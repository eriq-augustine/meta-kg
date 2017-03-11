GEN_SCRIPT = File.join('..', 'scripts', 'data-processing', 'nelle', 'genEvaluationEnergies.rb')

SOURCE_DIR = File.join('..', 'data', 'nelle', '165')
DATA_DIR = File.join('..', 'data', 'raw')
EMBEDDING_DIR = File.join('..', 'data', 'embeddings')
OUT_DIR = File.join('output', 'genEval')

experiments = [
   {:dataset => 'NELLE_08000_201703040942', :embedding => 'TransE_NELLE_08000_201703040942_[size:100,margin:1,method:0,rate:0.01,batches:100,epochs:1000,distance:0]'},
   {:dataset => 'NELLE_08000_ONTOLOGY_EXPAND_201703040942', :embedding => 'TransE_NELLE_08000_ONTOLOGY_EXPAND_201703040942_[size:100,margin:1,method:0,rate:0.01,batches:100,epochs:1000,distance:0]'},
   {:dataset => 'NELLE_09000_201703040941', :embedding => 'TransE_NELLE_09000_201703040941_[size:100,margin:1,method:0,rate:0.01,batches:100,epochs:1000,distance:0]'},
   {:dataset => 'NELLE_09000_ONTOLOGY_EXPAND_201703040941', :embedding => 'TransE_NELLE_09000_ONTOLOGY_EXPAND_201703040941_[size:100,margin:1,method:0,rate:0.01,batches:100,epochs:1000,distance:0]'},
   {:dataset => 'NELLE_09900_201702062214', :embedding => 'TransE_NELLE_09900_201702062214_[size:100,margin:1,method:0,rate:0.01,batches:100,epochs:1000,distance:0]'},
   {:dataset => 'NELLE_09900_ONTOLOGY_EXPAND_201702151754', :embedding => 'TransE_NELLE_09900_ONTOLOGY_EXPAND_201702151754_[size:100,margin:1,method:0,rate:0.01,batches:100,epochs:1000,distance:0]'},
   {:dataset => 'NELLE_08000_201703040942', :embedding => 'TransH_NELLE_08000_201703040942_[size:100,margin:1,method:0,rate:0.01,batches:100,epochs:1000,distance:0]'},
   {:dataset => 'NELLE_08000_ONTOLOGY_EXPAND_201703040942', :embedding => 'TransH_NELLE_08000_ONTOLOGY_EXPAND_201703040942_[size:100,margin:1,method:0,rate:0.01,batches:100,epochs:1000,distance:0]'},
   {:dataset => 'NELLE_09000_201703040941', :embedding => 'TransH_NELLE_09000_201703040941_[size:100,margin:1,method:0,rate:0.01,batches:100,epochs:1000,distance:0]'},
   {:dataset => 'NELLE_09000_ONTOLOGY_EXPAND_201703040941', :embedding => 'TransH_NELLE_09000_ONTOLOGY_EXPAND_201703040941_[size:100,margin:1,method:0,rate:0.01,batches:100,epochs:1000,distance:0]'},
   {:dataset => 'NELLE_09900_201702062214', :embedding => 'TransH_NELLE_09900_201702062214_[size:100,margin:1,method:0,rate:0.01,batches:100,epochs:1000,distance:0]'},
   {:dataset => 'NELLE_09900_ONTOLOGY_EXPAND_201702151754', :embedding => 'TransH_NELLE_09900_ONTOLOGY_EXPAND_201702151754_[size:100,margin:1,method:0,rate:0.01,batches:100,epochs:1000,distance:0]'},
]

`mkdir -p #{OUT_DIR}`

experiments.each{|experiment|
   id = experiment[:embedding].sub(/_\[size:.*$/, '')
   outPath = File.join(OUT_DIR, "#{id}.txt")

   puts "Generating eval evergies for #{id}"

   args = [
      SOURCE_DIR,
      File.join(EMBEDDING_DIR, experiment[:embedding])
   ]

   begin
      output = `jruby #{GEN_SCRIPT} #{args.map{|arg| "'#{arg}'"}.join(' ')}`

      puts output
      File.open(outPath, 'w'){|outFile|
         outFile.puts(output)
      }
   rescue Exception => ex
      puts "Failed to eval #{id}. #{ex}"
   end
}
