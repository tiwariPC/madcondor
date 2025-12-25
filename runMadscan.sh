#!/usr/bin/env bash

# Exit immediately on error and echo every command
set -e
set -x

ulimit -s unlimited

# -----------------------------
# Input arguments
# -----------------------------
JOBID=$1
SINTHETA=$2
TANBETA=$3
M35=$4
M55=$5
SINTHETA_TAG=${SINTHETA//./p}

# -----------------------------
# Job info
# -----------------------------
echo "===================================="
echo "JOBID        = ${JOBID}"
echo "sinθ         = ${SINTHETA}"
echo "tanβ         = ${TANBETA}"
echo "m35/36/37    = ${M35}"
echo "m55          = ${M55}"
echo "===================================="

# -----------------------------
# Untar production directory
# -----------------------------
echo "# Untar the Production Dir"
tar -xaf bbdm_2HDMa_type1_case1_scan.tar.gz
echo "Done"

# -----------------------------
# Prepare launch card
# -----------------------------
LAUNCH_CARD="bbdm_2HDMa_type1_case1_scan/launch_card_st${SINTHETA_TAG}_tb${TANBETA}_mA${M35}_ma${M55}.dat"

cp launch_card_template.dat "${LAUNCH_CARD}"

sed -i \
  -e "s/__TANBETA__/${TANBETA}/g" \
  -e "s/__SINTHETA__/${SINTHETA}/g" \
  -e "s/__M35__/${M35}/g" \
  -e "s/__M36__/${M35}/g" \
  -e "s/__M37__/${M35}/g" \
  -e "s/__M55__/${M55}/g" \
  "${LAUNCH_CARD}"

# -----------------------------
# Run MadEvent
# -----------------------------
cd bbdm_2HDMa_type1_case1_scan
./bin/madevent "launch_card_st${SINTHETA_TAG}_tb${TANBETA}_mA${M35}_ma${M55}.dat"
wait
# -----------------------------
# Copy events
# -----------------------------
RESULT_DIR="../results/Events_st${SINTHETA_TAG}_tb${TANBETA}_mA${M35}_ma${M55}"
mkdir -p "${RESULT_DIR}"
cp -r Events/. "${RESULT_DIR}/"

echo "===================================="
echo "Job finished successfully"
echo "===================================="
