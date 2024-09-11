#!/bin/bash

tms=("Zr" "Nb" "Ru" "Rh" "Pd" "Ag" "Cd" "Hf"  "Ta" "Re" "Os" "Ir" "Pt" "Au" "Hg" ) 

charge_states=("1-" "0" "1+")

for tm in "${tms[@]}"; do
  for state in "${charge_states[@]}"; do
    path=$(awk -v state="$state" '$1 == state {print $2}' "${tm}/Energy_Difference.txt") 
    cp "${path}/CONTCAR" POS/${tm}${state}.vasp
  done
done

ls POS

