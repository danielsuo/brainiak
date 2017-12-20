#!/usr/bin/env bash

# Cause the script to exit if a single command fails.
set -e

# Show explicitly which commands are currently running.
set -x

git clone -q https://bitbucket.org/mpi4py/mpi4py
pushd mpi4py
git checkout 3.0.0
popd

for VERSION in $VERSIONS
do
  MAJOR=${VERSION%.*}
  # Replicate readlink -f
  PYTHON_DIR=$(dirname $(realpath $(which python$MAJOR)))
  PYTHON=$PYTHON_DIR/python$MAJOR
  DELOCATE=$(dirname $PYTHON)/delocate-wheel

  git clean -f -f -x -d -q -e dist -e mpi4py

  # Use virtual environments because we want to install later
  pushd ..
  $PYTHON -m venv venv
  source venv/bin/activate
  popd

  pushd mpi4py
    git clean -f -f -x -d -q
    $PYTHON setup.py -q bdist_wheel
    $DELOCATE dist/*.whl
  popd
  mv mpi4py/dist/*.whl dist/

  $PYTHON -m pip install .
  $PYTHON setup.py bdist_wheel
  $DELOCATE dist/*.whl

  # Build source distribution
  if [ $MAJOR == '3.4' ]
  then
     $PYTHON setup.py sdist
  fi

  deactivate
  rm -rf ../venv
done

rm -rf mpi4py
