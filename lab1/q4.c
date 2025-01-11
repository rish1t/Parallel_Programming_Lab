#include "mpi.h"
#include <stdio.h>

int main(int argc, char *argv[]){
	int rank, size;
	MPI_Init(&argc, &argv);
	MPI_Comm_rank(MPI_COMM_WORLD, &rank);
	MPI_Comm_size(MPI_COMM_WORLD, &size);
	char str[50] = "Hello World";
	char s = str[rank]; 
	if(s > 90){
		s = s - 32;
	} else {
		s = s + 32;
	}
	printf("Rank:%d, %c toggled to %c\n", rank, str[rank], s);
	str[rank] = s;
	
	MPI_Finalize();
	return 0;
}