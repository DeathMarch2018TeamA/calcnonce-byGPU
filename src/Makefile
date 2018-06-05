# Makefile
calc_nonce: sha256.o calc_nonce_cuda.o calc_nonce.o calc_nonce_test.o
	nvcc -o calc_nonce sha256.o calc_nonce_cuda.o calc_nonce.o calc_nonce_test.o --relocatable-device-code=true

sha256.o: sha256.cu
	nvcc -c sha256.cu --relocatable-device-code=true

calc_nonce_cuda.o: calc_nonce_cuda.cu
	nvcc -c calc_nonce_cuda.cu --relocatable-device-code=true

calc_nonce.o: calc_nonce.cpp
	g++ -c calc_nonce.cpp

calc_nonce_test.o: calc_nonce_test.cpp
	g++ -c calc_nonce_test.cpp

clean: 
	rm sha256.o calc_nonce_cuda.o calc_nonce.o calc_nonce_test.o

