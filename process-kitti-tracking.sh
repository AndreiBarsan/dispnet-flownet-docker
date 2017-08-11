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

if [[ "$#" -ne 2 ]]; then
  echo >&2 "Usage: $0 <tracking_dataset_root> <sequence_number>"
  exit 1
fi

SEQUENCE_ROOT="$1"
SEQUENCE_NUMBER="$2"
# Zero-Padded Sequence Number
PSN="$(printf '%04d' ${SEQUENCE_NUMBER})"

printf "Will process sequence [%04d] from dataset located at [%s].\n" \
  "${SEQUENCE_NUMBER}" "${SEQUENCE_ROOT}"

SCRIPT_DIR="$(pwd)"
# How many images from the dataset to process.
LIMIT=100000

cd "$SEQUENCE_ROOT"
LEFT_DIR="training/image_02/${PSN}"
RIGHT_DIR="training/image_03/${PSN}"
OUT_DIR="training/precomputed-depth-dispnet/${PSN}"

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

# TODO: how about trying DispNetCorr1D-K? It performs slightly better in their
# paper thanks to the explicit correlation layer.
MODEL="DispNet-K"

${SCRIPT_DIR}/run-network.sh -n "${MODEL}" -g 0 -vvv \
  left-dispnet-in.txt right-dispnet-in.txt left-dispnet-out.txt


