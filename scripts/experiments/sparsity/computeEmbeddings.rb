require_relative '../../embeddings/computeAllEmbeddings'
require_relative '../../lib/constants'
require_relative '../../lib/distance'
require_relative '../../lib/embedding/constants'


EX_DATA_DIRS = [
   'FB15k',
   'FB15k_CORRUPT[010]',
   'FB15k_CORRUPT[020]',
   'FB15k_CORRUPT[030]',
   'FB15k_CORRUPT[040]',
   'FB15k_CORRUPT[050]',
   'FB15k_CR[100]',
   'FB15k_CR[200]',
   'FB15k_CR[300]',
   'FB15k_CR[400]',
   'FB15k_CR[500]',
   'FB15k_CR[600]'
].map{|basename| File.absolute_path(File.join(Constants::RAW_DATA_PATH, basename))}

EX_TRANSE_EXPERIMENTS = {
   'emethod' => 'TransE',
   'data' => EX_DATA_DIRS,
   'args' => {
      'size' => [100],
      'rate' => [0.001],
      'margin' => [1.0],
      'method' => [Embedding::METHOD_BERNOULLI],
      'distance' => [Distance::L1_ID_INT]
   }
}

def main(args)
   experiments = buildExperiments(EX_TRANSE_EXPERIMENTS)
   runAll(experiments)
end

if (__FILE__ == $0)
   main(ARGV)
end
