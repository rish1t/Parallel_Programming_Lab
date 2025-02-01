#include "mpi.h"
#include <stdio.h>
#include <stdlib.h>

void custom_err_handler(MPI_Comm *comm, int *error_code, ...) {
    char error_string[256];
    int error_len;

    MPI_Error_string(*error_code, error_string, &error_len);
    printf("Custom Error Handler: %s\n", error_string);

    exit(*error_code);
}

int main(int argc, char *argv[]) {
    int rank, size, i=5, sum;
    MPI_Errhandler errhandler;

    MPI_Init(&argc, &argv);
    
    MPI_Comm_create_errhandler(custom_err_handler, &errhandler);
    MPI_Comm_set_errhandler(MPI_COMM_WORLD, errhandler);

    if (MPI_Comm_rank(MPI_COMM_WORLD, &rank) != MPI_SUCCESS) {
        MPI_Abort(MPI_COMM_WORLD, 1);  // Trigger custom error handler
    }
    if (MPI_Comm_size(MPI_COMM_WORLD, &size) != MPI_SUCCESS) {
        MPI_Abort(MPI_COMM_WORLD, 2);  // Trigger custom error handler
    }

    if (size < 2) {
        printf("Error: Number of processes should be at least 2.\n");
        custom_err_handler(MPI_COMM_WORLD, &i);  // Trigger custom error handler
    }

    int fact = 1;
    int j = rank + 1;

    if (rank < 0) {
        printf("Error: Rank cannot be negative.\n");
        MPI_Abort(MPI_COMM_WORLD, 4);  // Trigger custom error handler
    }

    while (j > 0) {
        fact *= j;
        j--;
    }

    printf("Factorial for %d : %d\n", rank + 1, fact);

    if (rank == 1) {
        //printf("Simulating communication failure at rank 1...\n");
        // Simulate communication error by mismatched datatypes
        if (!MPI_Send(&fact, 1, MPI_CHAR, 0, 0, MPI_COMM_WORLD)) {
            custom_err_handler(MPI_COMM_WORLD, &rank);  // Trigger custom error handler
        }
    }

    if (MPI_Scan(&fact, &sum, 1, MPI_INT, MPI_SUM, MPI_COMM_WORLD) != MPI_SUCCESS) {
        MPI_Abort(MPI_COMM_WORLD, 6);  // Trigger custom error handler
    }

    if (sum < 0) {
        printf("Error: Unexpected negative sum detected.\n");
        MPI_Abort(MPI_COMM_WORLD, 7);  // Trigger custom error handler
    }

    // Simulate a datatype error (fault injection)
    if (rank == 0) {
        int fake_rank = 9999;
        if (MPI_Send(&fake_rank, 1, MPI_DOUBLE, 1, 0, MPI_COMM_WORLD) != MPI_SUCCESS) {
            MPI_Abort(MPI_COMM_WORLD, 8);  // Trigger custom error handler
        }
    }

    if (rank == size - 1) {
        printf("The Result gathered in the root\n");
        printf("Final sum: %d\n", sum);
    }

    MPI_Finalize();
    return 0;
}
