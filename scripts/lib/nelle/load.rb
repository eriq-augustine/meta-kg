require_relative 'constants'

module NellELoad
   def NellELoad.triples(path, minConfidence = 0.0)
      triples = []
      rejectedCount = 0

      File.open(path, 'r'){|file|
         file.each{|line|
            parts = line.split("\t").map{|part| part.strip()}
            if (parts[3].to_f() < minConfidence)
               rejectedCount += 1
               next
            end

            triples << parts[0...3].map{|part| part.to_i()}
         }
      }

      return triples, rejectedCount
   end

   # Just get all the unique triples as an Array.
   def NellELoad.allTriples(sourceDir)
      triples = []

      NellE::TRIPLE_FILENAMES.each{|filename|
         newTriples, newRejectedCount = NellELoad.triples(File.join(sourceDir, filename), -1)
         triples += newTriples
      }
      triples.uniq!()

      return triples
   end

   def NellELoad.categories(path, minConfidence = 0.0)
      cats = []
      rejectedCount = 0

      File.open(path, 'r'){|file|
         file.each{|line|
            parts = line.split("\t").map{|part| part.strip()}
            if (parts[2].to_f() < minConfidence)
               rejectedCount += 1
               next
            end

            cats << parts[0...2].map{|part| part.to_i()}
         }
      }

      return cats, rejectedCount
   end

   def NellELoad.writeEntities(path, triples)
      entities = []
      entities += triples.map{|triple| triple[0]}
      entities += triples.map{|triple| triple[1]}
      entities.uniq!

      File.open(path, 'w'){|file|
         file.puts(entities.map.with_index{|entity, index| "#{entity}\t#{index}"}.join("\n"))
      }
   end

   def NellELoad.writeRelations(path, triples)
      relations = triples.map{|triple| triple[2]}
      relations.uniq!

      File.open(path, 'w'){|file|
         file.puts(relations.map.with_index{|relation, index| "#{relation}\t#{index}"}.join("\n"))
      }
   end

   def NellELoad.writeTriples(path, triples)
      File.open(path, 'w'){|file|
         # Head, Tail, Relation
         file.puts(triples.map{|triple| "#{triple[0]}\t#{triple[1]}\t#{triple[2]}"}.join("\n"))
      }
   end
end
