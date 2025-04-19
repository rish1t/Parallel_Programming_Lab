#include "cuda_runtime.h"
#include "device_launch_parameters.h"
#include <stdio.h>
#include <stdlib.h>

__global__ void matmul_rowwise(int *a, int *b, int *t, int m, int n, int p)
{
    int row = threadIdx.x;
    if (row < m)
    {
        for (int col = 0; col < p; col++)
        {
            t[row * p + col] = 0;
            for (int k = 0; k < n; k++)
            {
                t[row * p + col] += a[row * n + k] * b[k * p + col];
            }
        }
    }
}

__global__ void matmul_columnwise(int *a, int *b, int *t, int m, int n, int p)
{
    int col = threadIdx.x;
    if (col < p)
    {
        for (int row = 0; row < m; row++)
        {
            t[row * p + col] = 0;
            for (int k = 0; k < n; k++)
            {
                t[row * p + col] += a[row * n + k] * b[k * p + col];
            }
        }
    }
}

__global__ void matmul_elementwise(int *a, int *b, int *t, int m, int n, int p)
{
    int row = threadIdx.x;
    int col = threadIdx.y;
    if (row < m && col < p)
    {
        t[row * p + col] = 0;
        for (int k = 0; k < n; k++)
        {
            t[row * p + col] += a[row * n + k] * b[k * p + col];
        }
    }
}

int check_multiplication_dimensions(int m1, int n1, int m2, int n2)
{
    if (n1 != m2)
    {
        printf("Error: Matrices dimensions must match for multiplication (columns of A == rows of B).\n");
        return 0;
    }
    return 1;
}

int main(void)
{
    int *a, *b, *c;
    int m, n, p;
    int *d_a, *d_b, *d_c;

    printf("Enter the dimensions of matrix A (rows x columns): ");
    scanf("%d %d", &m, &n);

    a = (int *)malloc(m * n * sizeof(int));
    printf("Enter matrix A:\n");
    for (int i = 0; i < m * n; i++)
        scanf("%d", &a[i]);

    printf("Enter the dimensions of matrix B (rows x columns): ");
    int m2, n2;
    scanf("%d %d", &m2, &n2);

    if (!check_multiplication_dimensions(m, n, m2, n2))
    {
        free(a);
        return -1;
    }

    b = (int *)malloc(m2 * n2 * sizeof(int));
    printf("Enter matrix B:\n");
    for (int i = 0; i < m2 * n2; i++)
        scanf("%d", &b[i]);

    int size_a = sizeof(int) * m * n;
    int size_b = sizeof(int) * m2 * n2;
    int size_c = sizeof(int) * m * n2;

    cudaMalloc((void **)&d_a, size_a);
    cudaMalloc((void **)&d_b, size_b);
    cudaMalloc((void **)&d_c, size_c);

    cudaMemcpy(d_a, a, size_a, cudaMemcpyHostToDevice);
    cudaMemcpy(d_b, b, size_b, cudaMemcpyHostToDevice);

    matmul_rowwise<<<1, m>>>(d_a, d_b, d_c, m, n, n2);

    matmul_columnwise<<<1, n2>>>(d_a, d_b, d_c, m, n, n2);

    dim3 threadsPerBlock(16, 16);
    dim3 numBlocks((m + 15) / 16, (n2 + 15) / 16);
    matmul_elementwise<<<numBlocks, threadsPerBlock>>>(d_a, d_b, d_c, m, n, n2);

    c = (int *)malloc(m * n2 * sizeof(int));
    cudaMemcpy(c, d_c, size_c, cudaMemcpyDeviceToHost);

    printf("\nMatrix multiplication result (row-wise):\n");
    for (int i = 0; i < m; i++)
    {
        for (int j = 0; j < n2; j++)
            printf("%d\t", c[i * n2 + j]);
        printf("\n");
    }

    free(a);
    free(b);
    free(c);
    cudaFree(d_a);
    cudaFree(d_b);
    cudaFree(d_c);

    return 0;
}
