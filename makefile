LIB77        :=libopenblas.a
LIB95_BLAS   :=libblas95.a
LIB95_LAPACK :=liblapack95.a
MAKE_RULE    :=./OpenBLAS/Makefile.rule
MKLROOT      :=/opt/intel/oneapi/mkl
ifeq ($(OS),Windows_NT)
	INSTALL_DIR :=C:/Users/tkdhs/0_tkd/1_hss/2_tools/fortran-openblas-installer/OpenBLAS95
else
	INSTALL_DIR :=/home/hss/0_tkd/1_hss/2_tools/fortran-openblas-installer/OpenBLAS95
endif

all: download openblas test_openblas cp_mkl blas95 test_blas95 lapack95 test_lapack95 check

openblas: $(INSTALL_DIR)/lib/$(LIB77)
blas95  : $(INSTALL_DIR)/lib/$(LIB95_BLAS)
lapack95: $(INSTALL_DIR)/lib/$(LIB95_LAPACK)
check   : test_openblas test_blas95 test_lapack95 test_blas95_shared test_lapack95_shared

#
# OpenBLAS
#

download: download_openblas download_mkl

download_openblas:
	git clone https://github.com/OpenMathLib/OpenBLAS.git

download_mkl:
	mkdir -p ./mkl/latest/include
	mkdir -p ./mkl/latest/share/mkl/interfaces
	cp    $(MKLROOT)/latest/include/mkl_blas.f90          ./mkl/latest/include/mkl_blas.f90
	cp    $(MKLROOT)/latest/include/mkl_lapack.f90        ./mkl/latest/include/mkl_lapack.f90
	cp -r $(MKLROOT)/latest/share/mkl/interfaces/blas95   ./mkl/latest/share/mkl/interfaces/blas95
	cp -r $(MKLROOT)/latest/share/mkl/interfaces/lapack95 ./mkl/latest/share/mkl/interfaces/lapack95

config:
	sed -i '/# FC = gfortran/s/.*/FC = gfortran/'                         $(MAKE_RULE)
	sed -i '/# NO_CBLAS = 1/s/.*/NO_CBLAS = 1/'                           $(MAKE_RULE)
	sed -i '/# NO_LAPACKE = 1/s/.*/NO_LAPACKE = 1/'                       $(MAKE_RULE)
	sed -i '/# FCOMMON_OPT = -frecursive/s/.*/FCOMMON_OPT = -frecursive/' $(MAKE_RULE)
	#sed -i '/# BUILD_SINGLE = 1/s/.*/BUILD_SINGLE = 1/'                   $(MAKE_RULE) error may occur
	#sed -i '/# BUILD_DOUBLE = 1/s/.*/BUILD_DOUBLE = 1/'                   $(MAKE_RULE) error may occur

$(INSTALL_DIR)/lib/$(LIB77): config
	make --directory=./OpenBLAS
	mkdir -p $(INSTALL_DIR)
	make PREFIX=$(INSTALL_DIR) install --directory=./OpenBLAS

.PHONY: test_openblas
test_openblas:
	gfortran -o ./test/test_openblas \
		./test/test_openblas.f90 $(INSTALL_DIR)/lib/$(LIB77) && \
		./test/test_openblas

#
# BLAS95 LAPACK95
#

$(INSTALL_DIR)/lib/$(LIB95_BLAS):
	mkdir -p $(INSTALL_DIR)/include
	mkdir -p $(INSTALL_DIR)/lib
	cd ./mkl/latest/share/mkl/interfaces/blas95 && \
	make libintel64 FC=gfortran INSTALL_DIR=lib95 MKLROOT=../../../..
	cp ./mkl/latest/share/mkl/interfaces/blas95/lib95/include/mkl/intel64/lp64/f95_precision.mod $(INSTALL_DIR)/include/f95_precision.mod
	cp ./mkl/latest/share/mkl/interfaces/blas95/lib95/include/mkl/intel64/lp64/blas95.mod        $(INSTALL_DIR)/include/blas95.mod
	cp ./mkl/latest/share/mkl/interfaces/blas95/lib95/lib/libmkl_blas95_lp64.a                   $(INSTALL_DIR)/lib/$(LIB95_BLAS)

$(INSTALL_DIR)/lib/$(LIB95_LAPACK):
	mkdir -p $(INSTALL_DIR)/include
	mkdir -p $(INSTALL_DIR)/lib
	cd ./mkl/latest/share/mkl/interfaces/lapack95 && \
	make libintel64 FC=gfortran INSTALL_DIR=lib95 MKLROOT=../../../..
	cp ./mkl/latest/share/mkl/interfaces/lapack95/lib95/include/mkl/intel64/lp64/f95_precision.mod $(INSTALL_DIR)/include/f95_precision.mod
	cp ./mkl/latest/share/mkl/interfaces/lapack95/lib95/include/mkl/intel64/lp64/lapack95.mod      $(INSTALL_DIR)/include/lapack95.mod
	cp ./mkl/latest/share/mkl/interfaces/lapack95/lib95/lib/libmkl_lapack95_lp64.a                 $(INSTALL_DIR)/lib/$(LIB95_LAPACK)

#
# Link with OpenBLAS static library
#
.PHONY: test_blas95
test_blas95:
	gfortran -I$(INSTALL_DIR)/include -o ./test/test_blas95 \
		./test/test_blas95.f90 $(INSTALL_DIR)/lib/$(LIB95_BLAS) $(INSTALL_DIR)/lib/$(LIB77) && \
		./test/test_blas95

.PHONY: test_lapack95
test_lapack95:
	gfortran -I$(INSTALL_DIR)/include -o ./test/test_lapack95 \
		./test/test_lapack95.f90 $(INSTALL_DIR)/lib/$(LIB95_LAPACK) $(INSTALL_DIR)/lib/$(LIB77) && \
		./test/test_lapack95

#
# Link with OpenBLAS shared library
#
.PHONY: test_blas95_shared
test_blas95_shared:
	gfortran -I$(INSTALL_DIR)/include -L$(INSTALL_DIR)/lib -o ./test/test_blas95_shared \
		./test/test_blas95.f90 $(INSTALL_DIR)/lib/$(LIB95_BLAS) -lopenblas -Wl,-rpath,$(INSTALL_DIR)/lib && \
		./test/test_blas95_shared && \
		ldd ./test/test_blas95_shared 

.PHONY: test_lapack95_shared
test_lapack95_shared:
	gfortran -I$(INSTALL_DIR)/include -L$(INSTALL_DIR)/lib -o ./test/test_lapack95_shared \
		./test/test_lapack95.f90 $(INSTALL_DIR)/lib/$(LIB95_LAPACK) -lopenblas -Wl,-rpath,$(INSTALL_DIR)/lib && \
		./test/test_lapack95_shared && \
		ldd ./test/test_lapack95_shared 

clean:
	rm -rf mkl
	rm -f ./test/test_openblas
	rm -f ./test/test_openblas.exe
	rm -f ./test/test_blas95
	rm -f ./test/test_blas95.exe
	rm -f ./test/test_blas95_shared
	rm -f ./test/test_blas95_shared.exe
	rm -f ./test/test_lapack95
	rm -f ./test/test_lapack95.exe
	rm -f ./test/test_lapack95_shared
	rm -f ./test/test_lapack95_shared.exe

distclean: clean
	rm -rf OpenBLAS
	rm -rf OpenBLAS95
	rm ./test/*.exe

# ToDo: combining blas95 and lapack95 interfaces into a single library (not working, maybe difficult)
#
#LIB_95IFS :=./lib95/lib95interfaces.a
#
#.PHONY: lib95
#lib95: $(LIB95_BLAS) $(LIB95_LAPACK)
#	mkdir -p lib95 ; \
#	ar x $(LIB95_BLAS)   --output=./lib95 && \
#	ar x $(LIB95_LAPACK) --output=./lib95 && \
#	ar rcs $(LIB_95IFS) $(wildcard ./lib95/*.o) && \
#	ranlib $(LIB_95IFS) && \
#	rm ./lib95/*.o
#
#.PHONY: test_lib95_blas
#test_lib95_blas:
#	gfortran -I./interfaces/blas95/lib95/include/mkl/intel64/lp64 -o ./test/test_lib95_blas \
#		./test/test_blas95.f90 $(LIB_95IFS) $(LIB77) && \
#		./test/test_lib95_blas
#
#.PHONY: test_lib95_lapack
#test_lib95_lapack:
#	gfortran -I./interfaces/lapack95/lib95/include/mkl/intel64/lp64 -o ./test/test_lib95_lapack \
#		./test/test_lapack95.f90 $(LIB_95IFS) $(LIB77) && \
#		./test/test_lib95_lapack

