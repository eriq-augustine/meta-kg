# Complie a wordnet knowledge graph from raw data files.

DATA_FILENAMES = [
   'data.adj',
   'data.adv',
   'data.noun',
   'data.verb'
]

# The relations are from this documentation: https://wordnet.princeton.edu/man/wninput.5WN.html
# The documentation seems a little out-of-date.

# Note, there is one non-unique marker (different between pos) that is ruining the party for everyone
# and forcing us to use embedded hashs instead of just one top level one.
# {pos => {symbol => idString, ...}, ...}
RELATION_SYMBOLS = {
   'n' => {
      '!'  => '_antonym',
      '@'  => '_hypernym',
      '@i' => '_instance_hypernym',
      '~'  => '_hyponym',
      '~i' => '_instance_hyponym',
      '#m' => '_member_holonym',
      '#s' => '_substance_holonym',
      '#p' => '_part_holonym',
      '%m' => '_member_meronym',
      '%s' => '_substance_meronym',
      '%p' => '_part_meronym',
      '='  => '_attribute',
      '+'  => '_derivationally_related_form',
      ';c' => '_synset_domain_topic',
      '-c' => '_member_of_domain_topic',
      ';r' => '_synset_domain_region',
      '-r' => '_member_of_domain_region',
      ';u' => '_synset_domain_usage',
      '-u' => '_member_of_domain_usage'
   },
   'v' => {
      '!'  => '_antonym',
      '@'  => '_hypernym',
      '~'  => '_hyponym',
      '*'  => '_entailment',
      '>'  => '_cause',
      '^'  => '_also_see',
      '$'  => '_verb_group',
      '+'  => '_derivationally_related_form',
      ';c' => '_synset_domain_topic',
      ';r' => '_synset_domain_region',
      ';u' => '_synset_domain_usage'
   },
   'a' => {
      '!'  => '_antonym',
      '&'  => '_similar_to',
      '<'  => '_participle_of_verb',
      '\\' => '_pertainym',
      '='  => '_attribute',
      '^'  => '_also_see',
      ';c' => '_synset_domain_topic',
      ';r' => '_synset_domain_region',
      ';u' => '_synset_domain_usage',
      '+'  => '_derivationally_related_form' # Not in documentation.
   },
   'r' => {
      '!'  => '_antonym',
      '\\' => '_derived_from_adjective',
      ';c' => '_synset_domain_topic',
      ';r' => '_synset_domain_region',
      ';u' => '_synset_domain_usage',
      '+'  => '_derivationally_related_form' # Not in documentation.
   }
}
# Treat adjative satelites the same as adjectives.
RELATION_SYMBOLS['s'] = RELATION_SYMBOLS['a']

def parseFile(path)
   triples = []

   File.open(path, 'r'){|file|
      file.each{|line|
         if (line.start_with?('  '))
            next
         end

         # Remove the gloss.
         line = line.split('|', 2)[0].strip()

         parts = line.split(' ')

         synsetId = parts.shift()

         # Lex filenum
         parts.shift()

         synsetPos = parts.shift()

         # Size is in hex.
         synsetSize = parts.shift().to_i(16)

         # We don't actually care about words.
         for i in 0...synsetSize
            # word
            parts.shift()

            # lex id
            parts.shift()
         end

         # The number of relations is in decimal.
         numRelations = parts.shift().to_i()

         for i in 0...numRelations
            relationSymbol = parts.shift()
            targetSynsetId = parts.shift()
            targetPos = parts.shift()
            # Index into word in target synset.
            parts.shift()

            if (!RELATION_SYMBOLS.include?(synsetPos))
               $stderr.puts("ERROR -- [#{path}::#{file.lineno}]: Unknown synset POS: '#{synsetPos}'")
               exit(2)
            end

            if (!RELATION_SYMBOLS[synsetPos].include?(relationSymbol))
               $stderr.puts("ERROR -- [#{path}::#{file.lineno}]: Unknown relation symbol for POS (#{synsetPos}): '#{relationSymbol}'")
               exit(3)
            end

            triples << [synsetId, targetSynsetId, RELATION_SYMBOLS[synsetPos][relationSymbol]]
         end
      }
   }

   return triples
end

def parseData(dataDir)
   triples = []

   DATA_FILENAMES.each{|filename|
      triples += parseFile(File.join(dataDir, filename))
   }

   # TEST
   puts triples.size()
end

def loadArgs(args)
   if (args.size != 1 || args.map{|arg| arg.gsub('-', '').downcase()}.include?('help'))
      puts "USAGE: ruby #{$0} <wordnet database dir>"
      exit(1)
   end

   return args.shift()
end

def main(args)
   dataDir = loadArgs(args)
   parseData(dataDir)
end

if ($0 == __FILE__)
   main(ARGV)
end
