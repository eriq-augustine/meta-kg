SCRIPT = File.join('..', 'KnowledgeGraphIdentification', 'nell', 'scripts', 'cal_f1_auc_j.pl')

DATA_DIR = File.join('..', 'data', 'nelle')
EMBEDDING_DIR = File.join('..', 'data', 'embeddings')

KGI_OUT_DIR = File.join('output', 'kgi')
OUT_DIR = File.join('output', 'kgiEval')

datasets = [
   '165_EMBED_TransE_NELLE_08000_201703040942',
   '165_EMBED_TransE_NELLE_08000_ONTOLOGY_EXPAND_201703040942',
   '165_EMBED_TransE_NELLE_09000_201703040941',
   '165_EMBED_TransE_NELLE_09000_ONTOLOGY_EXPAND_201703040941',
   '165_EMBED_TransE_NELLE_09900_201702062214',
   '165_EMBED_TransE_NELLE_09900_ONTOLOGY_EXPAND_201702151754',
   '165_EMBED_TransH_NELLE_08000_201703040942',
   '165_EMBED_TransH_NELLE_08000_ONTOLOGY_EXPAND_201703040942',
   '165_EMBED_TransH_NELLE_09000_201703040941',
   '165_EMBED_TransH_NELLE_09000_ONTOLOGY_EXPAND_201703040941',
   '165_EMBED_TransH_NELLE_09900_201702062214',
   '165_EMBED_TransH_NELLE_09900_ONTOLOGY_EXPAND_201702151754'
]

`mkdir -p #{OUT_DIR}`

datasets.each{|dataset|
   id = dataset
   outPath = File.join(OUT_DIR, "#{id}.txt")

   puts "Replacing truth values for #{id}"

   args = [
      File.join(KGI_OUT_DIR, "#{id}-run.txt"),
      File.join(DATA_DIR, dataset, 'label-test-uniq-raw-cat.db.TRAIN'),
      File.join(DATA_DIR, dataset, 'label-test-uniq-raw-rel.db.TRAIN')
   ]

   begin
      output = `perl #{SCRIPT} #{args.map{|arg| "'#{arg}'"}.join(' ')}`

      puts output
      File.open(outPath, 'w'){|outFile|
         outFile.puts(output)
      }
   rescue Exception => ex
      puts "Failed to replace #{id}. #{ex}"
   end
}
