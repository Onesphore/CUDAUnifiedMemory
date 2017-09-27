#include <stdio.h>
#include <stdlib.h>

typedef struct
{
  int size;
  char *_string;
} string_t;

__global__ void string_append(string_t*, string_t*, string_t*);

int main(void)
{
  int size;

  string_t *str1_host = (string_t *)malloc(sizeof(string_t));
  char _string1[] = "Hello, ";
  size = sizeof(_string1);
  str1_host->size = size;
  str1_host->_string = (char *)malloc(size * sizeof(char));
  memcpy(str1_host->_string, _string1, size);


  string_t *str2_host = (string_t *)malloc(sizeof(string_t));
  char _string2[] = "world!\n";
  size = sizeof(_string2);
  str1_host->size = size;
  str1_host->_string = (char *)malloc(size * sizeof(char));
  memcpy(str1_host->_string, _string2, size);

  string_t *result_host = (string_t *)malloc(sizeof(string_t)); 
  result_host->size = str1_host->size+str2_host->size;
  result_host->_string = (char *)malloc(result_host->size * result_host->size);
   
  string_t *str1_device;
  
  string_t *str2_device;
  string_t *result_device;
  

  // allocate memory on global memory (device).
  cudaMalloc(&str1_device, sizeof(string_t));
  char *string1_device;
  cudaMalloc(&string1_device, str1_host->size);
  //cudaMalloc(&(str1_device->_string), str1_host->size)  

  cudaMalloc(&str2_device, sizeof(string_t));
  char *string2_device;
  cudaMalloc(&string2_device, str2_host->size);
  //cudaMalloc(&(str2_device->_string), str2_host->size);

  cudaMalloc(&result_device, sizeof(string_t));
  char *res_string_device;
  cudaMalloc(&res_string_device, result_host->size);
  cudaMemcpy(&(result_device->_string), &res_string_device, sizeof(char *),
  cudaMemcpyDeviceToDevice);
  //cudaMalloc(&(result_device->_string), result_host->size);

  // copy data (str1_host and str2_host) to 
  // global memory (device). 
  cudaMemcpy(str1_device, str1_host, sizeof(string_t), cudaMemcpyHostToDevice);
  cudaMemcpy(string1_device, str1_host->_string, str1_host->size, 
  cudaMemcpyHostToDevice);
  cudaMemcpy(&(str1_device->_string), &string1_device, sizeof(char *), 
  cudaMemcpyHostToDevice);

  //cudaMemcpy(str1_device->_string, str1_host->_string, str1_host->size,
  //cudaMemcpyHostToDevice);
  
  cudaMemcpy(str2_device, str2_host, sizeof(string_t), cudaMemcpyHostToDevice);
  cudaMemcpy(string2_device, str2_host->_string, str2_host->size, 
  cudaMemcpyHostToDevice);
  cudaMemcpy(&(str2_device->_string), &string2_device, sizeof(char *), 
  cudaMemcpyHostToDevice);

  //cudaMemcpy(str2_device, str2_host, str2_host->size, 
  //cudaMemcpyHostToDevice);

  // append str1 and str2 in result (it's done on the device)
  string_append<<<1,1>>>(str1_device, str2_device, result_device);
  
  // copy the result back to the CPU memory
  cudaMemcpy(result_host->_string, result_device->_string, result_host->size, 
  cudaMemcpyDeviceToHost);

  // check the result on the CPU. 
  // It should print "Hello, world!."
  printf("%s", result_host->_string);  


  exit(EXIT_SUCCESS);
}

__global__ void string_append(string_t* str1, string_t* str2, string_t *str3)
{
  memcpy(str3->_string, str1->_string, str1->size);
  memcpy(str3->_string+(str1->size), str2->_string, str2->size);
}

