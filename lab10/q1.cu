#include "cuda_runtime.h"
#include "device_launch_parameters.h"
#include <stdio.h>
#include <stdlib.h>
#include <math.h>

__global__ void matmul(int *a, int *b, int *t, int m, int n, int q) {
    int r = blockIdx.y * blockDim.y + threadIdx.y;
    int c = blockIdx.x * blockDim.x + threadIdx.x;

    if (r < m && c < q) {  // Ensure valid thread range
        int sum = 0;
        for (int k = 0; k < n; k++)
            sum += a[r * n + k] * b[k * q + c];
        t[r * q + c] = sum;
    }
}

int main(void) {
    int *a, *b, *t, m, n, p, q;
    int *d_a, *d_b, *d_t;

    printf("m value: ");
    scanf("%d", &m);
    printf("n value: ");
    scanf("%d", &n);
    printf("p value: ");
    scanf("%d", &p);
    printf("q value: ");
    scanf("%d", &q);

    if (n != p) {
        printf("Matrix multiplication not possible: n != p.\n");
        return -1;
    }

    int sizeA = sizeof(int) * m * n;
    int sizeB = sizeof(int) * p * q;
    int sizeT = sizeof(int) * m * q;

    a = (int *)malloc(sizeA);
    b = (int *)malloc(sizeB);
    t = (int *)malloc(sizeT);

    printf("Enter matrix A: ");
    for (int i = 0; i < m * n; i++)
        scanf("%d", &a[i]);

    printf("Enter matrix B: ");
    for (int i = 0; i < p * q; i++)
        scanf("%d", &b[i]);

    cudaMalloc((void **)&d_a, sizeA);
    cudaMalloc((void **)&d_b, sizeB);
    cudaMalloc((void **)&d_t, sizeT);

    cudaMemcpy(d_a, a, sizeA, cudaMemcpyHostToDevice);
    cudaMemcpy(d_b, b, sizeB, cudaMemcpyHostToDevice);

    dim3 block(16, 16);
    dim3 grid(ceil((float)q / block.x), ceil((float)m / block.y));

    matmul<<<grid, block>>>(d_a, d_b, d_t, m, n, q);
    cudaMemcpy(t, d_t, sizeT, cudaMemcpyDeviceToHost);

    printf("Result matrix:\n");
    for (int i = 0; i < m; i++) {
        for (int j = 0; j < q; j++)
            printf("%d ", t[i * q + j]);
        printf("\n");
    }

    free(a);
    free(b);
    free(t);
    cudaFree(d_a);
    cudaFree(d_b);
    cudaFree(d_t);

    return 0;
}
