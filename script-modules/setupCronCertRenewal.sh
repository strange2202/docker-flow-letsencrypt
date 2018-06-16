function setupCronCertRenewal() {
  printf "Configuring cron for Certificate Renewal processing ...\n";

  if [ "$CERTBOTMODE" ]; then
    printf "SHELL=/bin/sh\nPATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin\nPROXY_ADDRESS=$PROXY_ADDRESS\nCERTBOTMODE=$CERTBOTMODE\n" > /etc/cron.d/certRenewal 
  else
    printf "SHELL=/bin/sh\nPATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin\nPROXY_ADDRESS=$PROXY_ADDRESS\n" > /etc/cron.d/certRenewal
  fi


  declare -a arr=$CERTBOT_CRON_RENEW;
  for i in "${arr[@]}"
  do
    printf "$i root /root/certRenewal.sh > /var/log/dockeroutput.log\n" >> /etc/cron.d/certRenewal
  done

  printf "\n" >> /etc/cron.d/certRenewal
}
