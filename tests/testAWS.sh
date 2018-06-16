#!/bin/sh

# Get CurrentScriptDirectory
CurrentScriptDir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Import Script Modules
source "${CurrentScriptDir}/../script-modules/globalVars.sh"
source "${CurrentScriptDir}/../script-modules/awsFunctions.sh"

# Initialize AWS
#TODO:

# Load Certificates from AWS
loadAwsCerts;

# Load AWS Certificate File
loadAwsCertsFile;

# Save AWS Certificates File
saveAwsCertsFile;

# Delete File
rm ./awsCerts.json