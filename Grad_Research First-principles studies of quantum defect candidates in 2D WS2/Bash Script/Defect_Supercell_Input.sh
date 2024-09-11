#!/bin/bash

TM=$1

if [ -z "$TM" ]; then
    echo "Usage: $0 [Transition Metal Symbol]"
    exit 1
fi

charge_states=("0" "1-" "1+")

sub_dirs=("no.1" "no.2" "no.3")

for state in "${charge_states[@]}"; do
  for sub_dir in "${sub_dirs[@]}"; do

    target_dir="${TM}/${state}/${sub_dir}"

    mkdir -p "$target_dir"
    echo "Directory created: $target_dir"

    # Copy
    poscar_file="" # Initialize variable
    if [[ $sub_dir == "no.1" ]]; then
      poscar_file="POSCAR1"
    elif [[ $sub_dir == "no.2" ]]; then
      poscar_file="POSCAR2"
    elif [[ $sub_dir == "no.3" ]]; then
      poscar_file="POSCAR3"
    fi

    cp "template/${poscar_file}" "$target_dir/POSCAR"
    cp template/job.vasp.pbs "$target_dir/"
    cp template/INCAR1 "$target_dir/INCAR"
    cp template/KPOINTS1 "$target_dir/KPOINTS"
    echo "File copied: $target_dir"

    # Modify
    sed -i "s/TM/${TM}/g" "$target_dir/POSCAR"
    
    # Extract Total Valence Electrons and adjust NELECT
    (cd "$target_dir" && vaspkit -task 103 > vaspkit_output.txt)
    total_valence=$(grep "Total Valence Electrons:" $target_dir/vaspkit_output.txt | awk '{print $4}')
    echo "Total Valence Electrons: $total_valence"

    
    # Append NELECT to the INCAR file
    if [[ $state == "0" ]]; then
      nelect_val=$(printf "%.0f" "$total_valence") 
    elif [[ $state == "1-" ]]; then
      nelect_val=$(printf "%.0f" $(echo "$total_valence + 1" | bc)) 
    elif [[ $state == "1+" ]]; then
      nelect_val=$(printf "%.0f" $(echo "$total_valence - 1" | bc)) 
    fi    

    echo "NELECT = $nelect_val" >> "$target_dir/INCAR"
    echo "Updated INCAR with NELECT = $nelect_val for $target_dir"

    # Modify job.vasp.pbs script
    job_name="${TM}_${state}_${sub_dir}" 
    sed -i "s/#PBS -N .*/#PBS -N $job_name/" "$target_dir/job.vasp.pbs"
    echo "Modified job.vasp.pbs with job name: $job_name"

    # Submit the job
    (cd "$target_dir" && qsub job.vasp.pbs)
    echo "Submitted job for $target_dir"

  done
done

