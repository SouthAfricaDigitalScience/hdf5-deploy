#!/bin/bash -e
. /etc/profile.d/modules.sh
module add deploy
module add gmp
module add mpfr
module add mpc
module add gcc/${GCC_VERSION}
module add zlib
module add torque/2.5.13-gcc-${GCC_VERSION}
module add  mpich/3.2-gcc-${GCC_VERSION}

echo "Starting deploy.sh"
cd ${WORKSPACE}/${NAME}-${VERSION}/build-${BUILD_NUMBER}
make distclean
rm -rf *
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
--enable-shared \
--with-zlib=${ZLIB_DIR}
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
module add zlib
module add torque/2.5.13-gcc-${GCC_VERSION}
module add mpich/3.2-gcc-${GCC_VERSION}

module-whatis   "$NAME $VERSION. Build for GCC ${GCC_VERSION} with OpenMPI ${MPICH_VERSION}"
setenv       HDF5_VERSION       $VERSION
setenv       HDF5_DIR           $::env(CVMFS_DIR)/$::env(SITE)/$::env(OS)/$::env(ARCH)/${NAME}/${VERSION}-gcc-${GCC_VERSION}-mpich
prepend-path LD_LIBRARY_PATH   $::env(HDF5_DIR)/lib
prepend-path PATH              $::env(HDF5_DIR)/bin
prepend-path HDF5_INCLUDE_DIR   $::env(HDF5_DIR)/include
prepend-path CPATH             $::env(HDF5_DIR)/include
MODULE_FILE
) > modules/${VERSION}-gcc-${GCC_VERSION}-mpich

mkdir -p ${LIBRARIES_MODULES}/${NAME}
cp modules/${VERSION}-gcc-${GCC_VERSION}-mpich ${LIBRARIES_MODULES}/${NAME}

module avail
module add ${NAME}/${VERSION}-gcc-${GCC_VERSION}-mpich
cd ${WORKSPACE}

echo "Working directory is $PWD with : "
ls
echo "LD_LIBRARY_PATH is $LD_LIBRARY_PATH"