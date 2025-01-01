LIB77        :=./OpenBLAS/install_tmp/lib/libopenblas.a
LIB95_BLAS   :=./interfaces/blas95/lib95/lib/libmkl_blas95_lp64.a
LIB95_LAPACK :=./interfaces/lapack95/lib95/lib/libmkl_lapack95_lp64.a
DIR_ONEAPI   :=/opt/intel/oneapi
#DIR_ONEAPI   :="C:/Program Files (x86)/Intel/oneAPI"
DIR_INSTALL  :=./installed
MAKE_RULE    :=./OpenBLAS/Makefile.rule

all: openblas blas95 lapack95 install test

openblas: $(LIB77)
blas95  : $(LIB95_BLAS)
lapack95: $(LIB95_LAPACK)
test    : test_openblas test_blas95 test_lapack95 test_blas95_shared test_lapack95_shared

$(MAKE_RULE):
	git clone https://github.com/OpenMathLib/OpenBLAS.git

config: $(MAKE_RULE)
	sed -i '/# FC = gfortran/s/.*/FC = gfortran/'                         $(MAKE_RULE)
	sed -i '/# NO_CBLAS = 1/s/.*/NO_CBLAS = 1/'                           $(MAKE_RULE)
	sed -i '/# NO_LAPACKE = 1/s/.*/NO_LAPACKE = 1/'                       $(MAKE_RULE)
	sed -i '/# FCOMMON_OPT = -frecursive/s/.*/FCOMMON_OPT = -frecursive/' $(MAKE_RULE)
	#sed -i '/# BUILD_SINGLE = 1/s/.*/BUILD_SINGLE = 1/'                   $(MAKE_RULE) error will occur
	#sed -i '/# BUILD_DOUBLE = 1/s/.*/BUILD_DOUBLE = 1/'                   $(MAKE_RULE) error will occur

$(LIB77): config
	cd ./OpenBLAS ; \
	mkdir -p install_tmp ; \
	make && make PREFIX="install_tmp" install

$(LIB95_BLAS): interfaces
	make -j libintel64 INSTALL_DIR=lib95 FC=gfortran --directory=./interfaces/blas95

$(LIB95_LAPACK): interfaces
	make -j libintel64 INSTALL_DIR=lib95 FC=gfortran --directory=./interfaces/lapack95

.PHONY: interfaces
interfaces:
	mkdir -p interfaces
	cp -r $(DIR_ONEAPI)/mkl/latest/share/mkl/interfaces/blas95   ./interfaces/blas95
	cp -r $(DIR_ONEAPI)/mkl/latest/share/mkl/interfaces/lapack95 ./interfaces/lapack95

.PHONY: install 
install: $(LIB95_BLAS) $(LIB95_LAPACK)
	cp -r ./OpenBLAS/install_tmp $(DIR_INSTALL)
	cp $(LIB95_BLAS)   $(DIR_INSTALL)/lib/
	cp $(LIB95_LAPACK) $(DIR_INSTALL)/lib/
	cp ./interfaces/blas95/lib95/include/mkl/intel64/lp64/f95_precision.mod $(DIR_INSTALL)/include/
	cp ./interfaces/blas95/lib95/include/mkl/intel64/lp64/blas95.mod        $(DIR_INSTALL)/include/
	cp ./interfaces/lapack95/lib95/include/mkl/intel64/lp64/lapack95.mod    $(DIR_INSTALL)/include/

.PHONY: test_openblas
test_openblas:
	gfortran -o ./test/test_openblas \
		./test/test_openblas.f90 $(LIB77) && \
		./test/test_openblas

#
# Link with OpenBLAS static library
#
.PHONY: test_blas95
test_blas95:
	gfortran -I$(DIR_INSTALL)/include -o ./test/test_blas95 \
		./test/test_blas95.f90 $(LIB95_BLAS) $(LIB77) && \
		./test/test_blas95

.PHONY: test_lapack95
test_lapack95:
	gfortran -I$(DIR_INSTALL)/include -o ./test/test_lapack95 \
		./test/test_lapack95.f90 $(LIB95_LAPACK) $(LIB77) && \
		./test/test_lapack95

#
# Link with OpenBLAS shared library
#
.PHONY: test_blas95_shared
test_blas95_shared:
	gfortran -I$(DIR_INSTALL)/include -L$(DIR_INSTALL)/lib -o ./test/test_blas95_shared \
		./test/test_blas95.f90 $(LIB95_BLAS) -lopenblas -Wl,-rpath,$(DIR_INSTALL)/lib && \
		./test/test_blas95_shared && \
		ldd ./test/test_blas95_shared 

.PHONY: test_lapack95_shared
test_lapack95_shared:
	gfortran -I$(DIR_INSTALL)/include -L$(DIR_INSTALL)/lib -o ./test/test_lapack95_shared \
		./test/test_lapack95.f90 $(LIB95_LAPACK) -lopenblas -Wl,-rpath,$(DIR_INSTALL)/lib && \
		./test/test_lapack95_shared && \
		ldd ./test/test_lapack95_shared 

clean:
	rm -r interfaces
	rm ./test/test_openblas
	rm ./test/test_blas95
	rm ./test/test_blas95_shared
	rm ./test/test_lapack95
	rm ./test/test_lapack95_shared

distclean: clean
	rm -rf OpenBLAS
	rm -r $(DIR_INSTALL)

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

