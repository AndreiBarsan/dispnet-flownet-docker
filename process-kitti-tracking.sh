#!/usr/bin/env bash
# Computes depth maps using dispnet for the specified KITTI odometry sequence.
# Puts the generated depth maps in a folder called 'precomputed-depth-dispnet',
# at the root of the sequence's folder. The files are 32-bit float maps in PFM
# format. Note that most image viewers won't display them correctly, and you
# need to use a custom library (see GitHub) for loading them in your programs.

set -eu
IFS=$'\n\t'

if [[ "$#" -ne 1 ]]; then
  echo >&2 "Usage: $0 <kitti_sequence_root>"
  exit 1
fi

SEQUENCE_ROOT="$1"
SCRIPT_DIR="$(pwd)"
# How many images from the dataset to process.
LIMIT=100000

cd "$SEQUENCE_ROOT"

mkdir -p precomputed-depth-dispnet

ls image_0/*.png | head -n "$LIMIT" >| left-dispnet-in.txt
ls image_1/*.png | head -n "$LIMIT" >| right-dispnet-in.txt

ls image_0/*.png | head -n "$LIMIT" | \
    sed 's/image_0/precomputed-depth-dispnet/g' | \
    sed 's/png/pfm/g' >| left-dispnet-out.txt

# TODO: how about trying DispNetCorr1D-K?
${SCRIPT_DIR}/run-network.sh -n DispNet-K -g 0 -v \
  left-dispnet-in.txt right-dispnet-in.txt left-dispnet-out.txt


