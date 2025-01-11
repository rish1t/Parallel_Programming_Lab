#include "mpi.h"
#include <stdio.h>

int main(int argc, char *argv[]){
	int rank, size;
	MPI_Init(&argc, &argv);
	MPI_Comm_rank(MPI_COMM_WORLD, &rank);
	MPI_Comm_size(MPI_COMM_WORLD, &size);
	if(rank%2==0){
		if (rank == 0 || rank == 1) {
        	printf("Rank: %d\t Factorial: %d\n", rank, 1);
        	return 0;
   		}
    	int result = 1;
    	for (int i = 2; i <= rank; i++) {
        	result *= i;
    	}
    	printf("Rank: %d\t Factorial: %d\n", rank, result);
	} else { 
		int t1 = 0, t2 = 1, nextTerm;
    	printf("Rank: %d\t Fibonacci: ", rank);
    	for (int i = 1; i <= rank; ++i) {
        	printf("%d ", t1);
        	nextTerm = t1 + t2;
        	t1 = t2;
        	t2 = nextTerm;
    	}
    	printf("\n");
	}
	MPI_Finalize();
	return 0;
}