RESULTS_DIR = 'output'
RESULTS_DATA_STATS_DIR = File.join(RESULTS_DIR, 'rawDataStats')
RESULTS_EMBEDDING_EVAL_DIR = File.join(RESULTS_DIR, 'embeddingEvaluation')
RESULTS_GEN_EVAL_DIR = File.join(RESULTS_DIR, 'genEval')
RESULTS_HISTOGRAMS_DIR = File.join(RESULTS_DIR, 'histograms')
RESULTS_KGI_EVAL_DIR = File.join(RESULTS_DIR, 'kgiEval')

COMPILE_DIR = File.join(RESULTS_DIR, 'compiled')
COMPILE_RAW_STATS_PATH = File.join(COMPILE_DIR, '01_datasetStats.txt')
COMPILE_EMBEDDING_EVAL_PATH = File.join(COMPILE_DIR, '02_embeddingEval.txt')
COMPILE_GEN_EVAL_PATH = File.join(COMPILE_DIR, '03_genEval.txt')
COMPILE_HISTOGRAMS_PATH = File.join(COMPILE_DIR, '04_histograms.txt')
COMPILE_KGI_EVAL_PATH = File.join(COMPILE_DIR, '05_kgiEval.txt')

NUM_REGEX = '\d+(?:\.\d+)?'

def compileKGIEval()
   headers = [
      'Embeddings',
      'AUC',
      'Relation AUC',
      'Category AUC'
   ]

   data = []

   Dir["#{RESULTS_KGI_EVAL_DIR}/*.txt"].each{|path|
      File.open(path, 'r'){|inFile|
         values = [File.basename(path, '.*')]
         inFile.each{|line|
            if (match = line.match(/AUC:\s+(#{NUM_REGEX})$/))
               values << match[1]
            end
         }
         data << values
      }
   }

   File.open(COMPILE_KGI_EVAL_PATH, 'w'){|outFile|
      outFile.puts(headers.join("\t"))
      outFile.puts(data.sort().map{|row| row.join("\t")}.join("\n"))
   }
end

def compileHistograms()
   headers = [
      'Embeddings',
      'Count',
      'Min',
      'Max',
      '00 - 10',
      '10 - 20',
      '20 - 30',
      '30 - 40',
      '40 - 50',
      '50 - 60',
      '60 - 70',
      '70 - 80',
      '80 - 90',
      '90 - 100'
   ]

   data = []

   Dir["#{RESULTS_HISTOGRAMS_DIR}/*.txt"].each{|path|
      File.open(path, 'r'){|inFile|
         values = [File.basename(path, '.*')]
         inFile.each{|line|
            if (match = line.match(/\):\s+(#{NUM_REGEX})$/))
               values << match[1]
            elsif (match = line.match(/^Count:\s+(#{NUM_REGEX})$/))
               values << match[1]
            elsif (match = line.match(/^Min:\s+(#{NUM_REGEX}),\s+Max:\s+(#{NUM_REGEX})$/))
               values << match[1]
               values << match[2]
            end
         }
         data << values
      }
   }

   File.open(COMPILE_HISTOGRAMS_PATH, 'w'){|outFile|
      outFile.puts(headers.join("\t"))
      outFile.puts(data.sort().map{|row| row.join("\t")}.join("\n"))
   }
end

def compileGenEval()
   headers = [
      'Embeddings',
      'Triples Considered',
      'Energies Considered',
      'Energies Written',
      'Energies Dropped'
   ]

   data = []

   Dir["#{RESULTS_GEN_EVAL_DIR}/*.txt"].each{|path|
      File.open(path, 'r'){|inFile|
         values = [File.basename(path, '.*')]
         inFile.each{|line|
            if (match = line.match(/^\w+\s+\w+:\s+(#{NUM_REGEX})$/))
               values << match[1]
            end
         }
         data << values
      }
   }

   File.open(COMPILE_GEN_EVAL_PATH, 'w'){|outFile|
      outFile.puts(headers.join("\t"))
      outFile.puts(data.sort().map{|row| row.join("\t")}.join("\n"))
   }
end

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
            match = line.match(/Rank:\s+(#{NUM_REGEX}),\s+Hits@10:\s+(#{NUM_REGEX})/)
            values << match[1]
            values << match[2]
         }
         data << values
      }
   }

   File.open(COMPILE_EMBEDDING_EVAL_PATH, 'w'){|outFile|
      outFile.puts(headers.join("\t"))
      outFile.puts(data.sort().map{|row| row.join("\t")}.join("\n"))
   }
end

def compileRawDataStats()
   headers = [
      'Dataset',
      'Entities',
      'Relations',
      'Test - Triples',
      'Test - Distinct Entities',
      'Test - Distinct Relations',
      'Test - R/E - Mean',
      'Test - R/E - Median',
      'Test - E/R - Mean',
      'Test - E/R - Median',
      'Train - Triples',
      'Train - Distinct Entities',
      'Train - Distinct Relations',
      'Train - R/E - Mean',
      'Train - R/E - Median',
      'Train - E/R - Mean',
      'Train - E/R - Median',
      'Truth - Triples',
      'Truth - Distinct Entities',
      'Truth - Distinct Relations',
      'Truth - R/E - Mean',
      'Truth - R/E - Median',
      'Truth - E/R - Mean',
      'Truth - E/R - Median'
   ]

   data = []

   Dir["#{RESULTS_DATA_STATS_DIR}/*.txt"].each{|path|
      File.open(path, 'r'){|inFile|
         values = [File.basename(path, '.*')]
         inFile.each{|line|
            if (match = line.match(/(#{NUM_REGEX})/))
               values << match[1]
            end
         }
         data << values
      }
   }

   File.open(COMPILE_RAW_STATS_PATH, 'w'){|outFile|
      outFile.puts(headers.join("\t"))
      outFile.puts(data.sort().map{|row| row.join("\t")}.join("\n"))
   }
end

def main(args)
   `mkdir -p #{COMPILE_DIR}`

   compileRawDataStats()
   compileEmbeddingEval()
   compileGenEval()
   compileHistograms()
   compileKGIEval()
end

if ($0 == __FILE__)
   main(ARGV)
end
