#include <stdio.h>
#include <stdlib.h>
#include "mpi.h"
int main(int argc, char *argv[]){
    int rank, size, buffer_size = (MPI_BSEND_OVERHEAD + sizeof(int));
    int *buffer = malloc(buffer_size);
    MPI_Init(&argc, &argv);
    MPI_Comm_rank(MPI_COMM_WORLD, &rank);
    MPI_Comm_size(MPI_COMM_WORLD, &size);
    int arr[size];
    MPI_Status status;
    if(rank==0){
        MPI_Buffer_attach(buffer, buffer_size);
        printf("Enter the Array : ");
        for(int i=0; i<size-1; i++){
            scanf("%d", &arr[i]);
        }
        for(int i=1; i<size; i++){
            MPI_Bsend(&arr[i-1], 1, MPI_INT, i, 1, MPI_COMM_WORLD);
        }
        MPI_Buffer_detach(&buffer, &buffer_size);
    } else if(rank%2==0) {
        int rec;
        MPI_Recv(&rec, 1 ,MPI_INT, 0, 1, MPI_COMM_WORLD, &status);
        fprintf(stdout, "Process %d received %d square %d\n", rank, rec, rec*rec);
        fflush(stdout);
    } else {
        int rec;
        MPI_Recv(&rec, 1 ,MPI_INT, 0, 1, MPI_COMM_WORLD, &status);
        fprintf(stdout, "Process %d received %d cube %d\n", rank, rec, rec*rec*rec);
        fflush(stdout);
    }
    MPI_Finalize();
    if(rank == size-1) printf("220905390\n");
    return 0;
}
