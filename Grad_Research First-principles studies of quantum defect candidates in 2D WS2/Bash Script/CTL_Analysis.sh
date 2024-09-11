#!/bin/bash

input_file="Ef.dat"
output_file="CTL.dat"

echo -e "TM\tTM(+1|0)\tTM(0|-1)" > "$output_file"

tail -n +2 "$input_file" | cut -f1 | sed 's/_.*//' | uniq | while read tm; do
    awk -v tm="$tm" -F'\t' '
    BEGIN {E_1plus=0; E_0=0; E_1minus=0;}
    $1 ~ tm"_1\\+" {E_1plus=$2+$3+$4}
    $1 ~ tm"_0" {E_0=$2+$3+$4}
    $1 ~ tm"_1-" {E_1minus=$2+$3+$4}
    END {
        TM_plus1_0=E_0-E_1plus;
        TM_0_minus1=E_1minus-E_0;
        printf "%s\t%.4f\t%.4f\n", tm, TM_plus1_0, TM_0_minus1
    }' "$input_file" >> "$output_file"
done

cat $output_file

