#include <stdio.h>
#include <stdlib.h>
#include <string.h>

// a struct 
typedef struct
{
  int size;
  char *_string;
} string_t;

__global__ void string_append(string_t*, string_t*, string_t*);

int main(void)
{
  string_t *str1, *str2, *str3;
  size_t size1 = strlen("Hello, ");
  size_t size2 = sizeof("world!");
  
  // allocate memory for str1, str2, and str3 
  // and for their string members.
  cudaMallocManaged(&str1, sizeof(string_t));
  cudaMallocManaged(&(str1->_string), size1*sizeof(char));

  cudaMallocManaged(&str2, sizeof(string_t));
  cudaMallocManaged(&(str2->_string), size2*sizeof(char));

  cudaMallocManaged(&str3, sizeof(string_t));
  cudaMallocManaged(&(str3->_string), (size1+size2) * sizeof(char));
  
  // the CPU and the GPU can directly access memory allocated to str's 
  
  //In the following 4 lines the Host is accessing
  // the memory allocated via cudaMallocManaged().
  str1->size = size1;
  memcpy(str1->_string, "Hello, ", size1);

  str2->size = size2;
  memcpy(str2->_string, "world!", size2);
  
  // Since the kernel has been declared/defined with 
  // "__global__" keyword we are sure it will run on the device.
  // So the device will be accessing memory allocated via cudaMallocManaged().
  string_append<<<1, 1>>>(str1, str2, str3);

  // the device and the host should be synchronized
  // before we call printf in the host.
  cudaDeviceSynchronize();
  
  printf("%s\n", str3->_string);

  exit(EXIT_SUCCESS);
}



// a kernel to append 2 strings in a 3rd string.
__global__ void string_append(string_t *s1, string_t *s2, string_t *s3)
{
  memcpy(s3->_string, s1->_string, s1->size);
  memcpy(s3->_string+(s1->size), s2->_string, s2->size);
}
