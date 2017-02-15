require_relative '../../lib/constants'
require_relative '../../lib/nelle/constants'
require_relative '../../lib/nelle/load'

require 'date'
require 'fileutils'

# The old Nell data is in many different files, and needs to be compiled into the
# format that the embeddings use.
# All triple rows (both input and output) are in the form: head, tail, relation[, probability] (but tab separated).

# We will only include triples that meet or exceed a minimim onfidence.
DEFAULT_MIN_CONFIDENCE = 0.99

MIN_ENTITY_COUNT = 10
MIN_RELATION_COUNT = 5

# Get gold standard evaluation triples.
def getTestTriples(dataDir)
   triples = []

   NellE::TEST_TRIPLE_FILENAMES.each{|filename|
      # These files have either 0 or 1, but we will only consider positive triples.
      newTriples, newRejectedCount = NellELoad.triples(File.join(dataDir, filename), 0.1)
      triples += newTriples
   }
   triples.uniq!()

   return triples
end

def getTriples(dataDir, minConfidence)
   triples = []
   rejectedCount = 0

   NellE::TRIPLE_FILENAMES.each{|filename|
      newTriples, newRejectedCount = NellELoad.triples(File.join(dataDir, filename), minConfidence)

      rejectedCount += newRejectedCount
      triples += newTriples
   }

   totalSize = triples.size() + rejectedCount
   dupSize = triples.size()

   puts "Rejected #{rejectedCount} / #{totalSize} triples"

   triples.uniq!()

   puts "Deduped from #{dupSize} -> #{triples.size()}"

   return triples
end

# Get some counting values for each entity/relation
# Returns: [{entityId: count, ...}, {relationId: count, ...}]
def countParts(triples)
   entityCount = Hash.new{|hash, key| hash[key] = 0}
   relationCount = Hash.new{|hash, key| hash[key] = 0}

   triples.each{|triple|
      entityCount[triple[0]] += 1
      entityCount[triple[1]] += 1
      relationCount[triple[2]] += 1
   }

   return entityCount, relationCount
end

# Pick up test triples that meet the requirements and split them between test and valid.
# Returns the triples that will be in the TEST file.
def writeTestSet(triples, testTriples, outDir)
   entityCount, relationCount = countParts(triples)

   keepTestTriples = []
   testTriples.each{|testTriple|
      if (entityCount[testTriple[0]] < MIN_ENTITY_COUNT ||
          entityCount[testTriple[1]] < MIN_ENTITY_COUNT ||
          relationCount[testTriple[2]] < MIN_RELATION_COUNT)
         next
      end

      keepTestTriples << testTriple
   }

   puts "Keeping: #{keepTestTriples.size()} / #{testTriples.size()} Test Triples"

   keepTestTriples.shuffle!()
   splitIndex = (keepTestTriples.size() / 2).to_i()

   evalTriples = keepTestTriples[0...splitIndex]
   validTriples = keepTestTriples[splitIndex...keepTestTriples.size()]

   NellELoad.writeTriples(File.join(outDir, Constants::RAW_TEST_FILENAME), evalTriples)
   NellELoad.writeTriples(File.join(outDir, Constants::RAW_VALID_FILENAME), validTriples)

   return evalTriples
end

def compileData(dataDir, minConfidence)
   triples = getTriples(dataDir, minConfidence)

   outDir = File.join(Constants::RAW_DATA_PATH, "NELLE_#{"%05d" % (minConfidence * 10000).to_i()}_#{DateTime.now().strftime('%Y%m%d%H%M')}")
   FileUtils.mkdir_p(outDir)

   NellELoad.writeEntities(File.join(outDir, Constants::RAW_ENTITY_MAPPING_FILENAME), triples)
   NellELoad.writeRelations(File.join(outDir, Constants::RAW_RELATION_MAPPING_FILENAME), triples)

   NellELoad.writeTriples(File.join(outDir, Constants::RAW_TRAIN_FILENAME), triples)

   testTriples = getTestTriples(dataDir)

   evalTriples = writeTestSet(triples, testTriples, outDir)
end

def parseArgs(args)
   if (args.size() < 1 || args.size() > 2 || args.map{|arg| arg.downcase().strip().sub(/^-+/, '')}.include?('help'))
      puts "USAGE: ruby #{$0} <data dir> [minimum confidence]"
      puts "minimum confidence -- Default: #{DEFAULT_MIN_CONFIDENCE}"
      exit(1)
   end

   dataDir = args[0]
   minConfidence = DEFAULT_MIN_CONFIDENCE

   if (args.size() == 2)
      minConfidence = args[1].to_f()

      if (minConfidence < 0 || minConfidence > 1)
         puts "Minimum confidence must be between 0 and 1."
         exit(2)
      end
   end

   return dataDir, minConfidence
end

def main(args)
   dataDir, minConfidence = parseArgs(args)
   compileData(dataDir, minConfidence)
end

if (__FILE__ == $0)
   main(ARGV)
end
