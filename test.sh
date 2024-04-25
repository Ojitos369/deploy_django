#!/bin/bash

while [[ "$#" -gt 0 ]]; do
    case $1 in
        --conda) conda="$2"; shift ;;
        *) echo "Unknown parameter passed: $1"; exit 1 ;;
    esac
    shift
done

my_list=("y" "s" "1")
conda_valid=false

for i in ${my_list[@]}; do
    # check if i in conda case insensitive
    if [[ "${conda,,}" == *"${i,,}"* ]]; then
        conda_valid=true
        break
    fi
done

conda=$conda_valid

echo "Conda: $conda"

if [ ! "$conda" == "true" ]; then
    echo "Conda is invalid"
else
    echo "Conda is valid"
fi
