#!/bin/bash

container_list=("kraken2" "mash" "pythonenv" "krona")
software_tag="autoDatabase"

for item in ${container_list[@]}; do
    sudo singularity build ${software_tag}_${item}.sif Singularity.${software_tag}_${item}
done
