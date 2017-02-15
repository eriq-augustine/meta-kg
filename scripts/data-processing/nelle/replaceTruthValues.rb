require_relative '../../lib/constants'
require_relative '../../lib/embedding/energies'
require_relative '../../lib/nelle/constants'
require_relative '../../lib/nelle/load'

require 'date'
require 'fileutils'

# Given a data directory, copy it and replace the relation truth values with
# ones computed from embedding energies.

ENERGY_FILE = 'energies.txt'

PAGE_SIZE = 1000

def loadEnergiesFromFile(path)
   energies = {}

   File.open(path, 'r'){|file|
      file.each{|line|
         parts = line.split("\t").map{|part| part.strip()}
         energies[parts[0...3].join(':')] = parts[3].to_f()
      }
   }

   return energies
end

def writeEnergies(path, energies)
   File.open(path, 'w'){|file|
      energies.each_slice(PAGE_SIZE){|page|
         file.puts(page.map{|energyId, energy| "#{energyId.gsub(':', "\t")}\t#{energy}"}.join("\n"))
      }
   }
end

# Returns: {'head:tail:relation' => energy, ...}
def getEnergies(sourceDir, datasetDir, embeddingDir, embeddingMethod, distanceType)
   energyPath = File.join(embeddingDir, ENERGY_FILE)
   if (File.exists?(energyPath))
      return loadEnergiesFromFile(energyPath)
   end

   triples = NellELoad.allTriples(sourceDir)

   # Note that the embeddings are indexed by the value in the mappings (eg. entity2id.txt).
	entityMapping = Load.idMapping(File.join(datasetDir, Constants::RAW_ENTITY_MAPPING_FILENAME), true)
	relationMapping = Load.idMapping(File.join(datasetDir, Constants::RAW_RELATION_MAPPING_FILENAME), true)

   entityEmbeddings, relationEmbeddings = LoadEmbedding.vectors(embeddingDir)

   energyMethod = Energies.getEnergyMethod(embeddingMethod, distanceType, embeddingDir)

   energies = Energies.computeEnergies(triples, entityMapping, relationMapping, entityEmbeddings, relationEmbeddings, energyMethod)
   writeEnergies(energyPath, energies)

   return energies
end

def normalizeEnergies(energies)
   minEnergy, maxEnergy = energies.values().minmax()

   energies.keys().each{|key|
      energies[key] = 1.0 - ((energies[key] - minEnergy) / (maxEnergy - minEnergy))
   }
end

def replaceEnergies(sourceDir, outDir, energies)
   FileUtils.cp_r(sourceDir, outDir)

   NellE::REPLACEMENT_TRIPLE_FILENAMES.each{|filename|
      triples = []

      File.open(File.join(outDir, filename), 'r'){|file|
         file.each{|line|
            parts = line.split("\t").map{|part| part.strip()}
            triples << parts[0...3].map{|part| part.to_i()} + [parts[3].to_f()]
         }
      }

      triples.each_index{|i|
         id = triples[i][0...3].join(':')

         if (energies.has_key?(id))
            triples[i][3] = energies[id]
         end
      }

      File.open(File.join(outDir, filename), 'w'){|file|
         triples.each_slice(PAGE_SIZE){|page|
            file.puts(page.map{|triple| triple.join("\t")}.join("\n"))
         }
      }
   }
end

def main(args)
   sourceDir, datasetDir, embeddingDir, outDir, embeddingMethod, distanceType = parseArgs(args)

   FileUtils.mkdir_p(File.absolute_path(File.join(outDir, '..')))

   energies = getEnergies(sourceDir, datasetDir, embeddingDir, embeddingMethod, distanceType)
   normalizeEnergies(energies)
   replaceEnergies(sourceDir, outDir, energies)
end

def parseArgs(args)
   sourceDir = nil
   embeddingDir = nil
   outDir = nil
   datasetDir = nil
   embeddingMethod = nil
   distanceType = nil

   if (args.size() < 2 || args.size() > 6 || args.map{|arg| arg.downcase().gsub('-', '')}.include?('help'))
      puts "USAGE: ruby #{$0} <source dir> <embedding dir> [output dir [dataset dir [embedding method [distance type]]]]"
      puts "Defaults:"
      puts "   output dir = inferred"
      puts "   dataset dir = inferred"
      puts "   embedding method = inferred"
      puts "   distance type = inferred"
      puts ""
      puts "All the inferred aguments relies on the source and emebedding directory"
      puts "being formatted by the evalAll.rb script."
      puts "The directory that the inferred output directory will be put in is: #{Constants::NELLE_DATA_PATH}."
      exit(2)
   end

   sourceDir = args.shift()
   embeddingDir = args.shift()

   if (args.size() > 0)
      outDir = args.shift()
   else
      suffix = DateTime.now().strftime('%Y%m%d%H%M')
      outDir = "#{File.join(Constants::NELLE_DATA_PATH, File.basename(sourceDir))}_EMBED_#{suffix}"
   end

   if (args.size() > 0)
      datasetDir = args.shift()
   else
      dataset = File.basename(embeddingDir).match(/^[^_]+_(\S+)_\[size:/)[1]
      datasetDir = File.join(Constants::DATA_PATH, File.join(dataset))
   end

   if (args.size() > 0)
      embeddingMethod = args.shift()
   else
      embeddingMethod = File.basename(embeddingDir).match(/^([^_]+)_/)[1]
   end

   if (args.size() > 0)
      distanceType = args.shift()
   else
      # TODO(eriq): This may be a little off for TransR.
      if (embeddingDir.include?("distance:#{Distance::L1_ID_INT}"))
         distanceType = Distance::L1_ID_STRING
      elsif (embeddingDir.include?("distance:#{Distance::L2_ID_INT}"))
         distanceType = Distance::L2_ID_STRING
      end
   end

   return sourceDir, datasetDir, embeddingDir, outDir, embeddingMethod, distanceType
end

if (__FILE__ == $0)
   main(ARGV)
end
