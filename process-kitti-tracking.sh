#!/usr/bin/env bash
# Computes depth maps using dispnet for the specified KITTI tracking sequence.
# Puts the generated depth maps in a folder called
# 'precomputed-depth-dispnet/<sequence_number>',
# at the root of the dataset's folder. The files are 32-bit float maps in PFM
# format. Note that most image viewers won't display them correctly, and you
# need to use a custom library (e.g., pfmLib) for loading them into your 
# programs.

set -eu
IFS=$'\n\t'

if [[ "$#" -ne 3 ]]; then
  echo >&2 "Usage: $0 <tracking_dataset_root> <training/testing> <sequence_number>"
  exit 1
fi

SEQUENCE_ROOT="$1"
SEQUENCE_SPLIT="$2"
SEQUENCE_NUMBER="$3"
# Zero-Padded Sequence Number
PSN="$(printf '%04d' ${SEQUENCE_NUMBER})"

printf "Will process sequence [%04d] from dataset located at [%s] (%s).\n" \
  "${SEQUENCE_NUMBER}" "${SEQUENCE_ROOT}" "${SEQUENCE_SPLIT}"

SCRIPT_DIR="$(pwd)"
# How many images from the dataset to process.
LIMIT=100000

cd "$SEQUENCE_ROOT"
LEFT_DIR="${SEQUENCE_SPLIT}/image_02/${PSN}"
RIGHT_DIR="${SEQUENCE_SPLIT}/image_03/${PSN}"
OUT_DIR="${SEQUENCE_SPLIT}/precomputed-depth-dispnet/${PSN}"

if ! [[ -d "${LEFT_DIR}" ]]; then
  echo >&2 "Invalid left image directory."
  exit 2
fi

if ! [[ -d "${RIGHT_DIR}" ]]; then
  echo >&2 "Invalid right image directory."
  exit 3
fi

mkdir -vp "$OUT_DIR"

ls "${LEFT_DIR}"/*.png | head -n "$LIMIT" >| left-dispnet-in.txt
ls "${RIGHT_DIR}"/*.png | head -n "$LIMIT" >| right-dispnet-in.txt

ls "${LEFT_DIR}"/*.png | head -n "$LIMIT" | \
    sed 's/image_02/precomputed-depth-dispnet/g' | \
    sed 's/png/pfm/g' >| left-dispnet-out.txt

MODEL="DispNetCorr1D-K"
# NOT the same order as in nvidia-smi... Obviously...
GPU_ID=0

${SCRIPT_DIR}/run-network.sh -n "${MODEL}" -g "${GPU_ID}" -vv \
  left-dispnet-in.txt right-dispnet-in.txt left-dispnet-out.txt


