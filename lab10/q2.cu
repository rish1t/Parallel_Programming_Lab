#include <stdio.h>
#include <cuda.h>

#define N 5
#define K 5     

__constant__ float d_kernel[K];

__global__ void convolution1D(float *d_input, float *d_output, int size) {
    int i = threadIdx.x + blockIdx.x * blockDim.x;
    float sum = 0.0f;
    
    if (i < size) {
        for (int j = 0; j < K; j++) {
            int index = i + j - K / 2;
            if (index >= 0 && index < size) {
                sum += d_input[index] * d_kernel[j];
            }
        }
        d_output[i] = sum;
    }
}

int main() {
    float h_input[N], h_output[N], h_kernel[K];
    float *d_input, *d_output;
    
    printf("Enter %d elements for input array:\n", N);
    for (int i = 0; i < N; i++) scanf("%f", &h_input[i]);

    printf("Enter %d elements for kernel:\n", K);
    for (int i = 0; i < K; i++) scanf("%f", &h_kernel[i]);

    cudaMalloc((void**)&d_input, N * sizeof(float));
    cudaMalloc((void**)&d_output, N * sizeof(float));

    cudaMemcpy(d_input, h_input, N * sizeof(float), cudaMemcpyHostToDevice);

    cudaMemcpyToSymbol(d_kernel, h_kernel, K * sizeof(float));

    int threadsPerBlock = 256;
    int blocksPerGrid = (N + threadsPerBlock - 1) / threadsPerBlock;
    convolution1D<<<blocksPerGrid, threadsPerBlock>>>(d_input, d_output, N);

    cudaMemcpy(h_output, d_output, N * sizeof(float), cudaMemcpyDeviceToHost);

    cudaFree(d_input);
    cudaFree(d_output);
    
    printf("Convolution Output:\n");
    for (int i = 0; i < N; i++) {
        printf("h_output[%d] = %f\n", i, h_output[i]);
    }
    
    return 0;
}
