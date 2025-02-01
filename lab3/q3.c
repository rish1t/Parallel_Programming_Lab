#include <stdio.h>
#include <string.h>
#include <mpi.h>

int is_vowel(char c) {
    return (c == 'a' || c == 'e' || c == 'i' || c == 'o' || c == 'u' ||
            c == 'A' || c == 'E' || c == 'I' || c == 'O' || c == 'U');
}

int main(int argc, char *argv[]) {
    int rank, size, local_count = 0, total_count = 0;
    char string[100];
    int length, local_length;

    MPI_Init(&argc, &argv);
    MPI_Comm_rank(MPI_COMM_WORLD, &rank);
    MPI_Comm_size(MPI_COMM_WORLD, &size);

    if (rank == 0) {
        printf("Enter a string: ");
        scanf(" %s", string);
        length = strlen(string);
    }
    MPI_Bcast(&length, 1, MPI_INT, 0, MPI_COMM_WORLD);
    local_length = length / size;
    char local_string[local_length + 1];

    MPI_Scatter(string, local_length, MPI_CHAR, local_string, local_length, MPI_CHAR, 0, MPI_COMM_WORLD);
    local_string[local_length] = '\0';

    for (int i = 0; i < local_length; i++) {
        if (!is_vowel(local_string[i])) {
            local_count++;
        }
    }

    MPI_Reduce(&local_count, &total_count, 1, MPI_INT, MPI_SUM, 0, MPI_COMM_WORLD);

    if (rank == 0) {
        printf("Total non-vowels: %d\n", total_count);
        printf("220905390\n");
    }

    MPI_Finalize();
    return 0;
}