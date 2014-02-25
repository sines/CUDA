#include"cuda_runtime.h"
#include"device_launch_parameters.h"

#define imin(a,b) (a<b?a:b)

const int N = 33 * 1024;
const int threadsPerBlock = 256;
const int blocksPerGrid = imin(32, (N + threadsPerBlock -1) / threadsPerBlock);
__global__ void dot(float *a, float *b, float *c)
{
	__shared__ float cache[threadsPerBlock];
	int tid = threadIdx.x + blockIdx.x * blockDim.x;
	int cacheIndex = threadIdx.x;
	
	float temp = 0;
	
	while(tid < N)
	{
		temp += a[tid] * b[tid];
		tid += blockDim.x * gridDim.x;
	}

	cache[cacheIndex] = temp;
	__syncthreads();

	int i = blockDim.x / 2;
	while(i != 0)
	{
		if(cacheIndex < i)
		{
			cache[cacheIndex] +=  cache[cacheIndex + i];
			__syncthreads();
			i /= 2;
		}
		if(cacheIndex == 0)
		{
			c[blockIdx.x] = cache[0];
		}
	}
}

int main(void)
{
	float *a, *b, c, *partial_c;
	float *dev_a, *dev_b, *dev_partial_c;

	a = (float*)malloc(N*sizeof(float));
	b = (float*)malloc(N*sizeof(float));
	partial_c = (float*)malloc(blocksPerGrid * sizeof(float));
	
}
