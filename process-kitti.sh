#!/usr/bin/env bash
# Computes depth maps using dispnet for the specified KITTI odometry sequence.
# Puts the generated depth maps in a folder called 'precomputed-depth-dispnet',
# at the root of the sequence's folder. The files are 32-bit float maps in PFM
# format. Note that most image viewers won't display them correctly, and you
# need to use a custom library (see GitHub) for loading them in your programs.

set -eu
IFS=$'\n\t'
GPU_ID_TO_USE=0

if [[ "$#" -eq 0 ]] || [[ "$#" -gt 4 ]]; then
  echo >&2 "Usage: $0 <kitti_sequence_root> [<left_dir>, <right_dir>, <out_dir>]"
  exit 1
fi

SEQUENCE_ROOT="$1"
if [[ "$#" -eq 1 ]]; then
  LEFT_DIR="image_2"
  RIGHT_DIR="image_3"
  OUT_DIR="precomputed-depth-dispnet"
else
  LEFT_DIR="$2"
  RIGHT_DIR="$3"
  OUT_DIR="$4"
fi

SCRIPT_DIR="$(pwd)"
# How many images from the dataset to process.
LIMIT=100000

cd "$SEQUENCE_ROOT"

mkdir -p "$OUT_DIR"

ls "$LEFT_DIR"/*.png | head -n "$LIMIT" >| left-dispnet-in.txt
ls "$RIGHT_DIR"/*.png | head -n "$LIMIT" >| right-dispnet-in.txt

ls "$LEFT_DIR"/*.png | head -n "$LIMIT" | \
    sed "s/${LEFT_DIR}/${OUT_DIR}/g" | \
    sed 's/png/pfm/g' >| left-dispnet-out.txt

# Build the docker image and run the network inside it.
${SCRIPT_DIR}/run-network.sh -n DispNetCorr1D-K -g "$GPU_ID_TO_USE" -vv \
  left-dispnet-in.txt right-dispnet-in.txt left-dispnet-out.txt


