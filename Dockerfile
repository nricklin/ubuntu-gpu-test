FROM nricklin/ubuntu-gpu-docker
MAINTAINER Nate Ricklin <nate.ricklin@gmail.com>

# Copy in test program
ADD test.cu /test.cu

# Compile test program
RUN nvcc -arch=sm_30 test.cu

# Execute test
CMD ./a.out 1000000
