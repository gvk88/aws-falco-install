#!/usr/bin/env bash

set -o errexit

# install the dependencies
# falco version 0.27.0

if [ "$(arch)" != "x86_64" ]; then
        echo "unsupported cpu architecture. exiting."
        exit 0
fi
yum install -y go git
rpm --import https://falco.org/repo/falcosecurity-3672BA8F.asc
curl -s -o /etc/yum.repos.d/falcosecurity.repo https://falco.org/repo/falcosecurity-rpm.repo
yum -y install kernel-devel-$(uname -r)
yum -y install falco
