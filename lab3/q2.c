#include "mpi.h"
#include <stdio.h>
int main(int argc, char *argv[])
{

    int rank, size, N, A[50], C[10], i, M;
    float B[10], ans;
    MPI_Init(&argc, &argv);
    MPI_Comm_rank(MPI_COMM_WORLD, &rank);
    MPI_Comm_size(MPI_COMM_WORLD, &size);
    if (rank == 0)
    {
        N=size;
        printf("Enter Integer M : ");
        scanf("%d", &M);
        printf("Enter %d elements : \n", M*N);
        for(i=0;i<M*N;i++){
            scanf("%d", &A[i]);
        }
    }
    MPI_Bcast(&M, 1, MPI_INT, 0, MPI_COMM_WORLD);
    MPI_Scatter(A, M, MPI_INT, C, M, MPI_INT, 0, MPI_COMM_WORLD);
    float avg;
    int sum=0;
    for(i=0;i<M;i++){
        sum += C[i];
    }
    avg = sum/M;
    MPI_Reduce(&avg, &ans, 1, MPI_FLOAT, MPI_SUM, 0, MPI_COMM_WORLD);
    if(rank==0){
        float average;
        average = ans/N;
        printf("Final Average : %f\n220905390\n", average);
    }
    
    MPI_Finalize();
    return 0;
}
