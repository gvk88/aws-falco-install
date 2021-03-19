# Customise AMI

This repo is use for installing falco amis for kubernetes.

## Building the AMI

A Makefile is provided to build the AMI, but it is just a small wrapper around invoking Packer directly. You can initiate the build process by running the following command in the root of this repository:

```bash
make <kubernetes_version>
```

The Makefile reads the latest recommended Amazon EKS optimized AMI from AWS Systems Manager Parameter Store. The latest recommended AMI is the base image the Kubernetes Amazon EKS optimized image is built from. Once the base AMI ID is retrieved the Makefile runs Packer with the packer-eks-ami.json build specification template and the amazon-ebs builder. An instance is launched and the Packer Shell Provisioner runs the install-worker.sh script on the instance to install software and perform other necessary configuration tasks. Then, Packer creates an AMI from the instance and terminates the instance after the AMI is created.

If the build succeeds the resulting AMI ID is written to AWS Systems Manager Parameter Store with the parameter name `/aws/service/Kubernetes/optimized-ami/${ver}/${arch}/recommended/image_id`. This enables consumption of the new optimized AMI by other processes and configurations by referencing the AMI ID parameter.

## Scripts

Parse a Packer.io manifest file for image metadata and store the AMI ID for all supported AWS Regions in AWS Systems Manager Parameter Store. This script is executed as part of the Packer.io image build process. If the build completes successfully the resulting AMI ID is stored as parameter before the build process exits.

```text
 Usage: scripts/publish.bash -f manifest
    -f,               Packer.io manifest.json file.
    -h,               Show this message.
```

## Jenkins

A [Jenkins job] is used  for building and publishing new AMI on updates to this repository
