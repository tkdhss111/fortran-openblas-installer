# fortran-openblas-installer

(Work in progress)

Installer for gfortran static/shared library of OpenBLAS with BLAS95 and LAPACK95 interfaces

- OpenBLAS has both BLAS and LAPACK routines
- OpenBLAS is written in C and assembly with optimization

## Install

Static/shared libraries are to be stored by default in "./OpenBLAS95" directory.

```
make
```

To test all test files,

```
make check
```

# Tips

For Windows installation, GNU makefile is used instead of the makefile for nmake stored in C:/Program Files (x86)/Intel/oneAPI/mkl

# ToDo

Fix test_blas95 failure in Windows
