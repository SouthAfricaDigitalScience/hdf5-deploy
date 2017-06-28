# hdf5-deploy

Build, test and deploy scripts for [HDF5](https://www.hdfgroup.org/) in CODE-RADE.

| Flavour | Status |
|:----: |:-----:|
| MPICH | [![Build Status](https://ci.sagrid.ac.za/buildStatus/icon?job=hdf5-mpich-deploy)](https://ci.sagrid.ac.za/job/hdf5-mpich-deploy)  |
| OpenMPI | [![Build Status](https://ci.sagrid.ac.za/buildStatus/icon?job=hdf5-openmpi-deploy)](https://ci.sagrid.ac.za/job/hdf5-openmpi-deploy) |


# Versions

We build HDF5 in a matrix of targets constructed from HDF5, GCC  and MPI parameters. Two flavours of MPI are used - OpenMPI and MPICH.
We build the following versions of HDF5 :

  * 1.8.15
  * 1.8.16

It is linked against the following combinations of MPI and GCC :

  * **MPI** :
    * OpenMPI :
      * 1.8.1
      * 1.8.8
      * 1.10.2
    * MPICH :
      * 3.2
  * **GCC** :
    * 4.9.4
    * 5.4.0
    * 6.3.0

# Dependencies

HDF5 depends directly on the MPI implementation (OpenMPI or MPICH), which in turn depends on the compiler version.

# Configuration

## MPICH

The following configuration was used for the  MPICH builds :

```
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
```

### OpenMPI

The following configuration was used for the OpenMPI builds  :

```
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
--enable-shared
```

# Citing
