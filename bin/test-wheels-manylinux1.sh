#!/usr/bin/env bash

# Caust the script to exit if a single command fails.
set -e

# Show explicitly which commands are currently running.
set -x

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE:-$0}")"; pwd)
WHEEL_DIR=$PWD/.whl

for PYTHON in cp34-cp34m cp35-cp35m cp36-cp36m; do
   MPI4PY_WHEEL=$(find $SCRIPT_DIR/../.whl -type f | grep $PYTHON | grep mpi4py)
   BRAINIAK_WHEEL=$(find $SCRIPT_DIR/../.whl -type f | grep $PYTHON | grep brainiak)

   PIP=/opt/python/${PYTHON}/bin/pip

   $PIP install -q $MPI4PY_WHEEL
   $PIP install -q $BRAINIAK_WHEEL
done
