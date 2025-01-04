# fortran-openblas-installer

Installer for gfortran static/shared library of OpenBLAS with BLAS95 and LAPACK95 interfaces

- OpenBLAS has both BLAS and LAPACK routines
- OpenBLAS is written in C and assembly with optimization

## Install in Linux

Static/shared libraries are to be stored in INSTALL_DIR directory in makefile.
Replace it with full path.

```
make
```

To test all test files,

```
make check
```

## Install in Windows

- Install MSYS2/MinGW64 for compilation in advance
- GNU makefile is used instead of nmake makefile stored in C:/Program Files (x86)/Intel/oneAPI/mkl
- Try a few times if installation fails
