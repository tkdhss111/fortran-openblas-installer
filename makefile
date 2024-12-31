LIB77        :=./OpenBLAS/install_tmp/lib/libopenblas.a
LIB95_BLAS   :=./interfaces/blas95/lib95/lib/libmkl_blas95_lp64.a
LIB95_LAPACK :=./interfaces/lapack95/lib95/lib/libmkl_lapack95_lp64.a
DIR_ONEAPI   :=/opt/intel/oneapi
DIR_INSTALL  :=./installed
MAKE_RULE    :=./OpenBLAS/Makefile.rule

all: openblas blas95 lapack95 install test

openblas: $(LIB77)
blas95  : $(LIB95_BLAS)
lapack95: $(LIB95_LAPACK)
test    : test_openblas test_blas95 test_lapack95

$(MAKE_RULE):
	git clone https://github.com/OpenMathLib/OpenBLAS.git

config: $(MAKE_RULE)
	sed -i '/# FC = gfortran/s/.*/FC = gfortran/'                         $(MAKE_RULE)
	sed -i '/# NO_CBLAS = 1/s/.*/NO_CBLAS = 1/'                           $(MAKE_RULE)
	sed -i '/# NO_LAPACKE = 1/s/.*/NO_LAPACKE = 1/'                       $(MAKE_RULE)
	sed -i '/# COMMON_OPT = -O2/s/.*/COMMON_OPT = -O3/'                   $(MAKE_RULE)
	sed -i '/# FCOMMON_OPT = -frecursive/s/.*/FCOMMON_OPT = -frecursive/' $(MAKE_RULE)
	#sed -i '/# BUILD_SINGLE = 1/s/.*/BUILD_SINGLE = 1/'                   $(MAKE_RULE)
	#sed -i '/# BUILD_DOUBLE = 1/s/.*/BUILD_DOUBLE = 1/'                   $(MAKE_RULE)

$(LIB77): config
	cd ./OpenBLAS ; \
	mkdir -p install_tmp ; \
	make -j && make PREFIX="install_tmp" install

$(LIB95_BLAS):
	mkdir -p interfaces
	cp -r $(DIR_ONEAPI)/mkl/latest/share/mkl/interfaces/blas95 ./interfaces/blas95
	make -j libintel64 INSTALL_DIR=lib95 FC=gfortran --directory=./interfaces/blas95

$(LIB95_LAPACK):
	mkdir -p interfaces
	cp -r $(DIR_ONEAPI)/mkl/latest/share/mkl/interfaces/lapack95 ./interfaces/lapack95
	make -j libintel64 INSTALL_DIR=lib95 FC=gfortran --directory=./interfaces/lapack95

.PHONY: install 
install:
	rm -rf $(DIR_INSTALL)
	cp -r ./OpenBLAS/install_tmp $(DIR_INSTALL)
	mkdir -p $(DIR_INSTALL)/mod
	cp $(LIB95_BLAS)   $(DIR_INSTALL)/lib/
	cp $(LIB95_LAPACK) $(DIR_INSTALL)/lib/
	cp ./interfaces/blas95/lib95/include/mkl/intel64/lp64/f95_precision.mod $(DIR_INSTALL)/mod/
	cp ./interfaces/blas95/lib95/include/mkl/intel64/lp64/blas95.mod        $(DIR_INSTALL)/mod/
	cp ./interfaces/lapack95/lib95/include/mkl/intel64/lp64/lapack95.mod    $(DIR_INSTALL)/mod/

.PHONY: test_openblas
test_openblas:
	gfortran -o ./test/test_openblas \
		./test/test_openblas.f90 $(LIB77) && \
		./test/test_openblas

.PHONY: test_blas95
test_blas95:
	gfortran -J$(DIR_INSTALL)/mod -o ./test/test_blas95 \
		./test/test_blas95.f90 $(LIB95_BLAS) $(LIB77) && \
		./test/test_blas95

.PHONY: test_lapack95
test_lapack95:
	gfortran -J$(DIR_INSTALL)/mod -o ./test/test_lapack95 \
		./test/test_lapack95.f90 $(LIB95_LAPACK) $(LIB77) && \
		./test/test_lapack95

clean:
	rm -r OpenBLAS
	rm -r interfaces
	rm -r $(DIR_INSTALL)
	rm ./test/test_openblas
	rm ./test/test_blas95
	rm ./test/test_lapack95

# ToDo: combining blas95 and lapack95 interfaces into a single library (not working, maybe difficult)
#
#LIB_95IFS :=./lib95/lib95interfaces.a
#
#.PHONY: lib95
#lib95: $(LIB95_BLAS) $(LIB95_LAPACK)
#	mkdir -p lib95 ; \
#	ar x $(LIB95_BLAS)   --output=./lib95 && \
#	ar x $(LIB95_LAPACK) --output=./lib95 && \
#	ar cr $(LIB_95IFS) $(wildcard ./lib95/*.o) && \
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

