#include "cuda_runtime.h"
#include "device_launch_parameters.h"
#include<stdio.h>

__global__ void add_vec(int*da, int*db, int*dc){
    int index = blockIdx.x*blockDim.x+threadIdx.x;
    dc[index] = da[index] + db[index];
}

int main(){
    int n;
    printf("Length of the vector : ");
    scanf("%d",&n);

    int a[n],b[n],c[n];
    int *da,*db,*dc;

    cudaMalloc((void **)&da,n*sizeof(int));
    cudaMalloc((void **)&db,n*sizeof(int));
    cudaMalloc((void **)&dc,n*sizeof(int));

    printf("Enter vector one : ");
    for(int i=0;i<n;i++)
        scanf("%d",&a[i]);

    printf("Enter vector two : ");
    for(int i=0;i<n;i++)
        scanf("%d",&b[i]);
    
    cudaMemcpy(da,a,n*sizeof(int),cudaMemcpyHostToDevice);
    cudaMemcpy(db,b,n*sizeof(int),cudaMemcpyHostToDevice);


    add_vec<<<n,1>>>(da,db,dc);
    cudaMemcpy(c,dc,n*sizeof(int),cudaMemcpyDeviceToHost);

    for(int i=0;i<n;i++)
        printf("%d\t",c[i]);
    printf("\n220905390\n");
    cudaFree(da);
    cudaFree(db);
    cudaFree(dc);
}