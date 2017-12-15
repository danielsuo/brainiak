#!/usr/bin/env bash

# Caust the script to exit if a single command fails.
set -e

# Show explicitly which commands are currently running.
set -x

# Install dependencies
apt update && apt install -y -q \
   build-essential \
   libgomp1 \
   libmpich-dev \
   mpich \
   git \
   zip \
   unzip

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE:-$0}")"; pwd)
WHEEL_DIR=$SCRIPT_DIR/../.whl
mkdir -p $WHEEL_DIR

# - Use the brainiak source stored in /brainiak via docker run command
# - Use head of mpi4py (we can pick some more suitable tag)
git clone -q https://bitbucket.org/mpi4py/mpi4py /mpi4py
pushd /mpi4py
git checkout 3.0.0
popd

for VERSION in 3.4 3.5 3.6; do
   PYTHON=python$VERSION
   $PYTHON -m pip install -U pip wheel auditwheel

   pushd /mpi4py
   git clean -f -f -x -d -q
   $PYTHON setup.py -q bdist_wheel
   auditwheel repair dist/*.whl
   mv wheelhouse/*.whl $WHEEL_DIR/
   popd

   git clean -f -f -x -d -q -e .whl
   $PYTHON -m pip install -q .
   $PYTHON setup.py -q bdist_wheel
   auditwheel repair dist/*.whl
   mv wheelhouse/*.whl $WHEEL_DIR/
done
