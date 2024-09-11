#!/bin/bash

# Define the output file
output_file="Ef.dat"

# Header for the output file
echo -e "TM_Charge\tRaw_Ef(eV)\tMu(eV)\tCorr(eV)" > "$output_file"

# List of TMs
tms=("Zr" "Nb" "Ru" "Rh" "Pd" "Ag" "Cd" "Hf"  "Ta" "Re" "Os" "Ir" "Pt" "Au" "Hg" ) 

# Charge states to consider
charge_states=("1-" "0" "1+")

# Loop through each TM
for tm in "${tms[@]}"; do
  # Get mu value
  mu=$(grep "$tm" mu/mu.txt | awk '{printf "%.3f\n", $3}')
  
  # Loop through each charge state
  for state in "${charge_states[@]}"; do
    # Column 1: TM and charge state
    tm_charge="${tm}_${state}"
    
    # Column 2: Raw Ef
    if [ -f "${tm}/Energy_Difference.txt" ]; then
      raw_ef=$(grep "^$state" "${tm}/Energy_Difference.txt" | awk '{printf "%.3f\n", $3}')
    else
      raw_ef="N/A"
    fi
    
    # Column 4: Corr
    if [ "$state" == "0" ]; then
      corr="0.000" # Correction set to 0 for charge state 0
    else
      if [ -f "${tm}/${state}corr/ALIGNED.txt" ]; then
        corr=$(grep energy "${tm}/${state}corr/ALIGNED.txt" | tail -1 | awk '{printf "%.3f\n", $6}')
      else
        corr="N/A"
      fi
    fi

    # Write to output file
    echo -e "${tm_charge}\t${raw_ef}\t${mu}\t${corr}" >> "$output_file"

  done
done

cat $output_file

