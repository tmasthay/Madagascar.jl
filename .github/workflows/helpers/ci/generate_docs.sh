#!/bin/bash
SCRIPT_PATH=$(dirname $(realpath "${BASH_SOURCE[0]}"))
source $SCRIPT_PATH/env.sh
source $MAD_ENV_PATH

echo "RSFROOT=$RSFROOT"
julia --project=docs -e 'using Pkg; Pkg.develop(path=pwd()); Pkg.instantiate()'
julia --project=docs docs/make.jl