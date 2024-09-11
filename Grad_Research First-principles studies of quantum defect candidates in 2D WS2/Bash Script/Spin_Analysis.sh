#!/bin/bash

TM=$1

if [ -z "$TM" ]; then
    echo "Usage: $0 [Transition Metal Symbol]"
    exit 1
fi

mkdir -p "${TM}"
result_file="${TM}/Spin.txt"

echo -e "Path\tTotal Energy (eV)" > "${result_file}"

charge_states=("0" "1-" "1+")

for charge_state in "${charge_states[@]}"; do
    lowest_energy=999999
    ground_state=""
    for spin_state in "S" "T"; do
        path="${TM}/${charge_state}${spin_state}"
        if [[ -d "$path" ]]; then
            total_energy=$(grep "TOTEN" "$path/OUTCAR" | tail -1 | awk '{print $5}')
            echo -e "${path}\t${total_energy}" >> "${result_file}"

            if (( $(echo "$total_energy < $lowest_energy" | bc -l) )); then
                lowest_energy="$total_energy"
                ground_state="${charge_state}${spin_state}"
            fi
        fi
    done

    if [[ ! -z "$ground_state" ]]; then
        echo "Ground state for charge ${charge_state}: ${ground_state}" >> "${result_file}"
    fi
done

cat ${result_file}
