#!/bin/bash -e
. /etc/profile.d/modules.sh
module load ci
echo ""
module add gmp
module add mpfr
module add mpc
module add zlib
module add bzip2
module add gcc/${GCC_VERSION}
module add openmpi/${OPENMPI_VERSION}-gcc-${GCC_VERSION}
cd ${WORKSPACE}/${NAME}-${VERSION}/build-${BUILD_NUMBER}
# disabling make check since this puts a huge load on the machines
# see http://stackoverflow.com/questions/23734729/open-mpi-virtual-timer-expired
#make check
echo $?

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

module add gcc/${GCC_VERSION}
module add openmpi/${OPENMPI_VERSION}-gcc-${GCC_VERSION}

module-whatis   "$NAME $VERSION."
setenv       HDF5_VERSION       $VERSION
setenv       HDF5_DIR           /data/ci-build/$::env(SITE)/$::env(OS)/$::env(ARCH)/${NAME}/${VERSION}-gcc-${GCC_VERSION}-mpi-${OPENMPI_VERSION}
prepend-path LD_LIBRARY_PATH   $::env(HDF5_DIR)/lib
prepend-path PATH              $::env(HDF5_DIR)/bin
prepend-path HDF5_INCLUDE_DIR   $::env(HDF5_DIR)/include
prepend-path CPATH             $::env(HDF5_DIR)/include
MODULE_FILE
) > modules/${VERSION}-gcc-${GCC_VERSION}-mpi-${OPENMPI_VERSION}

mkdir -p ${LIBRARIES_MODULES}/${NAME}
cp modules/${VERSION}-gcc-${GCC_VERSION}-mpi-${OPENMPI_VERSION} ${LIBRARIES_MODULES}/${NAME}

module avail
module add ${NAME}/${VERSION}-gcc-${GCC_VERSION}-mpi-${OPENMPI_VERSION}
cd ${WORKSPACE}

echo "Working directory is $PWD with : "
ls
echo "LD_LIBRARY_PATH is $LD_LIBRARY_PATH"
