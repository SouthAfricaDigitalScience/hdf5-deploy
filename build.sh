#!/bin/bash -e
SOURCE_FILE=$NAME-$VERSION.tar.gz

module load ci

echo "REPO_DIR is "
echo $REPO_DIR
echo "SRC_DIR is "
echo $SRC_DIR
echo "WORKSPACE is "
echo $WORKSPACE
echo "SOFT_DIR is"
echo $SOFT_DIR

mkdir -p $WORKSPACE
mkdir -p $SRC_DIR
mkdir -p $SOFT_DIR

#  Download the source file

if [[ ! -e $SRC_DIR/$SOURCE_FILE ]] ; then
  echo "seems like this is the first build - let's get the source"
  mkdir -p $SRC_DIR
  wget ftp://ftp.hdfgroup.org/HDF5/current/src/$SOURCE_FILE -O $SRC_DIR/$SOURCE_FILE
else
  echo "continuing from previous builds, using source at " $SRC_DIR/$SOURCE_FILE
fi
echo "Unpacking the source code tarball at $SRC_DIR/$SOURCE_FILE"
tar -xzf $SRC_DIR/$SOURCE_FILE -C $WORKSPACE
cd $WORKSPACE/$NAME-$VERSION
./configure --prefix=$SOFT_DIR --enable-parallel   --enable-cxx --enable-fortran --enable-unsupported --enable-share
make
