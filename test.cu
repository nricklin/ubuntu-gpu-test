#include <cuda_runtime.h>
#include <stdlib.h>
#include <stdio.h>

#ifndef USE_MALLOC_HOST
#define USE_MALLOC_HOST
#endif
#undef USE_MALLOC_HOST

#define CUDA_SAFE_CALL(err)  __cudaSafeCall(err,__FILE__,__LINE__)

inline void __cudaSafeCall(cudaError_t err,const char *file, const int line) {
  if(cudaSuccess != err) {
    printf("%s(%i) : cudaSafeCall() Runtime API error : %s.\n",
           file, line, cudaGetErrorString(err) );
    exit(-1);
  }
}

int main(int argc, char * argv[]) {
  int numDevs=0, i, j, N, nBytes;
  cudaError_t err;
  cudaDeviceProp prop;
  cudaEvent_t start, stop;
  float *x_cpu, *y_cpu, *x_gpu;
  float dt,totalDtTo=0.0,totalDtFrom=0.0;

  /* create events */
  CUDA_SAFE_CALL(cudaEventCreate(&start));
  CUDA_SAFE_CALL(cudaEventCreate(&stop));

  N = atoi(argv[1]);
  nBytes = N*sizeof(float);
#ifdef USE_MALLOC_HOST
  CUDA_SAFE_CALL(cudaMallocHost((void**)&x_cpu,nBytes));
  CUDA_SAFE_CALL(cudaMallocHost((void**)&y_cpu,nBytes));
#else
  x_cpu = (float *) malloc(nBytes);
  y_cpu = (float *) malloc(nBytes);
#endif

  for (i=0; i<N; ++i) {
    x_cpu[i] = 1.0*i;
  }

  CUDA_SAFE_CALL(cudaGetDeviceCount(&numDevs));
  printf("Number of CUDA Devices = %d\n",numDevs);
  printf("===========================\n");

  for (i=0; i<numDevs; ++i) {
    CUDA_SAFE_CALL(cudaSetDevice(i));
    CUDA_SAFE_CALL(cudaMalloc((void**)&x_gpu,nBytes));
#ifndef USE_MALLOC_HOST
    CUDA_SAFE_CALL(cudaHostRegister(x_cpu, nBytes, cudaHostRegisterMapped));
    CUDA_SAFE_CALL(cudaHostRegister(y_cpu, nBytes, cudaHostRegisterMapped));
#endif

    CUDA_SAFE_CALL(cudaGetDeviceProperties(&prop,i));
    printf("Device %d has name %s with compute capability %d.%d canMapHostMemory=%d\n",i,prop.name,prop.major,prop.minor,prop.canMapHostMemory);
    printf("                           global memory = %1.5g\n",1.0*prop.totalGlobalMem/(1024*1024*1024));

    dt=0.0;
    CUDA_SAFE_CALL(cudaEventRecord(start, 0));
    for (j=0; j<100; ++j) {
      CUDA_SAFE_CALL(cudaMemcpy(x_gpu, x_cpu, nBytes, cudaMemcpyHostToDevice));
    }
    CUDA_SAFE_CALL(cudaEventRecord(stop, 0));
    CUDA_SAFE_CALL(cudaEventSynchronize(stop));
    CUDA_SAFE_CALL(cudaEventElapsedTime(&dt,start,stop));
    totalDtTo+=dt;

    dt=0.0;
    CUDA_SAFE_CALL(cudaEventRecord(start, 0));
    for (j=0; j<100; ++j) {
      CUDA_SAFE_CALL(cudaMemcpy(y_cpu, x_gpu, nBytes, cudaMemcpyDeviceToHost));
    }
    CUDA_SAFE_CALL(cudaEventRecord(stop, 0));
    CUDA_SAFE_CALL(cudaEventSynchronize(stop));
    CUDA_SAFE_CALL(cudaEventElapsedTime(&dt,start,stop));
    totalDtFrom+=dt;
    
    totalDtTo*=.001;
    totalDtFrom*=.001;

    printf("HostToDevice PCI Express BW=%g GB/s\n",100.0*nBytes/(1024*1024*1024)/totalDtTo);
    printf("DeviceToHost PCI Express BW=%g GB/s\n",100.0*nBytes/(1024*1024*1024)/totalDtFrom);

    totalDtTo=0.0;
    totalDtFrom=0.0;
#ifndef USE_MALLOC_HOST
    CUDA_SAFE_CALL(cudaHostUnregister(x_cpu));
    CUDA_SAFE_CALL(cudaHostUnregister(y_cpu));
#endif
    CUDA_SAFE_CALL(cudaFree(x_gpu));
  }

#ifndef USE_MALLOC_HOST
  free(x_cpu);
  free(y_cpu);
#else
  CUDA_SAFE_CALL(cudaFreeHost(x_cpu));
  CUDA_SAFE_CALL(cudaFreeHost(y_cpu));
#endif

  /* destroy events */
  CUDA_SAFE_CALL(cudaEventDestroy(start));
  CUDA_SAFE_CALL(cudaEventDestroy(stop));
  return 0;
}
