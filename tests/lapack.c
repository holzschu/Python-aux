#include <math.h>
#include <stdio.h>

extern void dpotrf_(const char *, const int *, double *, const int *, int *);
extern void dgesv_(const int *, const int *, double *, const int *, int *, double *, const int *, int *);
extern void dsyev_(const char *, const char *, const int *, double *, const int *, double *, double *, const int *, int *);
extern void runtime_probe(void);

int main(void) {
    runtime_probe();
    const int n = 2, nrhs = 1;
    int info, pivots[2];
    double positive[] = {4, 2, 2, 5};
    dpotrf_("L", &n, positive, &n, &info);
    if (info || fabs(positive[0] - 2) > 1e-12 || fabs(positive[1] - 1) > 1e-12 || fabs(positive[3] - 2) > 1e-12) {
        fprintf(stderr, "Cholesky failed: info=%d\n", info);
        return 1;
    }
    double matrix[] = {3, 1, 1, 2}, rhs[] = {9, 8};
    dgesv_(&n, &nrhs, matrix, &n, pivots, rhs, &n, &info);
    if (info || fabs(rhs[0] - 2) > 1e-12 || fabs(rhs[1] - 3) > 1e-12) {
        fprintf(stderr, "Solve failed: info=%d\n", info);
        return 1;
    }
    const int lwork = 8;
    double symmetric[] = {2, 1, 1, 2}, eigenvalues[2], work[8];
    dsyev_("N", "U", &n, symmetric, &n, eigenvalues, work, &lwork, &info);
    if (info || fabs(eigenvalues[0] - 1) > 1e-12 || fabs(eigenvalues[1] - 3) > 1e-12) {
        fprintf(stderr, "Fortran eigensolver failed: info=%d\n", info);
        return 1;
    }
    puts("LAPACK Cholesky, solve and Fortran dsyev passed");
    return 0;
}
