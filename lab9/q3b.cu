#include <stdio.h>
#include <stdlib.h>
#include <cuda.h>
__device__ void getOnesCompInBin(int* n, int* res) {
    int numBits = 0;
    int d = *n;
    while (d > 0) {
        numBits++;
        d >>= 1;
    }
    int oc = 0;
    for (int i = numBits - 1; i >= 0; i--) {
        int bit = ((*n) >> i) & 1;
        int comp = bit ? 0 : 1;
        oc = oc * 10 + comp;
    }
    *res = oc;
}

__global__ void replaceElements(int* d_A, int* d_B, int m, int n) {
    int c = blockIdx.x * blockDim.x + threadIdx.x;
    int r = blockIdx.y * blockDim.y + threadIdx.y;
    if (r >= m || c >= n) return; 

    if (r > 0 && c > 0 && r < m - 1 && c < n - 1) {
        getOnesCompInBin(&d_A[r * n + c], &d_B[r * n + c]);
    } else {
        d_B[r * n + c] = d_A[r * n + c]; 
    }
}

int main() {
    int m, n;
    printf("Enter dimensions\n");
    scanf("%d %d", &m, &n);
    int A[m][n];
    int B[m][n];
    printf("Enter matrix\n");
    for (int i = 0; i < m; i++) {
        for (int j = 0; j < n; j++) {
            scanf("%d", &A[i][j]);
        }
    }
    int* d_A, *d_B;
    cudaMalloc((void**) &d_A, m * n * sizeof(int));
    cudaMalloc((void**) &d_B, m * n * sizeof(int));
    cudaMemcpy(d_A, A, m * n * sizeof(int), cudaMemcpyHostToDevice);
    dim3 dimGrid(ceil(n / 16.0), ceil(m / 16.0), 1);
    dim3 dimBlock(16, 16, 1);
    replaceElements<<<dimGrid, dimBlock>>>(d_A, d_B, m, n);
    cudaMemcpy(B, d_B, m * n * sizeof(int), cudaMemcpyDeviceToHost);
    printf("Result\n");
    for (int i = 0; i < m; i++) {
        for (int j = 0; j < n; j++) {
            printf("%d ", B[i][j]);
        }
        printf("\n");
    }

    cudaFree(d_A);
    cudaFree(d_B);
}
