#include "cuda_runtime.h"
#include "device_launch_parameters.h"
#include <stdio.h>
// #include <math_functions.h>

__device__ int getGTID()
{
    int gtid = blockIdx.x * blockDim.x + threadIdx.x + 
               blockIdx.y * blockDim.x * gridDim.x + 
               threadIdx.y * blockDim.x;
    return gtid;
}

__global__ void compute_sine(float *da, float *dc, int n)
{
    int gtid = getGTID();
    if (gtid < n)
    {
        dc[gtid] = sin(da[gtid]);
    }
}

int main()
{
    int n = 360 / 5;
    int t = 256;
    
    float *a = (float*)malloc(n * sizeof(float));
    float *c = (float*)malloc(n * sizeof(float));
    float *da, *dc;

    cudaMalloc((void **)&da, n * sizeof(float));
    cudaMalloc((void **)&dc, n * sizeof(float));

    for (int i = 0; i < n; i++) {
        a[i] = (float)(i * 5) * (M_PI / 180); 
    }

    cudaMemcpy(da, a, n * sizeof(float), cudaMemcpyHostToDevice);

    compute_sine<<<(n + t - 1) / t, t>>>(da, dc, n);

    cudaMemcpy(c, dc, n * sizeof(float), cudaMemcpyDeviceToHost);

    for (int i = 0; i < n; i++)
        printf("sin(%d degrees) = %f\n", i * 5, c[i]);

    printf("Unused threads: %d\n220905390\n", n > t ? t - (n % t) : t - n);

    free(a);
    free(c);
    cudaFree(da);
    cudaFree(dc);

    return 0;
}
