#!/bin/sh

mkdir -p  output/rawDataStats

ruby ../scripts/evaluation/dataSetStats.rb ../data/raw/NELLE_08000_201703040942 > output/rawDataStats/NELLE_08000_201703040942.txt
ruby ../scripts/evaluation/dataSetStats.rb ../data/raw/NELLE_08000_ONTOLOGY_EXPAND_201703040942 >  output/rawDataStats/NELLE_08000_ONTOLOGY_EXPAND_201703040942.txt
ruby ../scripts/evaluation/dataSetStats.rb ../data/raw/NELLE_09000_201703040941 >  output/rawDataStats/NELLE_09000_201703040941.txt
ruby ../scripts/evaluation/dataSetStats.rb ../data/raw/NELLE_09000_ONTOLOGY_EXPAND_201703040941 >  output/rawDataStats/NELLE_09000_ONTOLOGY_EXPAND_201703040941.txt
ruby ../scripts/evaluation/dataSetStats.rb ../data/raw/NELLE_09900_201702062214 >  output/rawDataStats/NELLE_09900_201702062214.txt
ruby ../scripts/evaluation/dataSetStats.rb ../data/raw/NELLE_09900_ONTOLOGY_EXPAND_201702151754 >  output/rawDataStats/NELLE_09900_ONTOLOGY_EXPAND_201702151754.txt
