#include <stdio.h>
#include "mpi.h"

int main(int argc, char *argv[]) {
    int rank, size, x;
    MPI_Init(&argc, &argv);
    MPI_Comm_rank(MPI_COMM_WORLD, &rank);
    MPI_Comm_size(MPI_COMM_WORLD, &size);
    MPI_Status status;

    if (rank == 0) {
        printf("Enter an integer value: ");
        scanf("%d", &x);
        printf("Process %d sent %d to process %d\n", rank, x, (rank + 1) % size);
        MPI_Send(&x, 1, MPI_INT, (rank + 1) % size, 0, MPI_COMM_WORLD);
        MPI_Recv(&x, 1, MPI_INT, size - 1, 0, MPI_COMM_WORLD, &status);
        printf("Process %d received %d from process %d\n", rank, x, size - 1);
        printf("220905390\n");
    } else {
        MPI_Recv(&x, 1, MPI_INT, (rank - 1) % size, 0, MPI_COMM_WORLD, &status);
        printf("Process %d received %d from process %d\n", rank, x, (rank - 1) % size);
        x++;
        MPI_Send(&x, 1, MPI_INT, (rank + 1) % size, 0, MPI_COMM_WORLD);
        printf("Process %d sent %d to process %d\n", rank, x, (rank + 1) % size);
    }

    MPI_Finalize();
    return 0;
}
