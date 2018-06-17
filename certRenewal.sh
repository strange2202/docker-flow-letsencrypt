#!/bin/sh

# Get CurrentScriptDirectory
local CurrentScriptDir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Import Script Modules
source "${CurrentScriptDir}/script-modules/globalVars.sh"
source "${CurrentScriptDir}/script-modules/awsFunctions.sh"
source "${CurrentScriptDir}/script-modules/renewCertificates.sh"

# Init AWS Settings
initAws true > /var/log/dockeroutput.log;

# Run Certificate Renewal
renewCerts;
