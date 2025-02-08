#include "cuda_runtime.h"
#include "device_launch_parameters.h"
#include <stdio.h>

__device__ int getGTID()
{
    int gtid = blockIdx.x * blockDim.x + threadIdx.x + 
               blockIdx.y * blockDim.x * gridDim.x + 
               threadIdx.y * blockDim.x;
    return gtid;
}

__global__ void add_vec(int *da, int *db, int *dc, int n)
{
    int gtid = getGTID();
    if (gtid < n)
    {
        dc[gtid] = da[gtid] + db[gtid];
    }
}

int main()
{
    int n, t = 256;
    printf("Length of the vector: ");
    scanf("%d", &n);

    int *a = (int*)malloc(n * sizeof(int));
    int *b = (int*)malloc(n * sizeof(int));
    int *c = (int*)malloc(n * sizeof(int));
    int *da, *db, *dc;

    cudaMalloc((void **)&da, n * sizeof(int));
    cudaMalloc((void **)&db, n * sizeof(int));
    cudaMalloc((void **)&dc, n * sizeof(int));

    for (int i = 0; i < n; i++) {
        a[i] = i + 1;
        b[i] = i + 1;
    }

    cudaMemcpy(da, a, n * sizeof(int), cudaMemcpyHostToDevice);
    cudaMemcpy(db, b, n * sizeof(int), cudaMemcpyHostToDevice);

    add_vec<<<ceil((float)n/256), t>>>(da, db, dc, n);

    cudaMemcpy(c, dc, n * sizeof(int), cudaMemcpyDeviceToHost);

    for (int i = 0; i < n; i++)
        printf("%d\t", c[i]);
    printf("\n");

    printf("Unused threads: %d\n220905390\n", n > t ? t-(n%t) : t - n);

    free(a);
    free(b);
    free(c);
    cudaFree(da);
    cudaFree(db);
    cudaFree(dc);

    return 0;
}
