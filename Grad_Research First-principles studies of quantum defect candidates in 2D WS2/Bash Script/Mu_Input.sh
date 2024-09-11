#! /bin/bash

BASE_DIR="/hpctmp/e1127489" 

TEMPLATE_JOB_FILE="${BASE_DIR}/template/job.vasp.pbs"


for compound_dir in ${BASE_DIR}/mu/*; do
    # Check if it's a directory and contains "MPRelaxSet"
    if [[ -d "${compound_dir}" && "${compound_dir}" == *"MPRelaxSet" ]]; then
        # Get the basename and remove " MPRelaxSet"
        compound_name=$(basename "${compound_dir}")
        compound_name=${compound_name%" MPRelaxSet"} 
        # New directory path without "MPRelaxSet"
        new_dir_name="${BASE_DIR}/mu/${compound_name}"

        echo "Renaming ${compound_dir} to ${new_dir_name}"
        
        mv "${compound_dir}" "${new_dir_name}"

        echo "Processing ${compound_name}"

        cp "${TEMPLATE_JOB_FILE}" "${new_dir_name}/job.vasp.pbs"

        sed -i "s/-N 1-no.1/-N ${compound_name}/" "${new_dir_name}/job.vasp.pbs"

        #rm -f "${new_dir_name}/POTCAR.spec"

        #(cd "${new_dir_name}" && vaspkit -task 103)

        # Submit the job
        (cd "${new_dir_name}" && qsub "${new_dir_name}/job.vasp.pbs")
    fi
done

