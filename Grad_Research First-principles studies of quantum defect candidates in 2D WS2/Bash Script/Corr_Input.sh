#!/bin/bash

if [ $# -eq 0 ]; then
    echo "No transition metal symbol provided. Usage: ./a.sh <TM>"
    exit 1
fi

TM=$1

mkdir -p "${TM}/1-corr"
mkdir -p "${TM}/1+corr"

charge_states=("1-" "1+")
for state in "${charge_states[@]}"; do
    if [ "$state" == "1-" ]; then
        target_dir="${TM}/1-corr"
    else
        target_dir="${TM}/1+corr"
    fi

    path=$(grep "$state" "${TM}/Energy_Difference.txt" | awk '{print $2}')
    
    mkdir -p "$target_dir"
    
    cp "${path}/INCAR" "$target_dir/"
    cp "${path}/POTCAR" "$target_dir/"
    cp "${path}/KPOINTS" "$target_dir/"
    cp "${path}/job.vasp.pbs" "$target_dir/"
    cp "${path}/CONTCAR" "$target_dir/POSCAR"
    
    sed -i "s/#PBS -N .*/#PBS -N ${TM}_$(basename "$target_dir")/" "$target_dir/job.vasp.pbs" 
    echo "LVHAR = .TRUE." >> "$target_dir/INCAR"
    echo "ISYM = 0" >> "$target_dir/INCAR"
    
    (cd "$target_dir" && qsub job.vasp.pbs)
    echo "Submitted job for $target_dir"
done

