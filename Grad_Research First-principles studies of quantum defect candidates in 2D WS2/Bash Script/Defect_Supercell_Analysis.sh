#!/bin/bash

TM=$1

if [ -z "$TM" ]; then
    echo "Usage: $0 [Transition Metal Symbol]"
    exit 1
fi

output_file="${TM}/Defect_Supercell.txt"
energy_difference_file="${TM}/Energy_Difference.txt"
sorted_output="${TM}/Defect_Supercell_Sorted.txt"

echo -e "Path\t\t\t\t\tDefect Coordinates\t\t\tTotal Energy (eV)" > "$output_file"
echo -e "Charge State\tPath\t\t\t\tEnergy Difference (eV)" > "$energy_difference_file"

charge_states=("0" "1-" "1+")
sub_dirs=("no.1" "no.2" "no.3")

for state in "${charge_states[@]}"; do
  for sub_dir in "${sub_dirs[@]}"; do
    target_dir="${TM}/${state}/${sub_dir}"
    defect_coords=$(sed -n '24p' "$target_dir/CONTCAR") 
    total_energy=$(grep "TOTEN" "$target_dir/OUTCAR" | tail -1 | awk '{print $5}')

    printf "%-10s\t%-40s\t%-20s\n" "${TM}/${state}/${sub_dir}" "$defect_coords" "$total_energy" >> "$output_file"
  done
done

#Sort without headline
header=$(head -n 1 "$output_file")

( 
  echo "$header" 
  tail -n +2 "$output_file" | sort -k5,5n
) > "$sorted_output"

mv "$sorted_output" "$output_file"

# Get the pristine structure's energy
pristine_energy=$(grep "TOTEN" "pristine/OUTCAR" | tail -1 | awk '{print $5}')

# Select ground states and calculate energy differences
for state in "${charge_states[@]}"; do
    lowest_energy_line=$(grep "/${state}/" "$output_file" | head -1)
    path=$(echo "$lowest_energy_line" | awk '{print $1}')
    energy=$(echo "$lowest_energy_line" | awk '{print $5}')
    energy_diff=$(echo "$energy - $pristine_energy" | bc)
    printf "%-10s\t%-30s\t%-20s\n" "$state" "$path" "$energy_diff" >> "$energy_difference_file"
done

echo "Sorted results have been saved to $output_file"
cat "$output_file"
echo "Energy differences have been saved to $energy_difference_file"
cat "$energy_difference_file"


