module Reverb
   DATA_FILENAME = 'data.txt'

   # Compiled annotations written out to the RAW data directory.
   ANNOTATIONS_RAW_FILENAME = 'annotations.txt'

   ANNOTATIONS_DIR = 'annotations'
   # Relative to the base data dir (where DATA_FILENAME lives).
   ANNOTATIONS_FILE_RELPATH = File.join(ANNOTATIONS_DIR, 'reverb-scored.txt')
end
