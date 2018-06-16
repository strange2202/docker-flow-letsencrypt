#!/bin/sh

if [ -z $CERTBOT_EMAIL ]; then
    printf "CERTBOT_EMAIL is empty!"
    exit 1
fi

# Get CurrentScriptDirectory
local CurrentScriptDir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Import Script Modules
source "${CurrentScriptDir}/script-modules/globalVars.sh"
source "${CurrentScriptDir}/script-modules/awsFunctions.sh"
source "${CurrentScriptDir}/script-modules/createDomainFolders.sh"
source "${CurrentScriptDir}/script-modules/setupCronCertRenewal.sh"
source "${CurrentScriptDir}/script-modules/renewCerts.sh"

# Start up Message
printf "${PRINT_COLOR_GREEN}Docker Flow: Let's Encrypt starting ...${PRINT_COLOR_NC}\n";
printf "We will use $CERTBOT_EMAIL for certificate registration with certbot. This e-mail is used by Let's Encrypt when you lose the account and want to get it back.\n";

# Initialize AWS
#TODO:

# Load Certificates from AWS
loadAwsCerts > /var/log/dockeroutput.log;

# Create Domain Folders
createDomainFolders > /var/log/dockeroutput.log;

# Setup Cron
setupCronCertRenewal > /var/log/dockeroutput.log;

# Run Certificate Renewal, to ensure all certificates are created or refreshed if needed
renewCerts > /var/log/dockeroutput.log;

# Start supervisord (which starts and monitors cron)
printf "\033[0;31mStarting supervisord (which starts and monitors cron) \033[0m\n"
/usr/bin/supervisord -c /etc/supervisor/conf.d/supervisord.conf
