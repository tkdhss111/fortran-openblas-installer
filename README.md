# fortran-openblas-installer

Installer for gfortran static/shared library of OpenBLAS with BLAS95 and LAPACK95 interfaces

- OpenBLAS has both BLAS and LAPACK routines
- OpenBLAS is written in C and assembly with optimization

## Install

```
make
```

, or step by step installation:

```
make openblas
make blas95
make lapack95
make install
make test
```

## Tips

- The libraries are to be stored by default in "./installed" directory.
