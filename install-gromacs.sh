#! /bin/bash

source /etc/profile.d/modules.sh

## module purge
## module load intel/16.0
## module load gcc/4.8.2
## module load openmpi/1.8.5/intel/any
## module load cudatoolkit/8.0
# module load fftw/3.3.4
# module load Cmake
# module load Fftw/3.3.4

module purge
module load cmake/3.7.2
module load intel/18.0
module load gcc/.5.4.0
module load openmpi/1.8.5/intel/any 
module load cudatoolkit/8.0 # hacked version from /u/sbp/bussi/modules

export CMAKE_PREFIX_PATH=/u/sbp/programs/64/Fftw/3.3.4

#installdir=/u/sbp/bussi/modules/Gromacs5.0.4c/sse
#installdir=/u/sbp/bussi/modules/Gromacs2016.5
installdir=/u/sbp/bussi/modules/2018/Gromacs2016.5
installdir=/u/sbp/bussi/modules/2018/Gromacs2018.4
umask 022

mkdir build-sp
cd build-sp

cmake .. \
    -DCMAKE_C_COMPILER:FILEPATH=$(which mpicc) \
    -DCMAKE_CXX_COMPILER:FILEPATH=$(which mpic++) \
    -DCMAKE_INSTALL_PREFIX:STRING=$installdir \
    -DGMX_MPI=ON

make -j 18

make install
cd ../

mkdir build-dp
cd build-dp

cmake .. \
    -DCMAKE_C_COMPILER=$(which mpicc) \
    -DCMAKE_CXX_COMPILER:FILEPATH=$(which mpic++) \
    -DCMAKE_INSTALL_PREFIX:STRING=$installdir \
    -DGMX_DOUBLE:BOOL=ON \
    -DGMX_GPU:BOOL=OFF \
    -DGMX_MPI:BOOL=ON 

make -j 12 
make install

