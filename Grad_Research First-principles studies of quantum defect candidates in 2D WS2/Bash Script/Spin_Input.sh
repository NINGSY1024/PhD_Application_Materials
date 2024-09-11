#!/bin/bash

TM=$1

if [ -z "$TM" ]; then
    echo "Usage: $0 [Transition Metal Symbol]"
    exit 1
fi

charge_states=("0" "1-" "1+")


# Loop through each charge state
for state in "${charge_states[@]}"; do
    
    path=$(awk -v state="$state" '$1 == state {print $2}' "${TM}/Energy_Difference.txt")    

    
    nelect=$(grep "NELECT" "$path/INCAR" | cut -d '=' -f2 | awk '{print int($1)}' )
    # Process only if NELECT is an even number
    if (( $(echo "$nelect % 2" | bc) == 0 )); then
        # Define singlet and triplet directories based on the charge state
        singlet_dir="${TM}/${state}S"
        triplet_dir="${TM}/${state}T"

        # Create directories and copy files for both singlet and triplet states
        for spin_dir in "$singlet_dir" "$triplet_dir"; do
            mkdir -p "$spin_dir"
            cp "$path/INCAR" "$spin_dir/"
            cp "$path/POTCAR" "$spin_dir/"
            cp "$path/KPOINTS" "$spin_dir/"
            cp "$path/job.vasp.pbs" "$spin_dir/"
            cp "$path/CONTCAR" "$spin_dir/POSCAR"

            # Set NUPDOWN according to the spin state
            if [[ $spin_dir == *S ]]; then
                echo "NUPDOWN=0" >> "$spin_dir/INCAR"
            else
                echo "NUPDOWN=2" >> "$spin_dir/INCAR"
            fi
            
            echo "ISYM = 0" >> "$spin_dir/INCAR"

            sed -i "s/#PBS -N .*/#PBS -N ${TM}_$(basename "$spin_dir")/" "$spin_dir/job.vasp.pbs"
            
            # Submit the job
            (cd "$spin_dir" && qsub job.vasp.pbs)
            echo "Job submitted for $spin_dir"
        done
    else
        echo "NELECT for $path is not an even number, skipping singlet and triplet setup."
    fi
done

echo "Singlet and triplet calculations setup is complete."

