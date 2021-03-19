#!/usr/bin/env bash

set -o errexit

function die()
{
    BASE=$(basename -- "$0")
    echo -e "$BASE: error: $*" >&2
    exit 1
}

function checkAWSCLI()
{
    command -v aws >/dev/null 2>&1 || die "aws cli is required but not installed. Aborting. See https://docs.aws.amazon.com/cli/latest/userguide/installing.html"
}

function checkJQ()
{
    command -v jq >/dev/null 2>&1 || die "jq is required but not installed. Aborting. See https://stedolan.github.io/jq/download/"
}

function usage()
{
    echo " Usage: ${0} -f manifest
    -f,               Packer.io manifest.json file.
    -h,               Show this message.
    "
}

# updateSSM performs an AWS SSM put-parameter to update the parameter with the latest value
# parameters: version architecture region value
function updateSSM()
{
    name="/aws/service/Kubernetes/optimized-ami/$1/$2/recommended/image_id"
    echo "updating $name in region: $3"

    ssm_ver=$(aws ssm put-parameter --region "$3" --name "$name" --value "$4" --type String --overwrite --query "Version" --output text)
    echo "ssm parameter updated to version=$ssm_ver"
}

checkAWSCLI && checkJQ
FILE=
while getopts ":f:h" opt; do
    case $opt in
        h) usage && exit 1
        ;;
        f) FILE="$OPTARG"
        ;;
        \?) echo "Invalid option -$OPTARG" >&2 && exit 1
        ;;
    esac
done

# Read the AMI name, Kubernetes version, CPU architecture, and other metadata from the Packer.io
# manifest file. Those values are passed through from the build process as custom data.
arch=$(jq -r '.builds[-1].custom_data.aws_linux_arch' "$FILE")
ver=$(jq -r '.builds[-1].custom_data.kubernetes_version' "$FILE")
accounts=$(jq -r '.builds[-1].custom_data.accounts' "$FILE" | tr ',' '\n')

# Parse the AMI ID(s) from the Packer.io manifest file. The AMI ID(s) are in the form region:id. If
# the Packer.io copies the AMI to multiple regions the AMI ID(s) are in the form
# region:id,region:id,...
id=$(jq -r '.builds[-1].artifact_id' "$FILE")
ids=$(echo "$id" | tr ',' '\n')
for line in $ids; do
    region=$(echo "$line" | cut -d ":" -f1)
    value=$(echo "$line" | cut -d ":" -f2)
    updateSSM "$ver" "$arch" "$region" "$value"
done
