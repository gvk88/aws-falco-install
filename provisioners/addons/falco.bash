#!/usr/bin/env bash

set -o errexit

# install the dependencies
# set the variables
# run the driverkit executable
# falco version 0.27.0

if [ "$(arch)" != "x86_64" ]; then
        echo "unsupported cpu architecture. exiting."
        exit 0
fi

target="amazonlinux2"
kernel_release=$(uname -r)
kernel_version=$(uname -v|cut -b 2)
driver_version="5c0b863ddade7a45568c0ac97d037422c9efb750"
driver_location=/usr/share/falco

git clone https://github.com/jfarrell/driverkit.git --depth 1 --branch docker_flags
sed -i 's/GIT_COMMIT :=.*/GIT_COMMIT := latest/g' driverkit/Makefile
make -C driverkit
mkdir -p "$driver_location"
driverkit/_output/bin/driverkit docker \
  --target="$target" \
  --kernelrelease="$kernel_release" \
  --kernelversion="$kernel_version" \
  --driverversion "$driver_version" \
  --output-module "$driver_location/falco_module.ko" \
  --output-probe "$driver_location/falco_probe.o" \
  --network host \
  --loglevel debug

cat >> "$driver_location/falco.version" << EOF
target=$target
kernel_release=$kernel_release
kernel_version=$kernel_version
driver_version=$driver_version
EOF