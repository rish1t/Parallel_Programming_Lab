#include <stdio.h>
#include <string.h>
#include <mpi.h>

int main(int argc, char *argv[]) {
    int rank, size;
    char str1[50], str2[50];
    int len1, len2, local_length;

    MPI_Init(&argc, &argv);
    MPI_Comm_rank(MPI_COMM_WORLD, &rank);
    MPI_Comm_size(MPI_COMM_WORLD, &size);

    if (rank == 0) {
        printf("Enter 1st string: ");
        scanf("%s", str1);
        printf("Enter 2nd string: ");
        scanf("%s", str2);
    }

    MPI_Bcast(str1, 50, MPI_CHAR, 0, MPI_COMM_WORLD);
    MPI_Bcast(str2, 50, MPI_CHAR, 0, MPI_COMM_WORLD);

    len1 = strlen(str1);
    len2 = strlen(str2);
    
    local_length = len1;

    char local_str[2 * local_length + 1];
    char local_result[2 * local_length + 1];

    MPI_Scatter(str1, local_length, MPI_CHAR, local_str, local_length, MPI_CHAR, 0, MPI_COMM_WORLD);
    MPI_Scatter(str2, local_length, MPI_CHAR, local_str + local_length, local_length, MPI_CHAR, 0, MPI_COMM_WORLD);

    local_str[2 * local_length] = '\0';

    for (int i = 0; i < local_length; i++) {
        local_result[2 * i] = local_str[i];
        local_result[2 * i + 1] = local_str[local_length + i];
    }
    local_result[2 * local_length] = '\0';

    char result[100];
    MPI_Gather(local_result, 2 * local_length, MPI_CHAR, result, 2 * local_length, MPI_CHAR, 0, MPI_COMM_WORLD);

    if (rank == 0) {
        printf("Resultant String: %s\n", result);
        printf("220905390\n");
    }

    MPI_Finalize();
    return 0;
}