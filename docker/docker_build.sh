#!/bin/bash

container_list=("kraken2" "mash" "pythonenv" "krona")

for item in ${container_list[@]}; do
    docker build -f Dockerfile.autoDatabase_${item} -t autodatabase${item} .
done
