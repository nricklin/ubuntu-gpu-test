ubuntu-gpu-test
===============

Compile &amp; Run a test script on a GPU-enabled Ubuntu Docker container

This needs to run on a GPU-enabled machine.  Here's how to set one up on AWS:

Quick start: run on an Ubuntu AMI with CUDA 6.5 built by this guy:

http://tleyden.github.io/blog/2014/10/25/cuda-6-dot-5-on-aws-gpu-instance-running-ubuntu-14-dot-04/

*  AMI:  ami-2cbf3e44
*  Instance type: g2.2xlarge

Then get into the AMI and do this:
```bash
# Run this command which somehow makes the nvidia devices show up under /dev/:
/usr/local/cuda/samples/1_Utilities/deviceQuery/deviceQuery

# Install docker:
curl -sSL https://get.docker.com/ | sudo sh

# Pull down the GPU test image:
sudo docker pull nricklin/ubuntu-gpu-test

# Run the test:
DOCKER_NVIDIA_DEVICES="--device /dev/nvidia0:/dev/nvidia0 --device /dev/nvidiactl:/dev/nvidiactl --device /dev/nvidia-uvm:/dev/nvidia-uvm"
sudo docker run $DOCKER_NVIDIA_DEVICES nricklin/ubuntu-gpu-test
```

And here is the result if successful:
```bash
Number of CUDA Devices = 1
===========================
Device 0 has name GRID K520 with compute capability 3.0 canMapHostMemory=1
                           global memory = 3.9998
HostToDevice PCI Express BW=9.56939 GB/s
DeviceToHost PCI Express BW=8.86773 GB/s
```
