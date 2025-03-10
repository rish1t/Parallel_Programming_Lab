#include <iostream>
#include <string>
#include <cuda_runtime.h>

__global__ void countOccurrences(const char* s, const char* w, int* c, int slen, int wlen) {
    int idx = threadIdx.x + blockIdx.x * blockDim.x;
    if (idx < slen - wlen + 1) {
        bool match = true;
        for (int i = 0; i < wlen; ++i) {
            if (s[idx + i] != w[i]) {
                match = false;
                break;
            }
        }
        if (match) atomicAdd(c, 1);
    }
}

int main() {
    char s[50], w[50];
    printf("Enter the string : ");
    scanf("%[^\n]c", s);
    printf("Enter the word to be searched : ");
    scanf(" %s", w);

    int slen = strlen(s);
    int wlen = strlen(w);
    char *d_s, *d_w;
    int *d_c, hcount;
    cudaMalloc(&d_s, slen * sizeof(char));
    cudaMalloc(&d_w, wlen * sizeof(char));
    cudaMalloc(&d_c, sizeof(int));

    cudaMemcpy(d_s, s, slen * sizeof(char), cudaMemcpyHostToDevice);
    cudaMemcpy(d_w, w, wlen * sizeof(char), cudaMemcpyHostToDevice);
    cudaMemcpy(d_c, &hcount, sizeof(int), cudaMemcpyHostToDevice);

    int bs = 256, gs = (slen + bs - 1) / bs;
    countOccurrences<<<gs, bs>>>(d_s, d_w, d_c, slen, wlen);

    cudaMemcpy(&hcount, d_c, sizeof(int), cudaMemcpyDeviceToHost);

    printf("The word '%s' appears %d times.\n", w, hcount);

    cudaFree(d_s);
    cudaFree(d_w);
    cudaFree(d_c);

    return 0;
}
