#include <stdio.h>
#include <cuda_runtime.h>

__global__ void transformMatrix(int *A, int *B, int m, int n) {
    int row = blockIdx.y * blockDim.y + threadIdx.y;
    int col = blockIdx.x * blockDim.x + threadIdx.x;
    
    if (row < m && col < n) {
        int val = A[row * n + col];
        int power = row + 1;
        int result = 1;
        
        for (int i = 0; i < power; i++) {
            result *= val;
        }
        
        B[row * n + col] = result;
    }
}

void printMatrix(int *M, int rows, int cols) {
    for (int i = 0; i < rows; i++) {
        for (int j = 0; j < cols; j++) {
            printf("%d\t", M[i * cols + j]);
        }
        printf("\n");
    }
    printf("\n");
}

int main() {
    int m, n;
    
    printf("Enter number of rows (M): ");
    scanf("%d", &m);
    
    printf("Enter number of columns (N): ");
    scanf("%d", &n);
    
    int *A = (int*)malloc(m * n * sizeof(int));
    int *B = (int*)malloc(m * n * sizeof(int));
    
    printf("Enter the elements of matrix A (%dx%d):\n", m, n);
    for (int i = 0; i < m; i++) {
        for (int j = 0; j < n; j++) {
            scanf("%d", &A[i * n + j]);
        }
    }
    
    printf("Matrix :\n");
    printMatrix(A, m, n);
    
    int size = m * n * sizeof(int);
    int *d_A, *d_B;
    
    cudaMalloc((void**)&d_A, size);
    cudaMalloc((void**)&d_B, size);
    
    cudaMemcpy(d_A, A, size, cudaMemcpyHostToDevice);
    
    dim3 blockSize(16, 16);
    dim3 gridSize((n + blockSize.x - 1) / blockSize.x, (m + blockSize.y - 1) / blockSize.y);
    
    transformMatrix<<<gridSize, blockSize>>>(d_A, d_B, m, n);
    
    cudaError_t err = cudaGetLastError();
    if (err != cudaSuccess) {
        printf("CUDA Error: %s\n", cudaGetErrorString(err));
        return -1;
    }
    
    cudaMemcpy(B, d_B, size, cudaMemcpyDeviceToHost);
    
    printf("Matrix after Operation:\n");
    printMatrix(B, m, n);
    
    cudaFree(d_A);
    cudaFree(d_B);
    free(A);
    free(B);
    
    return 0;
}