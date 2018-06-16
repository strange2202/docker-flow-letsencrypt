renewCerts() {
  #times we tried curl
  local TRIES=0

  #maximum number of retries
  local MAXRETRIES=5

  #timeout
  local TIMEOUT=5

  printf "${PRINT_COLOR_GREEN}Renewing certificates today $(date) ...${PRINT_COLOR_NC}\n"

  # send current certificates to proxy - after that do a certbot renew round (which could take some seconds) and send updated certificates to proxy (faster startup with https when old certificates are still valid)
  for d in /etc/letsencrypt/live/*/ ; do
      #move to directory
      cd $d

      #get directory name (which is the name of the regular domain)
      folder=${PWD##*/}

      #concat certificates
      printf "old certificates for $folder will be send to proxy\n"
      cat cert.pem chain.pem privkey.pem > $folder.combined.pem

      #send to proxy, retry up to 5 times with a timeout of $TIMEOUT seconds

      #reset tries to 0
      TRIES=0
      exitcode=0
      until [ $TRIES -ge $MAXRETRIES ]
      do
        TRIES=$[$TRIES+1]
        curl --silent --show-error -i -XPUT \
            --data-binary @$folder.combined.pem \
            "$PROXY_ADDRESS:8080/v1/docker-flow-proxy/cert?certName=$folder.combined.pem&distribute=true" && break
        exitcode=$?
        if [ $TRIES -eq $MAXRETRIES ]; then
          printf "old certificate: ${PRINT_COLOR_RED}transmit failed after ${TRIES} attempts.${PRINT_COLOR_NC}\n"
        else
          printf "old certificate: ${PRINT_COLOR_RED}transmit failed, we try again in ${TIMEOUT} seconds.${PRINT_COLOR_NC}\n"
          sleep $TIMEOUT
        fi
      done

      if [ $exitcode -eq 0 ]; then
        printf "old certificates: proxy received $folder.combined.pem\n"
      fi
  done

  # Load AWS Certificate ARNS
  loadAwsCertsFile;

  #full path is needed or it is not started when run as cron

  #--no-bootstrap: prevent the certbot-auto script from installing OS-level dependencies
  #--no-self-upgrade: revent the certbot-auto script from upgrading itself to newer released versions
  /root/certbot-auto renew --no-bootstrap --no-self-upgrade

  printf "Docker Flow: Proxy DNS-Name: ${PRINT_COLOR_GREEN}$PROXY_ADDRESS${PRINT_COLOR_NC}\n";

  for d in /etc/letsencrypt/live/*/ ; do
      #move to directory
      cd $d

      #get directory name (which is the name of the regular domain)
      folder=${PWD##*/}
      printf "current folder name is: $folder\n"

      #concat certificates
      printf "concat certificates for $folder\n"
      cat cert.pem chain.pem privkey.pem > $folder.combined.pem
      printf "${PRINT_COLOR_GREEN}generated $folder.combined.pem${PRINT_COLOR_NC}\n"

      #send to proxy, retry up to 5 times with a timeout of $TIMEOUT seconds
      printf "${PRINT_COLOR_GREEN}transmit $folder.combined.pem to $PROXY_ADDRESS${PRINT_COLOR_NC}\n"

      #reset tries to 0
      TRIES=0

      exitcode=0
      until [ $TRIES -ge $MAXRETRIES ]
      do
        TRIES=$[$TRIES+1]
        curl --silent --show-error -i -XPUT \
            --data-binary @$folder.combined.pem \
            "$PROXY_ADDRESS:8080/v1/docker-flow-proxy/cert?certName=$folder.combined.pem&distribute=true" && break
        exitcode=$?

        if [ $TRIES -eq $MAXRETRIES ]; then
          printf "${PRINT_COLOR_RED}transmit failed after ${TRIES} attempts.${PRINT_COLOR_NC}\n"
        else
          printf "${PRINT_COLOR_RED}transmit failed, we try again in ${TIMEOUT} seconds.${PRINT_COLOR_NC}\n"
          sleep $TIMEOUT
        fi
      done

      if [ $exitcode -eq 0 ]; then
        printf "proxy received $folder.combined.pem\n"
      fi


      # Create AWS Certificate
      createAwsCert $folder;
  done


  # Resave AWS Certificate ARNS
  saveAwsCertsFile;

  printf "${PRINT_COLOR_GREEN}Renewal of certificates completed ...${PRINT_COLOR_NC}\n"
}