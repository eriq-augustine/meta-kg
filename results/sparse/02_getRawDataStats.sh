#!/bin/sh

DATA_DIR='../../data/raw'
SCRIPT_PATH='../../scripts/evaluation/dataSetStats.rb'

mkdir -p  output/rawDataStats

for path in $DATA_DIR/FB15k*; do
   dataID=`echo ${path} | sed "s#${DATA_DIR}/##"`
   outPath="output/rawDataStats/${dataID}.txt"

   ruby $SCRIPT_PATH $path > $outPath
done
