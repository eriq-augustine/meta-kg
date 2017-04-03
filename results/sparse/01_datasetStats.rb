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

def compileRawDataStats()
   headers = [
      'Dataset',
      'Total - Triples',
      'Total - Distinct Entities',
      'Total - Distinct Relations',
      'Total - T/E - Gross Mean',
      'Total - T/R - Gross Mean',
      'Total - R/E - Mean',
      'Total - R/E - Median',
      'Total - E/R - Mean',
      'Total - E/R - Median',
      'Total - T/E - Mean',
      'Total - T/E - Median',
      'Total - T/R - Mean',
      'Total - T/R - Median',
      'Test - Triples',
      'Test - Distinct Entities',
      'Test - Distinct Relations',
      'Test - T/E - Gross Mean',
      'Test - T/R - Gross Mean',
      'Test - R/E - Mean',
      'Test - R/E - Median',
      'Test - E/R - Mean',
      'Test - E/R - Median',
      'Test - T/E - Mean',
      'Test - T/E - Median',
      'Test - T/R - Mean',
      'Test - T/R - Median',
      'Train - Triples',
      'Train - Distinct Entities',
      'Train - Distinct Relations',
      'Train - T/E - Gross Mean',
      'Train - T/R - Gross Mean',
      'Train - R/E - Mean',
      'Train - R/E - Median',
      'Train - E/R - Mean',
      'Train - E/R - Median',
      'Train - T/E - Mean',
      'Train - T/E - Median',
      'Train - T/R - Mean',
      'Train - T/R - Median',
      'Truth - Triples',
      'Truth - Distinct Entities',
      'Truth - Distinct Relations',
      'Truth - T/E - Gross Mean',
      'Truth - T/R - Gross Mean',
      'Truth - R/E - Mean',
      'Truth - R/E - Median',
      'Truth - E/R - Mean',
      'Truth - E/R - Median',
      'Truth - T/E - Mean',
      'Truth - T/E - Median',
      'Truth - T/R - Mean',
      'Truth - T/R - Median'
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
      puts(headers.join("\t"))
      puts(data.sort().map{|row| row.join("\t")}.join("\n"))
   }
end

def main(args)
   `mkdir -p #{COMPILE_DIR}`

   compileRawDataStats()
end

if ($0 == __FILE__)
   main(ARGV)
end
