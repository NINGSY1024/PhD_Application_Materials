#!/bin/bash

BASE_DIR="/hpctmp/e1127489/mu" 

# Output file for the results
OUTPUT_FILE="${BASE_DIR}/mu.txt"

# Initialize or clear the output file
: > "${OUTPUT_FILE}"

# Function to extract TM count from POSCAR
get_tm_count() {
    local poscar_file="$1"
    head -7 "${poscar_file}" | tail -1 | awk '{print $1}' # Assuming TM is always first
}

# Variable to store WS2 energy and TM count
#WS2_energy=$(grep "TOTEN" "${BASE_DIR}/WS2/OUTCAR" | tail -1 | awk '{print $5}')
#WS2_tm_count=$(get_tm_count "${BASE_DIR}/WS2/POSCAR")
#WS2_energy_per_formula=$(echo "scale=6; $WS2_energy / $WS2_tm_count" | bc)
WS2_energy_per_formula=-23.667

for compound_dir in ${BASE_DIR}/*; do
    if [ -d "$compound_dir" ]; then  
        compound_name=$(basename "${compound_dir}")

        energy=$(grep "TOTEN" "${compound_dir}/OUTCAR" | tail -1 | awk '{print $5}')
        tm_count=$(get_tm_count "${compound_dir}/POSCAR")
        energy_per_formula=$(echo "scale=6; $energy / $tm_count" | bc)

        # Calculate energy difference with WS2 per formula
        if [[ "${compound_name}" != "WS2" ]]; then
            energy_diff=$(echo "scale=6; $WS2_energy_per_formula - $energy_per_formula" | bc)
        else
            energy_diff="0" 
        fi

        echo "${compound_name} ${energy_per_formula} ${energy_diff}" >> "${OUTPUT_FILE}"
    fi
done

echo "Analysis completed. Results are saved to ${OUTPUT_FILE}."

cat ${OUTPUT_FILE}
