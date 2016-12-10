# RCuda
A repository containing Cuda files written with the purpose of letting R utilize the power of Cuda. I am new to both C and Cuda C, so feel free to contribute or give feedback.

All files are free to use, develop and redistrubute as long as proper credit is given. 

The files in the repository can be compiled in Ubuntu using the command:
nvcc -g -arch=sm_20 -I/usr/share/R/include/ --shared -Xcompiler -fPIC -o FILE.so FILE.cu

where FILE is the name of the relevant file. "-I/usr/share/R/include/" points the compiler to the location of the R header files, which are nessecary for compilation. If these files are located elsewhere one should change that part of the compile statement.

Here an example of loading an running RCuda_exp on a vector containing the numbers 1 to 10:
```R
setwd("Folder containing RCuda_exp.so")
dyn.load("RCuda_exp.so")
.Call("RCuda_exp", 1:10)
```
