# fortran-openblas-installer

Installer for gfortran static/shared library of OpenBLAS with BLAS95 and LAPACK95 interfaces

- OpenBLAS has both BLAS and LAPACK routines
- OpenBLAS is written in C and assembly with optimization

## Install

Static/shared libraries are to be stored by default in "./OpenBLAS95" directory.

```
make
```

# Tips

For Windows installation, GNU makefile and Mingw64 (MSYS2) is used instead of the nmake file stored in C:/Program Files (x86)/Intel/oneAPI/mkl
