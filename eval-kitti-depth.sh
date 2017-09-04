#!/usr/bin/env bash

set -eu
IFS=$'\n\t'

SCRIPT_DIR="$(pwd)"

# To get scores on the testing dataset, we'd have to submit the stuff online,
# so checking out the training error should suffice for now...
BENCH_DATA_ROOT="$HOME/datasets/kitti/depth-benchmark-2015/data_scene_flow/training/"
cd "$BENCH_DATA_ROOT"

LEFT_FOLDER="image_2"
RIGHT_FOLDER="image_3"
#ARCH="DispNetCorr1D-K"
#ARCH="DispNetCorr1D"
#ARCH="DispNet"
ARCH="DispNet-K"
OFFSET=0
LIMIT=200

# We only need this; disp_1 and flow are necessary only for the SF and OF benchmarks.
EXPERIMENT_OUT="disp_dispnet-${ARCH}/disp_0_pfm/"
mkdir -p "$EXPERIMENT_OUT"
mkdir -p "${EXPERIMENT_OUT}/../disp_0"

#ls "$LEFT_FOLDER"/*.png  | head -n "$LIMIT" >| left-dispnet-bench-in.txt  
#ls "$RIGHT_FOLDER"/*.png | head -n "$LIMIT" >| right-dispnet-bench-in.txt 

#ls "$LEFT_FOLDER"/*.png | head -n "$LIMIT" | \
  #sed "s|image_2|${EXPERIMENT_OUT}|g" | \
  #sed 's/png/pfm/g' >| left-dispnet-bench-out.txt

rm -f left-dispnet-bench-out.txt

#"${SCRIPT_DIR}"/run-network.sh -n "${ARCH}" -g 0 -vv \
  #left-dispnet-bench-in.txt right-dispnet-bench-in.txt left-dispnet-bench-out.txt

for (( i = $OFFSET ; i < $LIMIT; i++ )); do
  leftA="$LEFT_FOLDER/$(printf %06d $i)_10.png"
  leftB="$LEFT_FOLDER/$(printf %06d $i)_11.png"
  rightA="$RIGHT_FOLDER/$(printf %06d $i)_10.png"
  rightB="$RIGHT_FOLDER/$(printf %06d $i)_11.png"

  outA="${EXPERIMENT_OUT}$(printf %06d $i)_10.pfm"
  outB="${EXPERIMENT_OUT}$(printf %06d $i)_11.pfm"
  #echo $leftA $rightA

  #"${SCRIPT_DIR}"/run-network.sh -n "${ARCH}" -g 0 -v "$leftA" "$rightA" "$outA"
  #"${SCRIPT_DIR}"/run-network.sh -n "${ARCH}" -g 0 -v "$leftB" "$rightB" "$outB"

  echo $outA >> left-dispnet-bench-out.txt
  echo $outB >> left-dispnet-bench-out.txt
done

(cd "${SCRIPT_DIR}/cvtpfm" && cd pfmLib && make && cd .. &&
  g++ -o cvtpfm main.cpp pfmLib/pfmLib.a -lopencv_core -lopencv_highgui) && 
"${SCRIPT_DIR}/cvtpfm/cvtpfm" left-dispnet-bench-out.txt


# TODO add script to automagically run the KITTI evaluation
