CUDAC=nvcc
CUDACFLAGS=-g -O0

all: noUnifMem unifMem

noUnifMem: noUnifMem.cu
	${CUDAC} ${CUDACFLAGS} -o noUnifMem noUnifMem.cu

unifMem: unifMem.cu
	${CUDAC} ${CUDACFLAGS} -o unifMem unifMem.cu

clean: 
	rm -rf noUnifMem unifMem
