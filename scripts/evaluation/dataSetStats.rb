# Given a raw dataset, give some stats.

require_relative '../lib/constants'
require_relative '../lib/load'
require_relative '../lib/math-utils'

def tripleStats(label, triples)
   # Get stats on relations per entity and entities per relation.
   # {entity: {relation: count, ...}, ...}
   entities = Hash.new{|hash, key| hash[key] = Hash.new{|innerHash, innerKey| innerHash[innerKey] = 0}}
   relations = Hash.new{|hash, key| hash[key] = Hash.new{|innerHash, innerKey| innerHash[innerKey] = 0}}

   triples.each{|triple|
      entities[triple[Constants::HEAD]][triple[Constants::RELATION]] += 1
      entities[triple[Constants::TAIL]][triple[Constants::RELATION]] += 1

      relations[triple[Constants::RELATION]][triple[Constants::HEAD]] += 1
      relations[triple[Constants::RELATION]][triple[Constants::TAIL]] += 1
   }

   # For each entity, how many relatoions did it touch.
   # Visa-versa for relations.
   relationsPerEntitys = entities.values().map{|relations| relations.size()}
   entitiesPerRelation = relations.values().map{|entities| entities.size()}

   puts "#{label} Triples:"
   puts "   Num Triples: #{triples.size()}"

   puts "   Num Distinct Entities:  #{entities.size()}"
   puts "   Num Distinct Relations: #{relations.size()}"

   puts "   Relations per Entity:"
   puts "      Mean:   #{MathUtils.mean(relationsPerEntitys)}"
   puts "      Median: #{MathUtils.median(relationsPerEntitys)}"

   puts "   Entities per Relation:"
   puts "      Mean:   #{MathUtils.mean(entitiesPerRelation)}"
   puts "      Median: #{MathUtils.median(entitiesPerRelation)}"
end

def dataStats(dataDir)
   numEntities = Load.idMapping(File.join(dataDir, Constants::RAW_ENTITY_MAPPING_FILENAME)).size()
   numRelations = Load.idMapping(File.join(dataDir, Constants::RAW_RELATION_MAPPING_FILENAME)).size()

   puts "Num Entities:  #{numEntities}"
   puts "Num Relations: #{numRelations}"

   testTriples = Load.triples(File.join(dataDir, Constants::RAW_TEST_FILENAME))
   trainTriples = Load.triples(File.join(dataDir, Constants::RAW_TRAIN_FILENAME))
   validTriples = Load.triples(File.join(dataDir, Constants::RAW_VALID_FILENAME))

   [['Test', testTriples], ['Train', trainTriples], ['Valid', validTriples]].each{|label, triples|
      tripleStats(label, triples)
   }
end

def loadArgs(args)
   if (args.size != 1 || args.map{|arg| arg.gsub('-', '').downcase()}.include?('help'))
      puts "USAGE: ruby #{$0} <data dir>"
      exit(1)
   end

   return args.shift()
end

def main(args)
   dataDir = loadArgs(args)

   dataStats(dataDir)
end

if ($0 == __FILE__)
   main(ARGV)
end