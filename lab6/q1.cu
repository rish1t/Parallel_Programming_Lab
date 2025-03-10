#include "cuda_runtime.h"
#include "device_launch_parameters.h"
#include <stdio.h>

__global__ void conv_1D(float *N, float *M, float *P, int M_width, int width)
{
    int i = blockIdx.x * blockDim.x + threadIdx.x;
    if (i >= width)
        return;

    float Pval = 0.0;
    int start = i - (M_width / 2);
    for (int j = 0; j < M_width; j++)
    {
        int idx = start + j;
        if (idx >= 0 && idx < width)
        {
            Pval += N[idx] * M[j];
        }
    }
    P[i] = Pval;
}

int main()
{
    int n, m;
    printf("Enter the length of the Vector: ");
    scanf("%d", &n);
    printf("Enter length of the mask: ");
    scanf("%d", &m);

    float *N = (float *)malloc(n * sizeof(float));
    float *M = (float *)malloc(m * sizeof(float));
    float *P = (float *)malloc(n * sizeof(float));

    float *da, *db, *dc;

    cudaMalloc((void **)&da, n * sizeof(float));
    cudaMalloc((void **)&db, m * sizeof(float));
    cudaMalloc((void **)&dc, n * sizeof(float));

    printf("Enter vector: ");
    for (int i = 0; i < n; i++)
        scanf("%f", &N[i]);

    printf("Enter Mask: ");
    for (int i = 0; i < m; i++)
        scanf("%f", &M[i]);

    cudaMemcpy(da, N, n * sizeof(float), cudaMemcpyHostToDevice);
    cudaMemcpy(db, M, m * sizeof(float), cudaMemcpyHostToDevice);

    conv_1D<<<1, 256>>>(da, db, dc, m, n);

    cudaMemcpy(P, dc, n * sizeof(float), cudaMemcpyDeviceToHost);

    for (int i = 0; i < n; i++)
        printf("%2.2f\t", P[i]);
    printf("\n");

    cudaFree(da);
    cudaFree(db);
    cudaFree(dc);

    free(N);
    free(M);
    free(P);

    return 0;
}
