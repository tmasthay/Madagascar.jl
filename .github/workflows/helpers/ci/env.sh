#!/bin/bash

# sandbox root
export SANDBOX_ROOT="$HOME/.mad_sandbox"

# julia setup
export JULIA_ENV_PATH="$SANDBOX_ROOT/ci_julia_env"

# source info
export MAD_URL="https://github.com/ahay/src.git"
export MAD_BRANCH_NAME="master"
export MAD_SRC_PATH="$SANDBOX_ROOT/madagascar_src"

# post install info
export MAD_INSTALL_PATH="$SANDBOX_ROOT/madagascar"
export MAD_ENV_PATH="$MAD_INSTALL_PATH/share/madagascar/etc/env.sh"
