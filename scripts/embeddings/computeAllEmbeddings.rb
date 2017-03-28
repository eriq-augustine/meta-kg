require_relative 'computeEmbeddings'
require_relative '../lib/distance'
require_relative '../lib/embedding/constants'

require 'etc'
require 'fileutils'
require 'open3'

# gem install thread
require 'thread/pool'

NUM_THREADS = Etc.nprocessors - 1

FB15K_DATA_DIR = File.absolute_path(File.join(Constants::RAW_DATA_PATH, 'FB15k'))
FB15K_005_DATA_DIR = File.absolute_path(File.join(Constants::RAW_DATA_PATH, 'FB15k_005'))
FB15K_010_DATA_DIR = File.absolute_path(File.join(Constants::RAW_DATA_PATH, 'FB15k_010'))
FB15K_050_DATA_DIR = File.absolute_path(File.join(Constants::RAW_DATA_PATH, 'FB15k_050'))

NELL_DATA_DIR = File.absolute_path(File.join(Constants::RAW_DATA_PATH, 'NELL_95'))

UNCERTIAN_NELL_DIRS = [
   'NELL_050_080_[005,005]_201701141040',
   'NELL_050_080_[020,005]_201701141040',
   'NELL_050_080_[020,020]_201701141040',
   'NELL_050_080_[050,050]_201701141040',
   'NELL_050_080_[100,100]_201701141040',
   'NELL_050_100_[005,005]_201701141040',
   'NELL_050_100_[020,005]_201701141040',
   'NELL_050_100_[020,020]_201701141040',
   'NELL_050_100_[050,050]_201701141040',
   'NELL_050_100_[100,100]_201701141040',
   'NELL_080_090_[005,005]_201701141040',
   'NELL_080_090_[020,005]_201701141040',
   'NELL_080_090_[020,020]_201701141040',
   'NELL_080_090_[050,050]_201701141040',
   'NELL_080_090_[100,100]_201701141040',
   'NELL_090_100_[005,005]_201701141040',
   'NELL_090_100_[020,005]_201701141040',
   'NELL_090_100_[020,020]_201701141040',
   'NELL_090_100_[050,050]_201701141040',
   'NELL_090_100_[100,100]_201701141040',
   'NELL_095_100_[005,005]_201701141040',
   'NELL_095_100_[020,005]_201701141040',
   'NELL_095_100_[020,020]_201701141040',
   'NELL_095_100_[050,050]_201701141040',
   'NELL_095_100_[100,100]_201701141040',
   'NELL_100_100_[005,005]_201701141040',
   'NELL_100_100_[020,005]_201701141040',
   'NELL_100_100_[020,020]_201701141040',
   'NELL_100_100_[050,050]_201701141040',
   'NELL_100_100_[100,100]_201701141040'
].map{|basename| File.absolute_path(File.join(Constants::RAW_DATA_PATH, basename))}

SPARSITY_DATA_DIRS = [
   'NELL_050_055_[040,070,040,070,500000]_201703271559',
   'NELL_050_060_[010,040,010,040,500000]_201703271659',
   'NELL_050_060_[010,040,040,070,500000]_201703271705',
   'NELL_050_060_[010,040,070,100,500000]_201703271711',
   'NELL_050_060_[010,040,100,130,500000]_201703271716',
   'NELL_050_060_[040,070,010,040,500000]_201703271723',
   'NELL_050_060_[040,070,040,070,500000]_201703271728',
   'NELL_050_060_[040,070,070,100,500000]_201703271734',
   'NELL_050_060_[040,070,100,130,500000]_201703271740',
   'NELL_050_060_[070,100,010,040,500000]_201703271746',
   'NELL_050_060_[070,100,040,070,500000]_201703271752',
   'NELL_050_060_[070,100,070,100,500000]_201703271758',
   'NELL_050_060_[070,100,100,130,500000]_201703271804',
   'NELL_050_060_[100,130,010,040,500000]_201703271810',
   'NELL_050_060_[100,130,040,070,500000]_201703271816',
   'NELL_050_060_[100,130,070,100,500000]_201703271822',
   'NELL_050_060_[100,130,100,130,500000]_201703271828',
   'NELL_055_060_[040,070,040,070,500000]_201703271605',
   'NELL_060_065_[040,070,040,070,500000]_201703271611',
   'NELL_060_070_[010,040,010,040,500000]_201703271834',
   'NELL_060_070_[010,040,040,070,500000]_201703271840',
   'NELL_060_070_[010,040,070,100,500000]_201703271846',
   'NELL_060_070_[010,040,100,130,500000]_201703271851',
   'NELL_060_070_[040,070,010,040,500000]_201703271857',
   'NELL_060_070_[040,070,040,070,500000]_201703271903',
   'NELL_060_070_[040,070,070,100,500000]_201703271909',
   'NELL_060_070_[040,070,100,130,500000]_201703271915',
   'NELL_060_070_[070,100,010,040,500000]_201703271921',
   'NELL_060_070_[070,100,040,070,500000]_201703271927',
   'NELL_060_070_[070,100,070,100,500000]_201703271933',
   'NELL_060_070_[070,100,100,130,500000]_201703271939',
   'NELL_060_070_[100,130,010,040,500000]_201703271945',
   'NELL_060_070_[100,130,040,070,500000]_201703271951',
   'NELL_060_070_[100,130,070,100,500000]_201703271957',
   'NELL_060_070_[100,130,100,130,500000]_201703272002',
   'NELL_065_070_[040,070,040,070,500000]_201703271617',
   'NELL_070_075_[040,070,040,070,500000]_201703271623',
   'NELL_070_080_[010,040,010,040,500000]_201703272009',
   'NELL_070_080_[010,040,040,070,500000]_201703272014',
   'NELL_070_080_[010,040,070,100,500000]_201703272020',
   'NELL_070_080_[010,040,100,130,500000]_201703272026',
   'NELL_070_080_[040,070,010,040,500000]_201703272032',
   'NELL_070_080_[040,070,040,070,500000]_201703272038',
   'NELL_070_080_[040,070,070,100,500000]_201703272044',
   'NELL_070_080_[040,070,100,130,500000]_201703272050',
   'NELL_070_080_[070,100,010,040,500000]_201703272056',
   'NELL_070_080_[070,100,040,070,500000]_201703272102',
   'NELL_070_080_[070,100,070,100,500000]_201703272108',
   'NELL_070_080_[070,100,100,130,500000]_201703272114',
   'NELL_070_080_[100,130,010,040,500000]_201703272120',
   'NELL_070_080_[100,130,040,070,500000]_201703272126',
   'NELL_070_080_[100,130,070,100,500000]_201703272132',
   'NELL_070_080_[100,130,100,130,500000]_201703272138',
   'NELL_075_080_[040,070,040,070,500000]_201703271629',
   'NELL_080_085_[040,070,040,070,500000]_201703271635',
   'NELL_080_090_[010,040,010,040,500000]_201703272144',
   'NELL_080_090_[010,040,040,070,500000]_201703272150',
   'NELL_080_090_[010,040,070,100,500000]_201703272156',
   'NELL_080_090_[010,040,100,130,500000]_201703272202',
   'NELL_080_090_[040,070,010,040,500000]_201703272208',
   'NELL_080_090_[040,070,040,070,500000]_201703272214',
   'NELL_080_090_[040,070,070,100,500000]_201703272220',
   'NELL_080_090_[040,070,100,130,500000]_201703272226',
   'NELL_080_090_[070,100,010,040,500000]_201703272232',
   'NELL_080_090_[070,100,040,070,500000]_201703272238',
   'NELL_080_090_[070,100,070,100,500000]_201703272244',
   'NELL_080_090_[070,100,100,130,500000]_201703272250',
   'NELL_080_090_[100,130,010,040,500000]_201703272256',
   'NELL_080_090_[100,130,040,070,500000]_201703272302',
   'NELL_080_090_[100,130,070,100,500000]_201703272308',
   'NELL_080_090_[100,130,100,130,500000]_201703272313',
   'NELL_085_090_[040,070,040,070,500000]_201703271641',
   'NELL_090_095_[040,070,040,070,500000]_201703271647',
   'NELL_090_100_[010,040,010,040,500000]_201703272319',
   'NELL_090_100_[010,040,040,070,500000]_201703272326',
   'NELL_090_100_[010,040,070,100,500000]_201703272332',
   'NELL_090_100_[010,040,100,130,500000]_201703272337',
   'NELL_090_100_[040,070,010,040,500000]_201703272344',
   'NELL_090_100_[040,070,040,070,500000]_201703272350',
   'NELL_090_100_[040,070,070,100,500000]_201703272355',
   'NELL_090_100_[040,070,100,130,500000]_201703280001',
   'NELL_090_100_[070,100,010,040,500000]_201703280008',
   'NELL_090_100_[070,100,040,070,500000]_201703280013',
   'NELL_090_100_[070,100,070,100,500000]_201703280019',
   'NELL_090_100_[070,100,100,130,500000]_201703280026',
   'NELL_090_100_[100,130,010,040,500000]_201703280032',
   'NELL_090_100_[100,130,040,070,500000]_201703280037',
   'NELL_090_100_[100,130,070,100,500000]_201703280043',
   'NELL_090_100_[100,130,100,130,500000]_201703280050',
   'NELL_095_100_[040,070,040,070,500000]_201703271653'
].map{|basename| File.absolute_path(File.join(Constants::RAW_DATA_PATH, basename))}

TRANSE_EXPERIMENTS = {
   'emethod' => 'TransE',
   'data' => [FB15K_DATA_DIR, FB15K_005_DATA_DIR, FB15K_010_DATA_DIR, FB15K_050_DATA_DIR, NELL_DATA_DIR] + UNCERTIAN_NELL_DIRS,
   'args' => {
      'size' => [50, 100],
      'rate' => [0.01],
      'method' => [Embedding::METHOD_UNIFORM, Embedding::METHOD_BERNOULLI],
      'distance' => [Distance::L1_ID_INT, Distance::L2_ID_INT]
   }
}

TRANSH_EXPERIMENTS = {
   'emethod' => 'TransH',
   'data' => [FB15K_DATA_DIR, FB15K_005_DATA_DIR, FB15K_010_DATA_DIR, FB15K_050_DATA_DIR, NELL_DATA_DIR] + UNCERTIAN_NELL_DIRS,
   'args' => {
      'size' => [50, 100],
      'rate' => [0.01],
      'method' => [Embedding::METHOD_UNIFORM, Embedding::METHOD_BERNOULLI],
      'distance' => [Distance::L1_ID_INT]
   }
}

# Make sure the core settings mirror TRANSE since that is the seed data.
TRANSR_EXPERIMENTS = {
   'emethod' => 'TransR',
   'data' => [FB15K_DATA_DIR, FB15K_005_DATA_DIR, FB15K_010_DATA_DIR, FB15K_050_DATA_DIR, NELL_DATA_DIR],
   'args' => {
      'size' => [50, 100],
      'rate' => [0.01],
      'method' => [Embedding::METHOD_UNIFORM, Embedding::METHOD_BERNOULLI],
      'distance' => [Distance::L1_ID_INT, Distance::L2_ID_INT]
   }
}

# A new set of experiments revolving around confidence and sparsity.
SPARSITY_TRANSE_EXPERIMENTS = {
   'emethod' => 'TransE',
   'data' => SPARSITY_DATA_DIRS,
   'args' => {
      'size' => [100],
      'rate' => [0.001],
      'method' => [Embedding::METHOD_BERNOULLI],
      'distance' => [Distance::L1_ID_INT]
   }
}

# TransR needs some additional params.
def buildTransRExperiments(experimentsDefinition)
   experiments = buildExperiments(experimentsDefinition)

   experiments.each{|experiment|
      # TransE is the seed data, so grab the data from there.
      seeDataDir = getOutputDir(experiment).sub('TransR', 'TransE')
      experiment['args']['seeddatadir'] = seeDataDir

      # TODO(eriq): We are actually missing a set of experiments here.
      # The seed method and outer method are actually independent.
      experiment['args']['seedmethod'] = experiment['args']['method']
   }

   return experiments
end

# Take a condensed definition of some experiments and expand it out.
# TODO(eriq): This is pretty hacky and not robust at all.
def buildExperiments(experimentsDefinition)
   experiments = []

   experimentsDefinition['data'].each{|dataset|
      experimentsDefinition['args']['size'].each{|embeddingSize|
         experimentsDefinition['args']['method'].each{|method|
            experimentsDefinition['args']['distance'].each{|distance|
               experimentsDefinition['args']['rate'].each{|rate|
                  experiments << {
                     'emethod' => experimentsDefinition['emethod'],
                     'data' => dataset,
                     'args' => {
                        'size' => embeddingSize,
                        'margin' => 1,
                        'method' => method,
                        'rate' => rate,
                        'batches' => 100,
                        'epochs' => 1000,
                        'distance' => distance
                     }
                  }
               }
            }
         }
      }
   }

   return experiments
end

def runAll(experiments)
   pool = Thread.pool(NUM_THREADS)

   experiments.each{|experiment|
      pool.process{
         begin
            runExperiment(experiment)
         rescue Exception => ex
            puts "Failed to train #{getId(experiment)}"
            puts ex.message()
            puts ex.backtrace()
         end
      }
   }

   pool.wait(:done)
   pool.shutdown()
end

def main(args)
   experiments = buildExperiments(SPARSITY_TRANSE_EXPERIMENTS)

   # experiments = buildExperiments(TRANSE_EXPERIMENTS) + buildExperiments(TRANSH_EXPERIMENTS)
   # Some methods require data from other experiments and must be run after.
   # experiments2 = buildTransRExperiments(TRANSR_EXPERIMENTS)

   runAll(experiments)
   # runAll(experiments2)
end

if (__FILE__ == $0)
   main(ARGV)
end
