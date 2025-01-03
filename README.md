# fortran-openblas-installer

Installer for gfortran static/shared library of OpenBLAS with BLAS95 and LAPACK95 interfaces

- OpenBLAS has both BLAS and LAPACK routines
- OpenBLAS is written in C and assembly with optimization

## Install in Linux

Static/shared libraries are to be stored by default in "./OpenBLAS95" directory.

```
make
```

To test all test files,

```
make check
```

## Install in Windows

- Install MinGW64 for compilation in advance
- GNU makefile is used instead of the one for nmake stored in C:/Program Files (x86)/Intel/oneAPI/mkl
- Try a few times if installation fails
