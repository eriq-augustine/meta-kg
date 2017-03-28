# Enumerate over the options and generate all the Nell-based datasets.

GEN_SCRIPT_PATH = File.join('scripts', 'data-processing', 'nell', 'genDatasetFiles.rb')
PRECISION = 2

MIN_CONFIDENCE = 0.50
MAX_CONFIDENCE = 1.00
CONFIDENCE_STEP = 0.10

# Triples Per Entity
MIN_TPE = 10
MAX_TPE = 130
TPE_STEP = 30

# Triples Per Relation
MIN_TPR = 10
MAX_TPR = 130
TPR_STEP = 30

MAX_TRIPLES = 500000

def genDataset(minConfidence, maxConfidence, minTPE, maxTPE, minTPR, maxTPR, maxTriples)
   args = [
      minConfidence,
      maxConfidence,
      minTPE,
      maxTPE,
      minTPR,
      maxTPR,
      maxTriples
   ]

   puts "ruby #{GEN_SCRIPT_PATH} #{args.map{|arg| "'#{arg}'"}.join(' ')}"
   `ruby #{GEN_SCRIPT_PATH} #{args.map{|arg| "'#{arg}'"}.join(' ')}`
end

def crossproductParams()
   paramSets = []

   minConfidence = MIN_CONFIDENCE
   while (minConfidence < MAX_CONFIDENCE)
      maxConfidence = (minConfidence + CONFIDENCE_STEP).round(PRECISION)

      minTPE = MIN_TPE
      while (minTPE < MAX_TPE)
         maxTPE = (minTPE + TPE_STEP)

         minTPR = MIN_TPR
         while (minTPR < MAX_TPR)
            maxTPR = (minTPR + TPR_STEP)

            paramSets << [minConfidence, maxConfidence, minTPE, maxTPE, minTPR, maxTPR, MAX_TRIPLES]

            minTPR = maxTPR
         end

         minTPE = maxTPE
      end

      minConfidence = maxConfidence
   end

   return paramSets
end

def detailedParams()
   paramSets = []

   # Confidence
   minConfidence = 0.50
   while (minConfidence < 1.00)
      maxConfidence = (minConfidence + 0.05).round(PRECISION)

      paramSets << [minConfidence, maxConfidence, 40, 70, 40, 70, MAX_TRIPLES]

      minConfidence = maxConfidence
   end

   return paramSets
end

def main()
   paramSets = detailedParams() + crossproductParams()

   paramSets.each{|paramSet|
      genDataset(*paramSet)
   }
end

if ($0 == __FILE__)
   main()
end
