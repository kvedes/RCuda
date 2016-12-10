#include <cuda.h>
#include <stdlib.h>
#include <Rinternals.h>    
#include <R.h>

// treat it as C code
extern "C" {
  SEXP vadd(SEXP x, SEXP y);
}

__global__ void add( double *a, double *b, double *c, int n )
{
  int tid = threadIdx.x + blockIdx.x * blockDim.x;
  // handle the data at this index
  while (tid < n) {
    c[tid] = a[tid] + b[tid];
    tid += blockDim.x * gridDim.x;
  }
  //printf("Value of *ip variable: %f\n", a[tid] );

}


SEXP vadd(SEXP x, SEXP y) {
  SEXP res;
  int nx;
  nx = length(x);

  PROTECT(res = allocVector(REALSXP,nx));
  
  // Turn vectors into C objects
  double *h_x = REAL(x);
  double *h_y = REAL(y);
  double *h_res = REAL(res);

  
  //printf("Value of x_0 variable: %f\n", h_x[0] );
  
  // Create pointers for device
  double *d_x, *d_y, *d_res; // Pointer for the device (GPU)
    
  // Allocate memory on GPU
  int bytes = nx * sizeof(double);
  cudaMalloc(&d_x, bytes );
  cudaMalloc(&d_y, bytes );
  cudaMalloc(&d_res, bytes );

  // Copy vectors x, y and res to GPU
  cudaMemcpy( d_x, h_x, bytes, cudaMemcpyHostToDevice );
  cudaMemcpy( d_y, h_y, bytes, cudaMemcpyHostToDevice );
  
  // Set number of operations
  // Run code
  add<<<128,128>>>(d_x, d_y, d_res, nx);
  //add<<<nx,1>>>(d_x, d_y, d_res, nx);

  // Load result back from GPU
  cudaMemcpy( h_res, d_res, bytes, cudaMemcpyDeviceToHost );

  // Free memory on the GPU
  cudaFree( d_x );
  cudaFree( d_y );
  cudaFree( d_res );

  // Unprotect res. Allows R to clean it up.
  UNPROTECT(1);
  
  return res;
}
