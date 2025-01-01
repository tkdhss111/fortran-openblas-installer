# fortran-openblas-installer

Installer for gfortran static/shared library of OpenBLAS with BLAS95 and LAPACK95 interfaces

- OpenBLAS has both BLAS and LAPACK routines
- OpenBLAS is written in C and assembly with optimization

## Install

Static/shared libraries are to be stored by default in "/opt/OpenBLAS95" directory.

```
make openblas
make blas95
make lapack95
sudo make install
make test
```
