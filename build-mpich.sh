#!/bin/bash -e
. /etc/profile.d/modules.sh

SOURCE_FILE=${NAME}-${VERSION}.tar.gz

module load ci
module add gcc/${GCC_VERSION}
module add mpich/3.2-gcc-${GCC_VERSION}
#module add cmake
module list
echo "checking whether we can compile mpi programs with"
which mpif90

mpif90 sample-mpio.f90 -o f.out
mpiexec -np 8 $PWD/f.out

echo "REPO_DIR is "
echo $REPO_DIR
echo "SRC_DIR is "
echo $SRC_DIR
echo "WORKSPACE is "
echo $WORKSPACE
echo "SOFT_DIR is"
echo $SOFT_DIR

mkdir -p ${WORKSPACE}
mkdir -p ${SRC_DIR}
mkdir -p ${SOFT_DIR}

#  Download the source file

if [ ! -e ${SRC_DIR}/${SOURCE_FILE}.lock ] && [ ! -s ${SRC_DIR}/${SOURCE_FILE} ] ; then
  touch  ${SRC_DIR}/${SOURCE_FILE}.lock
  echo "seems like this is the first build - let's get the source"
  wget ftp://ftp.hdfgroup.org/HDF5/releases/${NAME}-${VERSION}/src/$SOURCE_FILE -O ${SRC_DIR}/${SOURCE_FILE}
  echo "releasing lock"
  rm -v ${SRC_DIR}/${SOURCE_FILE}.lock
elif [ -e ${SRC_DIR}/${SOURCE_FILE}.lock ] ; then
  # Someone else has the file, wait till it's released
  while [ -e ${SRC_DIR}/${SOURCE_FILE}.lock ] ; do
    echo " There seems to be a download currently under way, will check again in 5 sec"
    sleep 5
  done
else
  echo "continuing from previous builds, using source at " ${SRC_DIR}/${SOURCE_FILE}
fi
echo "Unpacking the source code tarball at ${SRC_DIR}/${SOURCE_FILE}"
tar -xz --keep-newer-files -f ${SRC_DIR}/${SOURCE_FILE} -C ${WORKSPACE}
cd ${WORKSPACE}/${NAME}-${VERSION}
mkdir -p build-${BUILD_NUMBER}
FC=`which mpif90`
if [ -z $FC ] ; then
  echo "Couldn't find an MPIF90 compiler"
  echo "bailing out"
  exit 1;
fi
cd build-${BUILD_NUMBER}
FC=`which mpif90` \
CC=`which mpicc` \
CXX=`which mpicxx` \
FFLAGS="-I${MPICH_DIR}/include -L${MPICH_DIR}/lib" \
CFLAGS="-I${MPICH_DIR}/include -L${MPICH_DIR}/lib" \
CXXFLAGS="-I${MPICH_DIR}/include/ -L${MPICH_DIR}/lib" \
H5CXXFLAGS="-I${MPICH_DIR}/include -L${MPICH_DIR}/lib" \
../configure \
--prefix=${SOFT_DIR}-gcc-${GCC_VERSION}-mpich \
--enable-parallel \
--enable-unsupported \
--enable-shared
make
#cmake -G"Unix Makefiles" -DBUILD_SHARED_LIBS:BOOL=TRUE -DHDF5_BUILD_CPP_LIB:BOOL=FALSE -DHDF5_BUILD_FORTRAN:BOOL=TRUE -DHDF5_ENABLE_PARALLEL:BOOL=TRUE -DCMAKE_INSTALL_PREFIX:PATH=$SOFT_DIR
