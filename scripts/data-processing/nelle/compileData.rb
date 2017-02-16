require_relative '../../lib/constants'
require_relative '../../lib/nelle/constants'
require_relative '../../lib/nelle/load'
require_relative '../../lib/nelle/ontology'

require 'date'
require 'fileutils'

# The old Nell data is in many different files, and needs to be compiled into the
# format that the embeddings use.
# All triple rows (both input and output) are in the form: head, tail, relation[, probability] (but tab separated).

# We will only include triples that meet or exceed a minimim onfidence.
DEFAULT_MIN_CONFIDENCE = 0.99

MIN_ENTITY_COUNT = 10
MIN_RELATION_COUNT = 5

def getTriples(dataDir, minConfidence)
   triples, rejectedCount = NellELoad.allTriples(dataDir, minConfidence)

   puts "Rejected #{rejectedCount} triples."
   puts "Left with #{triples.size()} triples."

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

def compileData(dataDir, minConfidence, ontologicalExpand)
   triples = getTriples(dataDir, minConfidence)

   if (ontologicalExpand)
      ontology = Ontology.load(dataDir)
      triples = Ontology.expand(triples, ontology, Ontology::DEFAULT_EXPAND_MAX_ITERATIONS, true)
   end

   suffix = DateTime.now().strftime('%Y%m%d%H%M')
   if (ontologicalExpand)
      suffix = "ONTOLOGY_EXPAND_#{suffix}"
   end

   outDir = File.join(Constants::RAW_DATA_PATH, "NELLE_#{"%05d" % (minConfidence * 10000).to_i()}_#{suffix}")
   FileUtils.mkdir_p(outDir)

   NellELoad.writeEntities(File.join(outDir, Constants::RAW_ENTITY_MAPPING_FILENAME), triples)
   NellELoad.writeRelations(File.join(outDir, Constants::RAW_RELATION_MAPPING_FILENAME), triples)

   NellELoad.writeTriples(File.join(outDir, Constants::RAW_TRAIN_FILENAME), triples)

   testTriples = NellELoad.testTriples(dataDir)
   if (ontologicalExpand)
      testTriples = Ontology.expand(testTriples, ontology, Ontology::DEFAULT_EXPAND_MAX_ITERATIONS, true)
   end

   evalTriples = writeTestSet(triples, testTriples, outDir)
end

def parseArgs(args)
   if (args.size() < 1 || args.size() > 3 || args.map{|arg| arg.downcase().strip().sub(/^-+/, '')}.include?('help'))
      puts "USAGE: ruby #{$0} <data dir> [minimum confidence] --ontologicalExpand"
      puts "minimum confidence -- Default: #{DEFAULT_MIN_CONFIDENCE}"
      puts "If --ontologicalExpand is supplied, then the ontology will be used to expand the triples."
      exit(1)
   end

   dataDir = args.shift()
   minConfidence = DEFAULT_MIN_CONFIDENCE
   ontologicalExpand = false

   if (args.size() > 0)
      if (args.include?('--ontologicalExpand'))
         ontologicalExpand = true
         args.delete('--ontologicalExpand')
      end
   end

   if (args.size() > 0)
      minConfidence = args.shift().to_f()

      if (minConfidence < 0 || minConfidence > 1)
         puts "Minimum confidence must be between 0 and 1."
         exit(2)
      end
   end

   if (args.size() > 0)
      puts "Unknown argument(s): #{args}"
      exit(3)
   end

   return dataDir, minConfidence, ontologicalExpand
end

def main(args)
   compileData(*parseArgs(args))
end

if (__FILE__ == $0)
   main(ARGV)
end
