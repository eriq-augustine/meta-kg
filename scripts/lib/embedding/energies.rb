require_relative 'transE'
require_relative 'transH'
require_relative '../distance'

require 'etc'

# gem install thread
require 'thread/pool'

module Energies
   NUM_THREADS = Etc.nprocessors - 1
   MIN_WORK_PER_THREAD = 100

   # If |useShortIdentifier| is true, then only the head and tail will be used as the energy key.
   # It is common to batch all triples of the same relation together, so it is not always necessary
   # in the caller.
   # |entityMapping| and |relationMapping| is used when the triples need to be converted to their surrogate keys
   # (the index into the embeddings).
   # If the triples are already translated, just pass nils for the mappings.
   def Energies.computeEnergies(
         triples,
         entityMapping, relationMapping,
         entityEmbeddings, relationEmbeddings, energyMethod,
         skipBadEnergies = false, useShortIdentifier = false)
      energies = {}

      pool = Thread.pool(NUM_THREADS)
      lock = Mutex.new()

      triples.each_slice([triples.size() / NUM_THREADS + 1, MIN_WORK_PER_THREAD].max()){|threadTriples|
         pool.process{
            threadTriples.each{|triple|
               if (useShortIdentifier)
                  id = triple[0...2].join(':')
               else
                  id = triple.join(':')
               end

               skip = false
               lock.synchronize {
                  if (energies.has_key?(id))
                     skip = true
                  else
                     # Mark the key so others don't try to take it mid-computation.
                     energies[id] = -1
                  end
               }

               if (skip)
                  next
               end

               if (entityMapping == nil)
                  ok, energy = energyMethod.call(
                     entityEmbeddings[triple[0]],
                     entityEmbeddings[triple[1]],
                     relationEmbeddings[triple[2]],
                     triple[0],
                     triple[1],
                     triple[2]
                  )
               else
                  # It is possible for the entity/relation to not exist if it got filtered
                  # out for having too low a confidence score.
                  # For these, just leave them out of the energy mapping.
                  if (!entityMapping.has_key?(triple[0]) || !entityMapping.has_key?(triple[1]) || !relationMapping.has_key?(triple[2]))
                     next
                  end

                  ok, energy = energyMethod.call(
                     entityEmbeddings[entityMapping[triple[0]]],
                     entityEmbeddings[entityMapping[triple[1]]],
                     relationEmbeddings[relationMapping[triple[2]]],
                     entityMapping[triple[0]],
                     entityMapping[triple[1]],
                     relationMapping[triple[2]]
                  )
               end

               if (!skipBadEnergies || ok)
                  lock.synchronize {
                     energies[id] = energy
                  }
               end
            }
         }
      }

      pool.wait(:done)
      pool.shutdown()

      # Remove rejected energies.
      energies.delete_if{|key, value| value == -1}

      return energies
   end

   # Given an embedding method and distance type, return a proc that will compute the energy.
   def Energies.getEnergyMethod(embeddingMethod, distanceType, embeddingDir)
      if (![Distance::L1_ID_STRING, Distance::L2_ID_STRING].include?(distanceType))
         raise("Unknown distance type: #{distanceType}")
      end

      case embeddingMethod
      when TransE::ID_STRING
         return proc{|head, tail, relation, headId, tailId, relationId|
            TransE.tripleEnergy(distanceType, head, tail, relation)
         }
      when TransH::ID_STRING
         transHWeights = LoadEmbedding.weights(embeddingDir)
         return proc{|head, tail, relation, headId, tailId, relationId|
            TransH.tripleEnergy(head, tail, relation, transHWeights[relationId])
         }
      else
         raise "Unknown embedding method: #{embeddingMethod}"
      end
   end

   # Given an embedding method and distance type, return the maximum energy that the method considers
   # not bad. This number is very subjective and I suggest callers find their own value.
   def Energies.getMaxEnergy(embeddingMethod, distanceType, embeddingDir)
      if (![Distance::L1_ID_STRING, Distance::L2_ID_STRING].include?(distanceType))
         raise("Unknown distance type: #{distanceType}")
      end

      case embeddingMethod
      when TransE::ID_STRING
         if (distanceType == Distance::L1_ID_STRING)
            return TransE::MAX_ENERGY_THRESHOLD_L1
         else
            return TransE::MAX_ENERGY_THRESHOLD_L2
         end
      when TransH::ID_STRING
         return TransH::MAX_ENERGY_THRESHOLD
      else
         raise "Unknown embedding method: #{embeddingMethod}"
      end
   end
end
