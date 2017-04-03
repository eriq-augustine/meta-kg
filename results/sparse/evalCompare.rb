RESULTS_DIR = 'output'
RESULTS_DATA_STATS_DIR = File.join(RESULTS_DIR, 'rawDataStats')
RESULTS_EMBEDDING_EVAL_DIR = File.join(RESULTS_DIR, 'eval')
RESULTS_GEN_EVAL_DIR = File.join(RESULTS_DIR, 'genEval')
RESULTS_HISTOGRAMS_DIR = File.join(RESULTS_DIR, 'histograms')
RESULTS_KGI_EVAL_DIR = File.join(RESULTS_DIR, 'kgiEval')

COMPILE_DIR = File.join(RESULTS_DIR, 'compiled')
COMPILE_RAW_STATS_PATH = File.join(COMPILE_DIR, '01_datasetStats.txt')
COMPILE_EMBEDDING_EVAL_PATH = File.join(COMPILE_DIR, '02_embeddingEval.txt')
COMPILE_GEN_EVAL_PATH = File.join(COMPILE_DIR, '03_genEval.txt')
COMPILE_HISTOGRAMS_PATH = File.join(COMPILE_DIR, '04_histograms.txt')
COMPILE_KGI_EVAL_PATH = File.join(COMPILE_DIR, '05_kgiEval.txt')

NUM_REGEX = '(?:\d+(?:\.\d+)?)|(?:-?nan)'

def compileEmbeddingEval()
   headers = [
      'Embeddings',
      'Raw - Rank',
      'Raw - Hits@10',
      'Filtered - Rank',
      'Filtered - Hits@10'
   ]

   data = []

   Dir["#{RESULTS_EMBEDDING_EVAL_DIR}/*.txt"].each{|path|
      File.open(path, 'r'){|inFile|
         values = [File.basename(path, '.*')]
         inFile.each{|line|
            if (match = line.match(/Rank:\s+(#{NUM_REGEX}),\s+Hits@10:\s+(#{NUM_REGEX})/))
               values << match[1]
               values << match[2]
            end
         }

         if (values.size() == 1)
            values << 999999
            values << -1
            values << 999999
            values << -1
         end

         data << values
      }
   }

   puts(headers.join("\t"))
   puts(data.sort().map{|row| row.join("\t")}.join("\n"))
end

def main(args)
   `mkdir -p #{COMPILE_DIR}`

   compileEmbeddingEval()
end

if ($0 == __FILE__)
   main(ARGV)
end
