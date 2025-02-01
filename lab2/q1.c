#include <stdio.h>
#include <string.h>
#include "mpi.h"
int main(int argc, char *argv[]){
    int rank, size;
    char data[50];

    MPI_Init(&argc, &argv);
    MPI_Comm_rank(MPI_COMM_WORLD, &rank);
    MPI_Comm_size(MPI_COMM_WORLD, &size);
    MPI_Status status;
    if(rank==0){
        printf("Enter the value to be sent to the receiver : ");
        scanf("%s", data);
        int len = strlen(data);

        MPI_Ssend(&len, 1, MPI_INT, 1, 0, MPI_COMM_WORLD);
        
        MPI_Ssend(data, len, MPI_CHAR, 1, 1, MPI_COMM_WORLD);

        fprintf(stdout, "I have sent %s from my process 0\n", data);

        MPI_Recv(data, len , MPI_CHAR, 1, 2, MPI_COMM_WORLD, &status);

        printf("Received %s from the other process\n", data);

        fflush(stdout);
    } else {
        int len;
        MPI_Recv(&len, 1 , MPI_INT, 0, 0, MPI_COMM_WORLD, &status);

        MPI_Recv(data, len , MPI_CHAR, 0, 1, MPI_COMM_WORLD, &status);
        data[len] = '\0';
        for(int i=0; i<len; i++){
            if(data[i] > 90){
                data[i] -= 32;
            } else {
                data[i] += 32;
            }
        }

        MPI_Ssend(data, len, MPI_CHAR, 0, 2, MPI_COMM_WORLD);
    }
    MPI_Finalize();
    if(rank == size-1) printf("220905390\n");
    return 0;
}
