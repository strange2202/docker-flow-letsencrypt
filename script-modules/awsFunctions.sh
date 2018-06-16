declare -A awsCerts=();

function loadAwsCerts {
  printf "Loading Certificates from AWS ...\n";

  aws acm list-certificates --no-paginate | jq -c '.CertificateSummaryList[]' > ./awsCerts.json
}

function createAwsCert {
  local domain=$1;

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
  printf "Loading AWS Certificates variable data ...\n";

  for cert in $(cat ./awsCerts.json); do
    certDomain=$(echo $cert | jq -r '.DomainName');
    certArn=$(echo $cert | jq -r '.CertificateArn');
    
    awsCerts[$certDomain]=$certArn;
  done
}

function saveAwsCertsFile {
  printf "Saving AWS Certificates variable data ...\n";

  rm ./awsCerts.json
  for awsCertDomain in "${!awsCerts[@]}"; do
    echo "{\"CertificateArn\": \"${awsCerts[$awsCertDomain]}\", \"DomainName\": \"${awsCertDomain}\"}" | jq -c '.' >> ./awsCerts.json
  done
}
