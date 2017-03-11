# Given a raw dataset, give some stats.

require_relative '../lib/constants'
require_relative '../lib/load'
require_relative '../lib/math-utils'

def tripleStats(label, triples)
   # Get stats on relations per entity and entities per relation.
   # {entity: {relation: count, ...}, ...}
   entities = Hash.new{|hash, key| hash[key] = Hash.new{|innerHash, innerKey| innerHash[innerKey] = 0}}
   relations = Hash.new{|hash, key| hash[key] = Hash.new{|innerHash, innerKey| innerHash[innerKey] = 0}}

   # Triples per entity/realtion.
   entityTripleCounts = Hash.new{|hash, key| hash[key] = 0}
   relationTripleCounts = Hash.new{|hash, key| hash[key] = 0}

   triples.each{|triple|
      entities[triple[Constants::HEAD]][triple[Constants::RELATION]] += 1
      entities[triple[Constants::TAIL]][triple[Constants::RELATION]] += 1

      relations[triple[Constants::RELATION]][triple[Constants::HEAD]] += 1
      relations[triple[Constants::RELATION]][triple[Constants::TAIL]] += 1

      entityTripleCounts[triple[Constants::HEAD]] += 1
      entityTripleCounts[triple[Constants::TAIL]] += 1
      relationTripleCounts[triple[Constants::RELATION]] += 1
   }

   # For each entity, how many relatoions did it touch.
   # Visa-versa for relations.
   relationsPerEntities = entities.values().map{|relations| relations.size()}
   entitiesPerRelation = relations.values().map{|entities| entities.size()}

   triplesPerEntity = entityTripleCounts.values()
   triplesPerRelation = relationTripleCounts.values()

   puts "#{label} Triples:"
   puts "   Num Triples: #{triples.size()}"

   puts "   Num Distinct Entities:  #{entities.size()}"
   puts "   Num Distinct Relations: #{relations.size()}"

   puts "   Triples / Entities:  #{triples.size().to_f() / entities.size()}"
   puts "   Triples / Relations: #{triples.size().to_f() / relations.size()}"

   puts "   Relations per Entity:"
   puts "      Mean:   #{MathUtils.mean(relationsPerEntities)}"
   puts "      Median: #{MathUtils.median(relationsPerEntities)}"

   puts "   Entities per Relation:"
   puts "      Mean:   #{MathUtils.mean(entitiesPerRelation)}"
   puts "      Median: #{MathUtils.median(entitiesPerRelation)}"

   puts "   Triples per Entity:"
   puts "      Mean:   #{MathUtils.mean(triplesPerEntity)}"
   puts "      Median: #{MathUtils.median(triplesPerEntity)}"

   puts "   Triples per Relation:"
   puts "      Mean:   #{MathUtils.mean(triplesPerRelation)}"
   puts "      Median: #{MathUtils.median(triplesPerRelation)}"
end

def dataStats(dataDir)
   # Note that we don't care about int keys.
   testTriples = Load.triples(File.join(dataDir, Constants::RAW_TEST_FILENAME), false)
   trainTriples = Load.triples(File.join(dataDir, Constants::RAW_TRAIN_FILENAME), false)
   validTriples = Load.triples(File.join(dataDir, Constants::RAW_VALID_FILENAME), false)

   statSets = [
      ['Total', testTriples + trainTriples + validTriples],
      ['Train', testTriples],
      ['Test', trainTriples],
      ['Valid', validTriples]
   ]

   statSets.each{|label, triples|
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
