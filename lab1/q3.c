#include "mpi.h"
#include <stdio.h>

int main(int argc, char *argv[]){
	int rank, size, c;
	MPI_Init(&argc, &argv);
	MPI_Comm_rank(MPI_COMM_WORLD, &rank);
	MPI_Comm_size(MPI_COMM_WORLD, &size);
	int a=4, b=5;
	switch(rank){
		case 0 : c = a-b;
				printf("Result of a-b is %d\n", c);
				break;
		case 1 : c = a+b;
				printf("Result of a+b is %d\n", c);
				break;
		case 2 : c = a*b;
				printf("Result of a*b is %d\n", c);
				break;
		case 3 : c = a/b;
				printf("Result of a/b is %d\n", c);
				break;
		case 4 : c = a%b;
				printf("Result of a mod b is %d\n", c);
				break; 	
	}
	MPI_Finalize();
	return 0;
}