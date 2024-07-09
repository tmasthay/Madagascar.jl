#!/bin/bash
SCRIPT_DIR=$(dirname $(realpath "${BASH_SOURCE[0]}"))
source $SCRIPT_DIR/env.sh

mkdir -p $MAD_SRC_PATH
cd $MAD_SRC_PATH

# check if path exists, if it does, ignore
#     In github runner, this will not be the case.
#     This is for fast local testing for debugging purposes
if [ -d "$MAD_SRC_PATH/src" ]; then
    echo "Madagascar source already exists in path $MAD_SRC_PATH. Exiting..."
    exit 0
else
    git clone --single-branch --branch $MAD_BRANCH_NAME $MAD_URL
    cd src
    ./configure --prefix=$MAD_INSTALL_PATH
    make -j$(nproc)
    make install
fi