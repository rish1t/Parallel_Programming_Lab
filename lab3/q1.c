#include "mpi.h"
#include <stdio.h>
int main(int argc, char *argv[])
{

    int rank, size, N, A[10], B[10], c, i;
    MPI_Init(&argc, &argv);
    MPI_Comm_rank(MPI_COMM_WORLD, &rank);
    MPI_Comm_size(MPI_COMM_WORLD, &size);
    if (rank == 0)
    {
        N = size;
        printf("Enter %d values:\n", N);

        for (i = 0; i < N; i++)
            scanf("%d", &A[i]);
    }
    MPI_Scatter(A, 1, MPI_INT, &c, 1, MPI_INT, 0, MPI_COMM_WORLD);
    printf("I have received %d in process %d\n", c, rank);

    int j = c - 1;
    while (j > 0)
    {
        c = c * j;
        j--;
    }

    MPI_Gather(&c, 1, MPI_INT, B, 1, MPI_INT, 0, MPI_COMM_WORLD);
    if (rank == 0)
    {
        sleep(3);
        int sum=0;
        printf("The Result gathered in the root \n");
        for (i = 0; i < N; i++){
            sum += B[i];
        }
        printf("%d\n", sum);
        printf("220905390");
           
    }
    MPI_Finalize();
    return 0;
}
