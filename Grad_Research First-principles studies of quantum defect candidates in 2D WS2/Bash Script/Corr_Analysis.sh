#!/bin/bash

if [ $# -eq 0 ]; then
    echo "No transition metal symbol provided. Usage: ./a.sh <TM>"
    exit 1
fi

TM=$1

charge_states=("1-" "1+")

for state in "${charge_states[@]}"; do
  target_dir="${TM}/${state}corr"

  cp "${target_dir}/LOCPOT" "${target_dir}/vDef.sxb"

  cp "template/corr.sh" "${target_dir}/"
  cp "pristine/LOCPOT" "${target_dir}/vRef.sxb"
  
  if [ "$state" == "1-" ]; then
    sed -i 's/Q = .*/Q = +1 ;/' "${target_dir}/corr.sh"
  elif [ "$state" == "1+" ]; then
    sed -i 's/Q = .*/Q = -1 ;/' "${target_dir}/corr.sh"
  fi

  z=$(awk 'NR==24 {print $3}' "${target_dir}/vDef.sxb")
  new_posZ=$(echo "18.1460990906/0.52918*$z" | bc -l)

  sed -i "s/posZ = .*/posZ = $new_posZ ;/" "${target_dir}/corr.sh"

  (cd "${target_dir}" && ./corr.sh)
  cat "${target_dir}/ALIGNED.txt"
done


