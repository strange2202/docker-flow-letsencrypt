#!/bin/sh

# Get CurrentScriptDirectory
CurrentScriptDir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Import Script Modules
source "${CurrentScriptDir}/../script-modules/globalVars.sh"
source "${CurrentScriptDir}/../script-modules/awsFunctions.sh"

# Initialize AWS
AWS_ACCESS_KEY=$1;
AWS_SECRET_KEY=$2;
AWS_DEFAULT_REGION=$3;
initAws false;

# Load Certificates from AWS
loadAwsCerts;

# Load AWS Certificate File
loadAwsCertsFile;

# Save AWS Certificates File
saveAwsCertsFile;

# Delete File
if [ -e ./awsCerts.json ]; then
  rm ./awsCerts.json
fi