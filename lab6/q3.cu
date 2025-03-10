#include "cuda_runtime.h"
#include "device_launch_parameters.h"
#include <stdio.h>

__global__ void oddEvenSort(int *arr, int n)
{
    int tid = blockIdx.x * blockDim.x + threadIdx.x;
    int temp;

    if (tid >= n) return;

    for (int phase = 0; phase < n; phase++) {
        if (phase % 2 == 0) {
            if (tid % 2 == 0 && tid + 1 < n) {
                if (arr[tid] > arr[tid + 1]) {
                    temp = arr[tid];
                    arr[tid] = arr[tid + 1];
                    arr[tid + 1] = temp;
                }
            }
        } else {
            if (tid % 2 == 1 && tid + 1 < n) {
                if (arr[tid] > arr[tid + 1]) {
                    temp = arr[tid];
                    arr[tid] = arr[tid + 1];
                    arr[tid + 1] = temp;
                }
            }
        }
        __syncthreads();
    }
}



int main()
{
    int n, i, *d_arr;
    printf("Enter the no. of elements : ");
    scanf("%d", &n);

    int arr[n], res[n];
    printf("Enter the array : ");
    for (i = 0; i < n; i++)
    {
        scanf("%d", &arr[i]);
    }

    cudaMalloc((void **)&d_arr, n * sizeof(int));
    cudaMemcpy(d_arr, arr, n * sizeof(int), cudaMemcpyHostToDevice);

    oddEvenSort<<<1, n>>>(d_arr, n);

    cudaMemcpy(res, d_arr, n * sizeof(int), cudaMemcpyDeviceToHost);

    printf("Sorted array: \n");
    for (int i = 0; i < n; i++)
    {
        printf("%d ", res[i]);
    }
    printf("\n");

    cudaFree(d_arr);
    return 0;
}
