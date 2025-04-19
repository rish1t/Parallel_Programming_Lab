#include <stdio.h>
#include <stdlib.h>
#include <cuda_runtime.h>

__global__ void spmv_csr_kernel(int num_rows, const int *row_ptr, const int *col_idx, 
                              const float *values, const float *x, float *y) {
    int row = blockIdx.x * blockDim.x + threadIdx.x;
    
    if (row < num_rows) {
        float dot = 0.0f;
        int row_start = row_ptr[row];
        int row_end = row_ptr[row + 1];
        
        for (int i = row_start; i < row_end; i++) {
            dot += values[i] * x[col_idx[i]];
        }
        
        y[row] = dot;
    }
}

int main() {
    int num_rows, num_cols, nnz;
    
    printf("Enter number of rows: ");
    scanf("%d", &num_rows);
    
    printf("Enter number of columns: ");
    scanf("%d", &num_cols);
    
    printf("Enter number of non-zero elements: ");
    scanf("%d", &nnz);
    
    int *h_row_ptr = (int*)malloc((num_rows + 1) * sizeof(int));
    int *h_col_idx = (int*)malloc(nnz * sizeof(int));
    float *h_values = (float*)malloc(nnz * sizeof(float));
    float *h_x = (float*)malloc(num_cols * sizeof(float));
    float *h_y = (float*)malloc(num_rows * sizeof(float));
    
    printf("Enter row_ptr array (%d values): ", num_rows + 1);
    for (int i = 0; i <= num_rows; i++) {
        scanf("%d", &h_row_ptr[i]);
    }
    
    printf("Enter col_idx array (%d values): ", nnz);
    for (int i = 0; i < nnz; i++) {
        scanf("%d", &h_col_idx[i]);
    }
    
    printf("Enter values array (%d values): ", nnz);
    for (int i = 0; i < nnz; i++) {
        scanf("%f", &h_values[i]);
    }
    
    printf("Enter input vector x (%d values): ", num_cols);
    for (int i = 0; i < num_cols; i++) {
        scanf("%f", &h_x[i]);
    }
    
    for (int i = 0; i < num_rows; i++) {
        h_y[i] = 0.0f;
    }
    
    int *d_row_ptr, *d_col_idx;
    float *d_values, *d_x, *d_y;
    
    cudaMalloc((void**)&d_row_ptr, (num_rows + 1) * sizeof(int));
    cudaMalloc((void**)&d_col_idx, nnz * sizeof(int));
    cudaMalloc((void**)&d_values, nnz * sizeof(float));
    cudaMalloc((void**)&d_x, num_cols * sizeof(float));
    cudaMalloc((void**)&d_y, num_rows * sizeof(float));
    
    cudaMemcpy(d_row_ptr, h_row_ptr, (num_rows + 1) * sizeof(int), cudaMemcpyHostToDevice);
    cudaMemcpy(d_col_idx, h_col_idx, nnz * sizeof(int), cudaMemcpyHostToDevice);
    cudaMemcpy(d_values, h_values, nnz * sizeof(float), cudaMemcpyHostToDevice);
    cudaMemcpy(d_x, h_x, num_cols * sizeof(float), cudaMemcpyHostToDevice);
    
    int threadsPerBlock = 256;
    int blocksPerGrid = (num_rows + threadsPerBlock - 1) / threadsPerBlock;
    
    spmv_csr_kernel<<<blocksPerGrid, threadsPerBlock>>>(num_rows, d_row_ptr, d_col_idx, d_values, d_x, d_y);
    
    cudaMemcpy(h_y, d_y, num_rows * sizeof(float), cudaMemcpyDeviceToHost);
    
    printf("\nOutput vector y = A*x: ");
    for (int i = 0; i < num_rows; i++) {
        printf("%.1f ", h_y[i]);
    }
    printf("\n");
    
    cudaFree(d_row_ptr);
    cudaFree(d_col_idx);
    cudaFree(d_values);
    cudaFree(d_x);
    cudaFree(d_y);
    
    free(h_row_ptr);
    free(h_col_idx);
    free(h_values);
    free(h_x);
    free(h_y);
    
    return 0;
}