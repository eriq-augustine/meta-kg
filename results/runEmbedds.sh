#!/bin/sh

time ruby scripts/embeddings/computeEmbeddings.rb --emethod TransE --data data/raw/NELLE_08000_201703040942
time ruby scripts/embeddings/computeEmbeddings.rb --emethod TransE --data data/raw/NELLE_08000_ONTOLOGY_EXPAND_201703040942
time ruby scripts/embeddings/computeEmbeddings.rb --emethod TransE --data data/raw/NELLE_09000_201703040941
time ruby scripts/embeddings/computeEmbeddings.rb --emethod TransE --data data/raw/NELLE_09000_ONTOLOGY_EXPAND_201703040941

time ruby scripts/embeddings/computeEmbeddings.rb --emethod TransH --data data/raw/NELLE_08000_201703040942
time ruby scripts/embeddings/computeEmbeddings.rb --emethod TransH --data data/raw/NELLE_08000_ONTOLOGY_EXPAND_201703040942
time ruby scripts/embeddings/computeEmbeddings.rb --emethod TransH --data data/raw/NELLE_09000_201703040941
time ruby scripts/embeddings/computeEmbeddings.rb --emethod TransH --data data/raw/NELLE_09000_ONTOLOGY_EXPAND_201703040941
time ruby scripts/embeddings/computeEmbeddings.rb --emethod TransH --data data/raw/NELLE_09900_201702062214
time ruby scripts/embeddings/computeEmbeddings.rb --emethod TransH --data data/raw/NELLE_09900_ONTOLOGY_EXPAND_201702151754
