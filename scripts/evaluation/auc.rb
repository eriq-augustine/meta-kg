# We do not expect very large sets of triples in the TEST/VALID sets.

require_relative '../lib/constants'
require_relative '../lib/embedding/energies'
require_relative '../lib/load'

require 'set'

ENERGY_STEP = 0.10

# Return: [[triple, energy], ...]
def calcEvalEnergies(dataDir, embeddingDir)
   triplesPath = File.join(dataDir, Constants::RAW_TEST_FILENAME)
   energiesPath = File.join(embeddingDir, Constants::EVAL_ENERGIES_FILENAME)

   # To save memory, we will write all energies out first, and then just read them.
   File.open(energiesPath, 'w'){|file|
      Energies.computeTripleFile(triplesPath, dataDir, embeddingDir){|energies|
         file.puts(energies.map{|energy| energy.flatten().join("\t")}.join("\n"))

         # TEST
         puts "Wrote #{energies.size()} energies"
      }
   }

   return Load.tripleEnergies(energiesPath, false)
end

# Return: [[triple, energy], ...]
def loadEvalEnergies(dataDir, embeddingDir)
   energiesPath = File.join(embeddingDir, Constants::EVAL_ENERGIES_FILENAME)
   if (File.exists?(energiesPath))
      return Load.tripleEnergies(energiesPath, false)
   end

   return calcEvalEnergies(dataDir, embeddingDir)
end

def calcF1(energies, energyThreshold)
   truePos = 0
   falsePos = 0

   energies.each{|triple, energy|
      # True and false negatives.
      if (energy < energyThreshold)
         next
      end
   }
end



# set[[head, tail, relation], ...]
def loadValidTriples(dataDir)
   triples = Set.new()

   Constants::RAW_TRIPLE_FILENAMES.each{|filename|
      triples += Load.triples(File.join(dataDir, filename), false)
   }

   return triples
end

def parseArgs(args)
   if (args.size != 2 || args.map{|arg| arg.gsub('-', '').downcase()}.include?('help'))
      puts "USAGE: ruby #{$0} <data dir> <embedding dir>"
      exit(1)
   end

   dataDir = args.shift()
   embeddingDir = args.shift()

   return dataDir, embeddingDir
end

def main(args)
   dataDir, embeddingDir = parseArgs(args)

   loadEvalEnergies(dataDir, embeddingDir)
end

if ($0 == __FILE__)
   main(ARGV)
end
