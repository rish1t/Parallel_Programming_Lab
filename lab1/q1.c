#include "mpi.h"
#include <stdio.h>
#include <math.h>
int main(int argc, char *argv[]){
	int rank, size, x=2;
	MPI_Init(&argc, &argv);
	MPI_Comm_rank(MPI_COMM_WORLD, &rank);
	MPI_Comm_size(MPI_COMM_WORLD, &size);
	double x1 = (double)x;
	double rank1 = (double)rank;
	double res = pow(x1, rank1);
	printf("Rank : %d, Power : %lf\n", rank, res);
	MPI_Finalize();
	return 0;
}