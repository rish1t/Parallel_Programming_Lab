#include <stdio.h>
#include "mpi.h"
int main(int argc, char *argv[]){
    int rank, size, x;
    MPI_Init(&argc, &argv);
    MPI_Comm_rank(MPI_COMM_WORLD, &rank);
    MPI_Comm_size(MPI_COMM_WORLD, &size);
    MPI_Status status;
    if(rank==0){
        printf("Sending value to all processes from master process: \n");
        int x = 20;
        for(int i=1; i<=3; i++){
            MPI_Send(&x, 1, MPI_INT, i, 1, MPI_COMM_WORLD);
            x +=10;
        }
    } else {
        MPI_Recv(&x, 1 ,MPI_INT, 0, 1, MPI_COMM_WORLD, &status);
        fprintf(stdout, "Process %d received %d\n", rank, x);
        fflush(stdout);
    }
    MPI_Finalize();
    if(rank == size-1) printf("220905390\n");
    return 0;
}
