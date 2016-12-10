#include <cuda.h>
#include <stdlib.h>
#include <Rinternals.h>    
#include <R.h>
#include <math.h>

// treat it as C code
extern "C" {
  SEXP vexp(SEXP x);
}

__global__ void dexp( double *a, double *b, int n )
{
  int tid = threadIdx.x + blockIdx.x * blockDim.x;
  // handle the data at this index
  while (tid < n) {
    b[tid] = exp(a[tid]);
    tid += blockDim.x * gridDim.x;
  }
  //printf("Value of *ip variable: %f\n", a[tid] );

}


SEXP vexp(SEXP x) {
  SEXP res;
  int nx;
  nx = length(x);

  PROTECT(res = allocVector(REALSXP,nx));
  
  // Turn vectors into C objects
  double *h_x = REAL(x);
  double *h_res = REAL(res);
  
  // Create pointers for device
  double *d_x, *d_res; // Pointer for the device (GPU)
    
  // Allocate memory on GPU
  int bytes = nx * sizeof(double);
  cudaMalloc(&d_x, bytes );
  cudaMalloc(&d_res, bytes );

  // Copy vectors x, y and res to GPU
  cudaMemcpy( d_x, h_x, bytes, cudaMemcpyHostToDevice );
  
  // Set number of operations
  // Run code
  dexp<<<256,256>>>(d_x, d_res, nx);

  // Load result back from GPU
  cudaMemcpy( h_res, d_res, bytes, cudaMemcpyDeviceToHost );

  // Free memory on the GPU
  cudaFree( d_x );
  cudaFree( d_res );

  // Unprotect res. Allows R to clean it up.
  UNPROTECT(1);
  
  return res;
}
