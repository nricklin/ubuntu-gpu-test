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
# Install docker:
curl -sSL https://get.docker.com/ | sudo sh

# Pull down the GPU test image:
sudo docker pull nricklin/ubuntu-gpu-test

# Run the test:
sudo docker run nricklin/ubuntu-gpu-test
```
