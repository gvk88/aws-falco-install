# Customise AMI

This repo is use for installing falco amis for kubernetes.

## Building the AMI

A Makefile is provided to build the AMI, but it is just a small wrapper around invoking Packer directly. You can initiate the build process by running the following command in the root of this repository:

```bash
make <kubernetes_version>
```

The Makefile reads the latest recommended Amazon EKS optimized AMI from AWS Systems Manager Parameter Store. The latest recommended AMI is the base image the Kubernetes Amazon EKS optimized image is built from. Once the base AMI ID is retrieved the Makefile runs Packer with the packer-eks-ami.json build specification template and the amazon-ebs builder. An instance is launched and the Packer Shell Provisioner runs the install-worker.sh script on the instance to install software and perform other necessary configuration tasks. Then, Packer creates an AMI from the instance and terminates the instance after the AMI is created.

Using custom shell scripts we install falco and also use goss plugin to test the installation.
## git hub

A [github action] is used  for building and publishing new AMI on updates to this repository
