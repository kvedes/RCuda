# RCuda
A repository containing Cuda files written with the purpose of letting R utilize the power of Cuda.

All files are free to use, develop and redistrubute as long as proper credit is given. 

The files in the repository can be compiled in Ubuntu using the command:
nvcc -g -arch=sm_20 -I/usr/share/R/include/ --shared -Xcompiler -fPIC -o FILE.so FILE.cu

where FILE is the name of the relevant file. "-I/usr/share/R/include/" points the compiler to the location of the R header files, which are nessecary for compilation. If these files are located elsewhere one should change that part of the compile statement.
