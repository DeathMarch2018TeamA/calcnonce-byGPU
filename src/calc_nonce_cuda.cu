#include <stdio.h>
#include <string.h>

#include <stdlib.h>	//rand()

#include "sha256.cuh"
#include "calc_nonce_cuda.cuh"

#include <curand_kernel.h>

//debug main() off
#define DEBUG

/***string***/

__device__ int my_strlen(char *str){
	int i = 0;
	while (str[i++] != '\0');
	i--;
	return i;
}

__device__ char * my_strcpy(char *dest, const char *src){
	int i = 0;
	do {
	  dest[i] = src[i];}
	while (src[i++] != 0);
	return dest;
}
  
  __device__ char * my_strcat(char *dest, const char *src){
	int i = 0;
	while (dest[i] != 0) i++;
	my_strcpy(dest+i, src);
	return dest;
}

__device__ int my_strcmp(const char *str_a, const char *str_b){
	while(*str_a == *str_b){
        if(*str_a == '\0'){
            return 0;
        }
        ++str_a;
        ++str_b;
    }
    return 1;
}

/***string***/

__device__
char change_10to16_one(int x) {

	char c;

	if (0 > x || x > 15) return 'X';
	else if (x >= 0 && x <= 9) c = x + '0';
	else if (x >= 10 && x <= 15) c = x + 'a' - 10;

	return c;
}

__device__
void string_change(unsigned char *hash, char *string_hash, int cpylen){

    int i=0,j=0;

    do{
        j=2*i;
        string_hash[j] = change_10to16_one(((int)hash[i] / 16));
        if(j>cpylen-2) break;
        j++;
        string_hash[j] = change_10to16_one(((int)hash[i] % 16));
        i++;
    }while(j<cpylen-1);

    string_hash[j+1] = '\0';

}

__device__
void random_nonce(char *nonce,curandState &s){

	const char set[] = "0123456789abcdef";
	int randam;

	for(int i = 0; i < 8; i++){
		randam = curand(&s) % 16;
		nonce[i]= set[randam];
	}

}

__device__
void calc_SHA256(char *string, char *string_hash, int hashlen){

	BYTE buf[SHA256_BLOCK_SIZE];
	SHA256_CTX ctx;

	sha256_init(&ctx);
	sha256_update(&ctx, (BYTE *)string, my_strlen(string));
	sha256_final(&ctx, buf);

	string_change(buf,string_hash,64);

	sha256_init(&ctx);
	sha256_update(&ctx, (const BYTE *)string_hash, my_strlen(string_hash));
	sha256_final(&ctx, buf);

	string_change(buf,string_hash,hashlen);


}

__global__
void calc_nonce_kernel(volatile bool *found, char *zero_size, char *block, char *nonce){


	BYTE blocknonce[157+8+1];
	char hash[65];

	//extern __shared__ char sub_zero_size[];
	//__shared__ char sub_block[157+1];

	char sub_nonce[9];
	my_strcpy(sub_nonce,nonce);

	curandState s;
	int id = blockIdx.x * blockDim.x + threadIdx.x;
	curand_init(0, id, id, &s);	

	do{
		
	random_nonce(sub_nonce,s);

	my_strcpy((char *)blocknonce,block);
	my_strcat((char *)blocknonce,sub_nonce);

	calc_SHA256((char *)blocknonce,hash,my_strlen(zero_size));

	*found = (my_strcmp(hash,zero_size) == 0);

	} while(!(*found));


	my_strcpy(nonce,sub_nonce);

	//for debug
	//printf("id=%d,blocknonce:%s\n",id,blocknonce);

}

void calc_nonce_host(const char *zero_size, const char *block, char *nonce){

	char *d_zero_size;
	char *d_block;
	char *d_nonce;

	bool *d_found;
	cudaMalloc((void**)&d_found, sizeof(bool));
	cudaMemset(d_found, false, sizeof(bool));

	cudaMalloc((void**)&d_zero_size,sizeof(char) * strlen(zero_size));
	cudaMalloc((void**)&d_block, sizeof(char) * strlen(block));
	cudaMalloc((void**)&d_nonce, sizeof(char) * strlen(nonce));

	cudaMemcpy(d_zero_size, zero_size, sizeof(char) * strlen(zero_size), cudaMemcpyHostToDevice);
	cudaMemcpy(d_block, block, sizeof(char) * strlen(block), cudaMemcpyHostToDevice);

	//calc_nonce_kernel<<<1024,256,strlen(zero_size)+1>>>(d_found, d_zero_size, d_block, d_nonce);
	calc_nonce_kernel<<<1,1>>>(d_found, d_zero_size, d_block, d_nonce);

	cudaMemcpy(nonce, d_nonce, sizeof(char) * strlen(nonce), cudaMemcpyDeviceToHost);

	cudaFree(d_zero_size);
	cudaFree(d_block);
	cudaFree(d_nonce);
	cudaFree(d_found);

}


#ifndef DEBUG
int main(void){

	char zero[200]="000";
	char block[20]="aaaaa";
	char nonce[9]="00000000";

	calc_nonce_host(zero,block,nonce);

	printf("nonce:%s\n",nonce);

	return 0;

}
#endif