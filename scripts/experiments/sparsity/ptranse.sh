#!/bin/sh

if [ $# -ne 2 ]; then
   echo "USAGE: $0 <data dir> <embedding dir>"
   exit 1
fi

CWD=`pwd`

PTRANSE_BASE_DIR='KB2E/PTransE/PTransE_add'
PCRA_SCRIPT='KB2E/PTransE/PCRA.py'
TEMP_DIR='temp/ptranse'

DATA_DIR=$1
EMBEDDING_DIR=$2

WORK_DIR="${TEMP_DIR}/$(basename $EMBEDDING_DIR)"
WORK_DATA_DIR="${WORK_DIR}/data"
WORK_PTRANSE_DIR="${WORK_DIR}/ptranse"

TOP_500_SOURCE="${EMBEDDING_DIR}/topEntityPairs_500.txt"
TOP_500_DEST="${WORK_DATA_DIR}/e1_e2.txt"

echo "Prepping ..."

mkdir -p "${WORK_DIR}"
cp -r "${PTRANSE_BASE_DIR}" "${WORK_PTRANSE_DIR}"
cp -r "${DATA_DIR}" "${WORK_DATA_DIR}"
cp "${PCRA_SCRIPT}" "${WORK_DIR}"

# Rename the top 500 entities.
cp "${TOP_500_SOURCE}" "${TOP_500_DEST}"

cd "${WORK_DIR}"

echo "Running PCRA ..."

python2 PCRA.py > out_pcra.txt 2> out_pcra.err

if [[ "$?" -ne 0 ]]; then
   echo "Failed to run PCRA"
   exit 10
fi

cd "${CWD}"
cd "${WORK_PTRANSE_DIR}"

echo "Building ..."

make > out_make.txt 2> out_make.err

if [[ "$?" -ne 0 ]]; then
   echo "Failed to make"
   exit 11
fi

echo "Training ..."

./Train_TransE_path 1 > out_train.txt 2> out_train.err

if [[ "$?" -ne 0 ]]; then
   echo "Failed to train"
   exit 12
fi

echo "Evaluating ..."

./Test_TransE_path 1 > out_test.txt 2> out_test.err

if [[ "$?" -ne 0 ]]; then
   echo "Failed to train"
   exit 12
fi

# Cleanup

cd "${CWD}"
exit 0
