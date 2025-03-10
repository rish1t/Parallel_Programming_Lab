#include "cuda_runtime.h"
#include "device_launch_parameters.h"
#include <stdio.h>

__global__ void selecsort(int *arr, int n)
{
    int tid = blockIdx.x * blockDim.x + threadIdx.x;

    if(tid >= n) return;

    for (int i = 0; i < n - 1; i++)
    {
        int minIdx = i;
        for (int j = i + 1; j < n; j++)
        {
            if (arr[j] < arr[minIdx])
            {
                minIdx = j;
            }
        }

        if (tid == i)
        {
            int temp = arr[i];
            arr[i] = arr[minIdx];
            arr[minIdx] = temp;
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

    selecsort<<<1, n>>>(d_arr, n);

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
