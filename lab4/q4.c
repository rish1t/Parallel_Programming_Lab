#include <mpi.h>
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
int main(int argc, char *argv[]) {
    int r, s, n;
    char str[100], local_str[100] = "", final_str[500] = "";
    MPI_Init(&argc, &argv);
    MPI_Comm_rank(MPI_COMM_WORLD, &r);
    MPI_Comm_size(MPI_COMM_WORLD, &s);
    if (!r) {
        printf("Enter a word: ");
        scanf("%s", str);
        n = strlen(str);
        if (n <= 0) {
            printf("Error: str word cannot be empty.\n");
            MPI_Abort(MPI_COMM_WORLD, 1);
        }
        if (s > n) {
            printf("Error: Number of processes exceeds the length of the str word.\n");
            MPI_Abort(MPI_COMM_WORLD, 1);
        }
    }
    MPI_Bcast(&n, 1, MPI_INT, 0, MPI_COMM_WORLD);
    MPI_Bcast(str, 100, MPI_CHAR, 0, MPI_COMM_WORLD);
    if (r < n) {
        char local_char = str[r];
        for (int i = 0; i <= r; i++) {
            local_str[i] = local_char;
        }
    }
    MPI_Gather(local_str, 100, MPI_CHAR, final_str, 100, MPI_CHAR, 0, MPI_COMM_WORLD);
    if (r == 0) {
        char final_result[500] = "";
        for (int i = 0; i < n; i++) {
            strcat(final_result, &final_str[i * 100]);
        }
        printf("Transformed string: %s\n", final_result);
    }    
    MPI_Finalize();
    return 0;
}