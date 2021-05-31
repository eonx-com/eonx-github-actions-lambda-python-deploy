#!/usr/bin/env bash
set -eo pipefail;

export AWS_ACCESS_KEY_ID=${1}
export AWS_SECRET_ACCESS_KEY=${2}
export AWS_DEFAULT_REGION=${3}
export LAMBDA_FUNCTION_NAME=${4}
export SOURCE_PATH=${5}
export AWS_ACCOUNT_ID=$(aws sts get-caller-identity | jq -r .Account)

error="0"
if [[ -z "${AWS_ACCESS_KEY_ID}" ]]; then
  echo "ERROR: Missing required AWS_ACCESS_KEY_ID value";
  error="1"
fi
if [[ -z "${AWS_SECRET_ACCESS_KEY}" ]]; then
  echo "ERROR: Missing required AWS_SECRET_ACCESS_KEY value";
  error="1"
fi
if [[ -z "${AWS_DEFAULT_REGION}" ]]; then
  echo "ERROR: Missing required AWS_DEFAULT_REGION value";
  error="1"
fi
if [[ -z "${LAMBDA_FUNCTION_NAME}" ]]; then
  echo "ERROR: Missing required LAMBDA_FUNCTION_NAME value";
  error="1"
fi
if [[ -z "${SOURCE_PATH}" ]]; then
  echo "ERROR: Missing required SOURCE_PATH value";
  error="1"
fi
if [[ "${error}" == "1" ]]; then
  exit 1;
fi

# Move into the source path
cd "${SOURCE_PATH}";

# Install Python dependencies if we find a 'requirements.txt' file in the source folder
if [[ -f "./requirements.txt" ]]; then
  echo "Installing Python packages...";
  pip install -r requirements.txt -t .;
  # Remove the requirements file as it is no longer needed in the packaged ZIP
  rm requirements.txt
fi

# Compress the source and any dependencies we installed
echo "Creating deployment ZIP file...";
zip -r lambda.zip .;

# Deploy the function to AWS
echo "Updating Lambda function...";
aws lambda update-function-code \
  --function-name ${LAMBDA_FUNCTION_NAME} \
  --zip-file fileb://$(pwd)/lambda.zip;
