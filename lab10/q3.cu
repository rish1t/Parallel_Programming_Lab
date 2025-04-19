#include <stdio.h>
#include <cuda_runtime.h>

#define TILE_SIZE 16

__global__ void convolution_1D_tiled(float *N, float *M, float *P, int width, int mask_width) {
    __shared__ float N_s[TILE_SIZE + 4];
    int i = blockIdx.x * blockDim.x + threadIdx.x;
    int n = mask_width / 2;
    int halo_index = i - n;
    if (halo_index >= 0 && halo_index < width) {
        N_s[threadIdx.x] = N[halo_index];
    } else {
        N_s[threadIdx.x] = 0.0f;
    }
    __syncthreads();
    float Pvalue = 0.0f;
    if (threadIdx.x < TILE_SIZE && i < width) {
        for (int j = 0; j < mask_width; j++) {
            int index = threadIdx.x + j;
            if (index < TILE_SIZE + mask_width - 1) {
                Pvalue += N_s[index] * M[j];
            }
        }
        P[i] = Pvalue;
    }
}

int main() {
    int width, mask_width;
    printf("Enter the size of the input array: ");
    scanf("%d", &width);
    printf("Enter the size of the mask array: ");
    scanf("%d", &mask_width);
    float *h_N = (float*)malloc(width * sizeof(float));
    float *h_M = (float*)malloc(mask_width * sizeof(float));
    float *h_P = (float*)malloc(width * sizeof(float));
    printf("Enter input array elements: ");
    for (int i = 0; i < width; i++) scanf("%f", &h_N[i]);
    printf("Enter mask array elements: ");
    for (int i = 0; i < mask_width; i++) scanf("%f", &h_M[i]);
    float *d_N, *d_M, *d_P;
    cudaMalloc(&d_N, width * sizeof(float));
    cudaMalloc(&d_M, mask_width * sizeof(float));
    cudaMalloc(&d_P, width * sizeof(float));
    cudaMemcpy(d_N, h_N, width * sizeof(float), cudaMemcpyHostToDevice);
    cudaMemcpy(d_M, h_M, mask_width * sizeof(float), cudaMemcpyHostToDevice);
    int block_size = TILE_SIZE;
    int grid_size = (width + block_size - 1) / block_size;
    convolution_1D_tiled<<<grid_size, block_size>>>(d_N, d_M, d_P, width, mask_width);
    cudaMemcpy(h_P, d_P, width * sizeof(float), cudaMemcpyDeviceToHost);
    printf("Resultant array: ");
    for (int i = 0; i < width; i++) printf("%f ", h_P[i]);
    printf("\n");
    cudaFree(d_N);
    cudaFree(d_M);
    cudaFree(d_P);
    free(h_N);
    free(h_M);
    free(h_P);
    return 0;
}
