# Makefile
calc_nonce: sha256.o calc_nonce_cuda.o calc_nonce.o calc_nonce_test.o
	nvcc -o calc_nonce sha256.o calc_nonce_cuda.o calc_nonce.o calc_nonce_test.o

sha256.o: sha256.cu
	nvcc -c sha256.cu

sha256_calc.o: calc_nonce_cuda.cu
	nvcc -c calc_nonce_cuda.cu

calc_nonce.o: calc_nonce.cpp
	g++ -c calc_nonce.cpp

calc_nonce_test.o: calc_nonce_test.cpp
	g++ -c calc_nonce_test.cpp