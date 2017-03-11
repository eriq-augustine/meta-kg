SCRIPT = File.join('..', 'scripts', 'data-processing', 'nelle', 'replaceTruthValues.rb')

# java -Xmx15G -cp ./target/classes/edu/umd/cs/psl/kgi/:./target/classes:`cat classpath.out` edu.umd.cs.psl.kgi.LoadData ../../data/nelle/165/
# java -Xmx15G -cp ./target/classes/edu/umd/cs/psl/kgi/:./target/classes:`cat classpath.out` edu.umd.cs.psl.kgi.RunKGI > out-baseline.txt
# Delete psl.h2.db in between so run will fail if load does.

BASE_DIR = File.join('..', 'KnowledgeGraphIdentification', 'nell')
DATA_DIR = File.join('..', 'data', 'nelle')
DB_FILE = File.join(BASE_DIR, 'psl.h2.db')
OUT_DIR = File.join('output', 'kgi')

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

classpath = "#{BASE_DIR}/target/classes/edu/umd/cs/psl/kgi/:#{BASE_DIR}/target/classes"
classpath += ':' + `cat #{BASE_DIR}/classpath.out`

datasets.each{|dataset|
   loadOutPath = File.join(OUT_DIR, "#{dataset}-load.txt")
   runOutPath = File.join(OUT_DIR, "#{dataset}-run.txt")

   puts "Loading data for #{dataset} ..."

   args = [
      '-Xmx25G',
      '-cp', "#{classpath}",
      'edu.umd.cs.psl.kgi.LoadData',
      File.join(DATA_DIR, dataset) + '/'
   ]

   begin
      output = `java #{args.map{|arg| "'#{arg}'"}.join(' ')}`

      puts output
      File.open(loadOutPath, 'w'){|outFile|
         outFile.puts(output)
      }
   rescue Exception => ex
      puts "Failed to load #{dataset}. #{ex}"
      `rm -f '#{DB_FILE}'`
      next
   end

   puts "Running KGI for #{dataset} ..."

   args = [
      '-Xmx25G',
      '-cp', "#{classpath}",
      'edu.umd.cs.psl.kgi.RunKGI'
   ]

   begin
      output = `java #{args.map{|arg| "'#{arg}'"}.join(' ')}`

      puts output
      File.open(runOutPath, 'w'){|outFile|
         outFile.puts(output)
      }
   rescue Exception => ex
      puts "Failed to run KGI on #{dataset}. #{ex}"
   end

   `rm -f '#{DB_FILE}'`
}
