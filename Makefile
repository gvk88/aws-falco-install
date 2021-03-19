aws_region ?= us-east-1
aws_access_key ?= ${AWS_ACCESS_KEY}
aws_secret_key ?= ${AWS_SECRET_KEY}
build_date = $(shell date +'%Y%m%d%H%M')
kubernetes_version ?= 1.16

arch ?= x86_64
ifeq ($(arch), arm64)
goss_arch ?= arm
instance_type ?= m6g.large
aws_linux_arch ?= amazon-linux-2-arm64
else
goss_arch ?= amd64
instance_type ?= m5.large
aws_linux_arch ?= amazon-linux-2
endif

ami_name ?= packer-eks-node-$(kubernetes_version)-$(aws_linux_arch)-v$(build_date)

# Lookup the given latest AWS EKS AMI ID to build from
source_ami_id ?= $(shell aws ssm get-parameter --name /aws/service/eks/optimized-ami/$(kubernetes_version)/$(aws_linux_arch)/recommended/image_id --region $(aws_region) --query "Parameter.Value" --output text)

.PHONY: init
init:
ifneq (,$(wildcard ./packer-provisioner-goss))
	@echo "Packer 'packer-provisioner-goss' plugin already exists"
else
	./provisioners/goss_plugin.bash
endif

.PHONY: clean
clean:
	rm -rf packer-provisioner-goss

.PHONY: validate
validate:
	@echo "Validating AMI config for version $(kubernetes_version) using base ami $(source_ami_id)"
	PACKER_LOG=1 packer validate \
						-var 'ami_name=${ami_name}' \
						-var 'goss_arch=${goss_arch}' \
					 	-var 'build_date=${build_date}' \
					 	-var 'aws_region=${aws_region}' \
					 	-var 'instance_type=${instance_type}' \
					 	-var 'source_ami_id=${source_ami_id}' \
						-var 'aws_linux_arch=${aws_linux_arch}' \
					 	-var 'kubernetes_version=${kubernetes_version}' \
						packer-eks-ami.json

.PHONY: ami
ami: validate
	@echo "Building AMI for version $(kubernetes_version) using base ami $(source_ami_id)"
	PACKER_LOG=1 packer build \
						-var 'ami_name=${ami_name}' \
						-var 'goss_arch=${goss_arch}' \
					 	-var 'build_date=${build_date}' \
					 	-var 'aws_region=${aws_region}' \
					 	-var 'instance_type=${instance_type}' \
					 	-var 'source_ami_id=${source_ami_id}' \
						-var 'aws_linux_arch=${aws_linux_arch}' \
					 	-var 'kubernetes_version=${kubernetes_version}' \
						packer-eks-ami.json

.PHONY: all
all: 1.16 1.17 1.18

1.16: init
	$(MAKE) ami kubernetes_version=1.16

1.17: init
	$(MAKE) ami kubernetes_version=1.17

1.18: init
	$(MAKE) ami kubernetes_version=1.18



