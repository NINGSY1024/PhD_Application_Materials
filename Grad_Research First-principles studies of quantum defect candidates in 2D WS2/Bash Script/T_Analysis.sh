#!/bin/bash

output_file="delta_E.dat"

echo -e "TM_Spin_State\tDelta_E(eV)" > "$output_file"

TMs=(Co Nb Ni  Zn Zr Tc Mn Fe Cu)

for TM in "${TMs[@]}"; do
    if [[ -f "${TM}/Spin.txt" ]]; then
        spin_state=$(grep "G.*T" "${TM}/Spin.txt" | awk '{print $5}' | tr -d ':')

        if [[ ! -z "$spin_state" ]]; then
            singlet=$(grep "${TM}/${spin_state}S" "${TM}/Spin.txt" | awk '{printf "%.3f", $2}')
            triplet=$(grep "${TM}/${spin_state}T" "${TM}/Spin.txt" | awk '{printf "%.3f", $2}')

            if [[ ! -z "$singlet" && ! -z "$triplet" ]]; then
                delta_E=$(echo "$singlet - $triplet" | bc)
                
                echo -e "${TM}_${spin_state}\t${delta_E}" >> "$output_file"
            fi
        fi
    fi
done

cat $output_file
