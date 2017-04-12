require_relative '../../lib/constants'
require_relative '../../lib/load'

require 'date'
require 'fileutils'

TRAINING_PERCENT = 0.90

def getTriples(dataPath)
   triples = []

   File.open(dataPath, 'r'){|file|
      file.each{|line|
         parts = line.split("\t").map{|part| part.strip()}
         confidence = parts.pop().to_f()

         triple = Array.new(3)
         triple[Constants::HEAD] = parts[0]
         triple[Constants::TAIL] = parts[2]
         triple[Constants::RELATION] = parts[1]

         triples << triple
      }
   }

   return triples.uniq()
end

def compileData(dataFile, suffix)
   triples = getTriples(dataFile)

   outDir = File.join(Constants::RAW_DATA_PATH, "REVERB_#{suffix}")
   FileUtils.mkdir_p(outDir)

   puts "Creating new dataset in #{outDir}"

   Load.writeEntities(File.join(outDir, Constants::RAW_ENTITY_MAPPING_FILENAME), triples)
   Load.writeRelations(File.join(outDir, Constants::RAW_RELATION_MAPPING_FILENAME), triples)

   # TODO(eriq): We probably need smarter splitting?
   trainingSize = (triples.size() * TRAINING_PERCENT).to_i()

   # Both test and valid sets will get this count.
   # The rounding error on odd is a non-issue. The valid will just have one less.
   testSize = ((triples.size() - trainingSize) / 2 + 0.5).to_i()

   triples.shuffle!()
   trainingSet = triples.slice(0, trainingSize)
   testSet = triples.slice(trainingSize, testSize)
   validSet = triples.slice(trainingSize + testSize, testSize)

   Load.writeTriples(File.join(outDir, Constants::RAW_TRAIN_FILENAME), trainingSet)
   Load.writeTriples(File.join(outDir, Constants::RAW_TEST_FILENAME), testSet)
   Load.writeTriples(File.join(outDir, Constants::RAW_VALID_FILENAME), validSet)
end

def parseArgs(args)
   if (args.size() < 1 || args.size() > 2 || args.map{|arg| arg.downcase().strip().sub(/^-+/, '')}.include?('help'))
      puts "USAGE: ruby #{$0} <data file> [suffix]"
      exit(1)
   end

   dataFile = args.shift()
   suffix = DateTime.now().strftime('%Y%m%d%H%M')

   if (args.size() > 0)
      suffix = args.shift()
   end

   return dataFile, suffix
end

def main(args)
   compileData(*parseArgs(args))
end

if (__FILE__ == $0)
   main(ARGV)
end
