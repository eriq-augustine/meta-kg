require_relative '../distance'

require 'matrix'

module STransE
   ID_STRING = 'STransE'

   ENTITY_EMBEDDING_EXT = 'entity2vec'
   RELATION_EMBEDDING_EXT = 'relation2vec'
   WEIGHT1_EXT = 'W1'
   WEIGHT2_EXT = 'W2'

   # Remember, each param is an embedding vector.
   def STransE.tripleEnergy(distanceType, head, tail, relation, weight1, weight2)
      energy = 0

      head = Matrix.column_vector(head)
      tail = Matrix.column_vector(tail)
      relation = Matrix.column_vector(relation)
      weight1 = Matrix.rows(weight1)
      weight2 = Matrix.rows(weight2)

      res = (weight1 * head) + relation - (weight2 * tail)
      if (distanceType == Distance::L1_ID_STRING)
         res.each{|val|
            energy += val.abs()
         }
      elsif (distanceType == Distance::L2_ID_STRING)
         res.each{|val|
            energy += val ** 2
         }
         energy = Math.sqrt(energy)
      else
         raise("Unknown distance type: [#{distanceType}]")
      end

      return true, energy
   end

   def STransE.loadWeights(embeddingDir)
      weight1Path = nil
      weight2Path = nil

      Dir.foreach(embeddingDir){|filename|
         if (filename.end_with?(".#{WEIGHT1_EXT}"))
            weight1Path = File.join(embeddingDir, filename)
         elsif (filename.end_with?(".#{WEIGHT2_EXT}"))
            weight2Path = File.join(embeddingDir, filename)
         end
      }

      return STransE.loadWeightFile(weight1Path), STransE.loadWeightFile(weight2Path)
   end

   # Weights are 3d.
   # Each line holds one matrix.
   # We will just infer matrix size from row length.
   # [relation][entity][entity]
   def STransE.loadWeightFile(path)
      weights = []

      File.open(path, 'r'){|file|
         file.each{|line|
            parts = line.strip().split("\t").map{|part| part.strip().to_f()}

            size = Math.sqrt(parts.size())
            if (size != size.to_i())
               raise("Weight matrix not square: #{path}[#{file.lineno}]")
            end
            size = size.to_i()

            matrix = []
            for i in 0...size
               row = []
               for j in 0...size
                  row << parts[i * size + j]
               end
               matrix << row
            end

            weights << matrix
         }
      }

      return weights
   end
end
