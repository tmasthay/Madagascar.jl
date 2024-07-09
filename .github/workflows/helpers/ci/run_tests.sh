#!/bin/bash
SCRIPT_DIR=$(dirname $(realpath "${BASH_SOURCE[0]}"))
source $SCRIPT_DIR/env.sh

mkdir -p $JULIA_ENV_PATH
source $MAD_ENV_PATH

julia --project=$ENV_PATH <<EOF
using Pkg
Pkg.develop(path=pwd())
Pkg.instantiate()
Pkg.test("Madagascar")
EOF