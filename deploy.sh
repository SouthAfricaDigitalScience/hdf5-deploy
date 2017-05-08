#!/bin/bash -e
. /etc/profile.d/modules.sh
module add deploy
module add gmp
module add mpfr
module add mpc
module add gcc/${GCC_VERSION}
module add torque/2.5.13-gcc-${GCC_VERSION}
module add  openmpi/${OPENMPI_VERSION}-gcc-${GCC_VERSION}

echo "Starting deploy.sh"
cd ${WORKSPACE}/${NAME}-${VERSION}/build-${BUILD_NUMBER}
make distclean
rm -rf *
FC=`which mpif90` \
CC=`which mpicc` \
CXX=`which mpicxx` \
FFLAGS="-I${OPENMPI_DIR}/include -L${OPENMPI_DIR}/lib" \
CFLAGS="-I${OPENMPI_DIR}/include -L${OPENMPI_DIR}/lib" \
CXXFLAGS="-I${OPENMPI_DIR}/include/ -L${OPENMPI_DIR}/lib" \
H5CXXFLAGS="-I${OPENMPI_DIR}/include -L${OPENMPI_DIR}/lib" \
../configure \
--prefix=${SOFT_DIR}-gcc-${GCC_VERSION}-mpi-${OPENMPI_VERSION} \
--enable-parallel \
--enable-unsupported \
--enable-shared \
make -j2
make install

mkdir -p modules
(
cat <<MODULE_FILE
#%Module1.0
## $NAME modulefile
##
proc ModulesHelp { } {
    puts stderr "       This module does nothing but alert the user"
    puts stderr "       that the [module-info name] module is not available"
}
module add gmp
module add mpfr
module add mpc
module add gcc/${GCC_VERSION}
module add torque/2.5.13-gcc-${GCC_VERSION}
module add openmpi/${OPENMPI_VERSION}-gcc-${GCC_VERSION}

module-whatis   "$NAME $VERSION. Build for GCC ${GCC_VERSION} with OpenMPI ${OPENMPI_VERSION}"
setenv       HDF5_VERSION       $VERSION
setenv       HDF5_DIR           $::env(CVMFS_DIR)/$::env(SITE)/$::env(OS)/$::env(ARCH)/${NAME}/${VERSION}-gcc-${GCC_VERSION}-mpi-${OPENMPI_VERSION}
prepend-path LD_LIBRARY_PATH   $::env(HDF5_DIR)/lib
prepend-path PATH              $::env(HDF5_DIR)/bin
prepend-path HDF5_INCLUDE_DIR   $::env(HDF5_DIR)/include
prepend-path CPATH             $::env(HDF5_DIR)/include
MODULE_FILE
) > modules/${VERSION}-gcc-${GCC_VERSION}-mpi-${OPENMPI_VERSION}

mkdir -p ${LIBRARIES}/${NAME}
cp modules/${VERSION}-gcc-${GCC_VERSION}-mpi-${OPENMPI_VERSION} ${LIBRARIES}/${NAME}

module avail
module add ${NAME}/${VERSION}-gcc-${GCC_VERSION}-mpi-${OPENMPI_VERSION}
cd ${WORKSPACE}

echo "Working directory is $PWD with : "
ls
echo "LD_LIBRARY_PATH is $LD_LIBRARY_PATH"
