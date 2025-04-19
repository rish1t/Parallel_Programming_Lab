#include "cuda_runtime.h"
#include "device_launch_parameters.h"
#include <stdio.h>
#include <stdlib.h>

__global__ void matadd_rowwise(int *a, int *b, int *t, int m, int n)
{
    int row = threadIdx.x;
    if (row < m)
    {
        for (int col = 0; col < n; col++)
        {
            t[row * n + col] = a[row * n + col] + b[row * n + col];
        }
    }
}

__global__ void matadd_columnwise(int *a, int *b, int *t, int m, int n)
{
    int col = threadIdx.x;
    if (col < n)
    {
        for (int row = 0; row < m; row++)
        {
            t[row * n + col] = a[row * n + col] + b[row * n + col];
        }
    }
}

__global__ void matadd_elementwise(int *a, int *b, int *t, int m, int n)
{
    int row = threadIdx.x;
    int col = threadIdx.y;
    if (row < m && col < n)
    {
        t[row * n + col] = a[row * n + col] + b[row * n + col];
    }
}

int check_addition_dimensions(int m1, int n1, int m2, int n2)
{
    if (m1 != m2 || n1 != n2)
    {
        printf("Error: Matrices dimensions must match for addition.\n");
        return 0;
    }
    return 1;
}

int main(void)
{
    int *a, *b, *t;
    int m, n;
    int *d_a, *d_b, *d_t;

    printf("Enter the dimensions of matrix A (rows x columns): ");
    scanf("%d %d", &m, &n);

    a = (int *)malloc(m * n * sizeof(int));
    printf("Enter matrix A:\n");
    for (int i = 0; i < m * n; i++)
        scanf("%d", &a[i]);

    printf("Enter the dimensions of matrix B (rows x columns): ");
    int m2, n2;
    scanf("%d %d", &m2, &n2);

    if (!check_addition_dimensions(m, n, m2, n2))
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
    int size_t = sizeof(int) * m * n;

    cudaMalloc((void **)&d_a, size_a);
    cudaMalloc((void **)&d_b, size_b);
    cudaMalloc((void **)&d_t, size_t); // For result

    cudaMemcpy(d_a, a, size_a, cudaMemcpyHostToDevice);
    cudaMemcpy(d_b, b, size_b, cudaMemcpyHostToDevice);

    matadd_rowwise<<<1, m>>>(d_a, d_b, d_t, m, n);

    //matadd_columnwise<<<1, n>>>(d_a, d_b, d_t, m, n);

    //dim3 threadsPerBlock(16, 16);
    //dim3 numBlocks((m + 15) / 16, (n + 15) / 16);
    //matadd_elementwise<<<numBlocks, threadsPerBlock>>>(d_a, d_b, d_t, m, n);

    t = (int *)malloc(m * n * sizeof(int));
    cudaMemcpy(t, d_t, size_t, cudaMemcpyDeviceToHost);

    printf("\nMatrix addition result (row-wise):\n");
    for (int i = 0; i < m; i++)
    {
        for (int j = 0; j < n; j++)
            printf("%d\t", t[i * n + j]);
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
