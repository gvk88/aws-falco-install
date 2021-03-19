#!/usr/bin/env bash

set -o pipefail
set -o nounset
set -o errexit

os_type="$(uname)"
os_arch="amd64"
version="v3.0.0"
echo "install packer-provisioner-goss-$version-$os_type-$os_arch.tar.gz"
curl -L https://github.com/YaleUniversity/packer-provisioner-goss/releases/download/$version/packer-provisioner-goss-$version-$os_type-$os_arch.tar.gz -o packer-provisioner-goss.tar.gz
tar -xzf packer-provisioner-goss.tar.gz
chmod +x packer-provisioner-goss
rm -rf packer-provisioner-goss.tar.gz
