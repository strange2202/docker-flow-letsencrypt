declare -A awsCerts=();

function initAws {
  loadSettingsOnly=$1;

  # Load From Secrets or ENV
  if [ -e /run/secrets/AWS_ACCESS_KEY ]; then
    local awsAccessKey=$(cat /run/secrets/AWS_ACCESS_KEY);
  else
    local awsAccessKey=$AWS_ACCESS_KEY;
  fi

  if [ -e /run/secrets/AWS_SECRET_KEY ]; then
    local awsSecretKey=$(cat /run/secrets/AWS_SECRET_KEY);
  else
    local awsSecretKey=$AWS_SECRET_KEY;
  fi

  if [ -e /run/secrets/AWS_DEFAULT_REGION ]; then
    local awsDefaultRegion=$(cat /run/secrets/AWS_DEFAULT_REGION);
  else
    local awsDefaultRegion=$AWS_DEFAULT_REGION;
  fi

  # Check Values
  runAws=false;
  if [ -z ${awsAccessKey} ]; then
    runAws=true;
    return 0;
  fi

  if $loadSettingsOnly ; then
    return 0;
  fi;

  if [ -z ${awsSecretKey} ]; then
    printf "${PRINT_COLOR_RED}AWS_SECRET_KEY is empty!${PRINT_COLOR_NC}\n"
    exit 1
  fi

  if [ -z ${awsDefaultRegion} ]; then
    printf "${PRINT_COLOR_RED}AWS_DEFAULT_REGION is empty!${PRINT_COLOR_NC}\n"
    exit 1
  fi

  printf "Initializing AWS ...\n";

  # Configure AWS
  aws configure set AWS_ACCESS_KEY_ID ${awsAccessKey}
  aws configure set AWS_SECRET_ACCESS_KEY ${awsSecretKey}
  aws configure set default.region ${awsDefaultRegion}
}

function loadAwsCerts {
  if $runAws ; then
    printf "AWS_ACCESS_KEY not set, skipping 'loadAwsCerts'\n"
    return 0;
  fi

  printf "Loading Certificates from AWS ...\n";

  aws acm list-certificates --no-paginate | jq -c '.CertificateSummaryList[]' > ./awsCerts.json
}

function createAwsCert {
  local domain=$1;

  if $runAws ; then
    printf "AWS_ACCESS_KEY not set, skipping 'createAwsCert'\n"
    return 0;
  fi

  # Check if Certificate Exists for the Domain
  # If so, then update existing or add new
  awsCertArn=${awsCerts[$domain]};

  if [ -z ${awsCertArn} ]; then
    awsCertArn=$(aws acm import-certificate \
      --certificate $(<cert.pem) \
      --private-key $(<privkey.pem) \
      --certificate-chain $(<chain.pem) | jq '.CertificateArn');

    awsCerts[$domain]=$awsCertArn;
  else
    aws acm import-certificate \
      --certificate-arn ${awsCertArn} \
      --certificate $(<cert.pem) \
      --private-key $(<privkey.pem) \
      --certificate-chain $(<chain.pem);
  fi; 
}

function loadAwsCertsFile {
  if $runAws ; then
    printf "AWS_ACCESS_KEY not set, skipping 'loadAwsCertsFile'\n"
    return 0;
  fi

  printf "Loading AWS Certificates variable data ...\n";

  for cert in $(cat ./awsCerts.json); do
    certDomain=$(echo $cert | jq -r '.DomainName');
    certArn=$(echo $cert | jq -r '.CertificateArn');
    
    awsCerts[$certDomain]=$certArn;
  done
}

function saveAwsCertsFile {
  if $runAws ; then
    printf "AWS_ACCESS_KEY not set, skipping 'saveAwsCertsFile'\n"
    return 0;
  fi

  printf "Saving AWS Certificates variable data ...\n";

  rm ./awsCerts.json
  for awsCertDomain in "${!awsCerts[@]}"; do
    echo "{\"CertificateArn\": \"${awsCerts[$awsCertDomain]}\", \"DomainName\": \"${awsCertDomain}\"}" | jq -c '.' >> ./awsCerts.json
  done
}
