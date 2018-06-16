createDomainFolders() {
  #maximum number of retries
  local MAXRETRIES=5

  #timeout
  local TIMEOUT=5

  #common arguments
  local args=("--no-self-upgrade" "--no-bootstrap" "--standalone" "--non-interactive" "--expand" "--keep-until-expiring" "--email" "$CERTBOT_EMAIL" "--agree-tos" "--preferred-challenges" "http-01" "--rsa-key-size" "4096" "--redirect" "--hsts" "--staple-ocsp")

  #if we are in a staging enviroment append the staging argument, the staging argument
  #was previously set to an empty string if the staging enviroment was not used
  #but this confuses cert-auto and should hence not be used
  if [ "$CERTBOTMODE" ]; then
    printf "${PRINT_COLOR_RED}Staging environment of Let's Encrypt is activated! The generated certificates won't be trusted. But you will not reach Let’s Encrypt's rate limits.${PRINT_COLOR_NC}\n";
    args+=("--staging");
  fi

  #we need to be careful and don't reach the rate limits of Let's Encrypt https://letsencrypt.org/docs/rate-limits/
  #Let's Encrypt has a certificates per registered domain (20 per week) and a names per certificate (100 subdomains) limit
  #so we should create ONE certificiates for a certain domain and add all their subdomains (max 100!)

  for var in $(env | grep -P 'DOMAIN_\d+' | sed  -e 's/=.*//'); do
    cur_domains=${!var};

    declare -a arr=$cur_domains;

    DOMAINDIRECTORY="/etc/letsencrypt/live/${arr[0]}";
    dom="";
    for i in "${arr[@]}"
    do
      let exitcode=tries=0
      until [ $tries -ge $MAXRETRIES ]
      do
        tries=$[$tries+1]
        certbot-auto certonly --dry-run "${args[@]}" -d "$i" | grep -q 'The dry run was successful.' && break
        exitcode=$?

        if [ $tries -eq $MAXRETRIES ]; then
          printf "${PRINT_COLOR_RED}Unable to verify domain ownership after ${tries} attempts.${NC}\n"
        else
          printf "${PRINT_COLOR_RED}Unable to verify domain ownership, we try again in ${TIMEOUT} seconds.${NC}\n"
          sleep $TIMEOUT
        fi
      done

      if [ $exitcode -eq 0 ]; then
        printf "Domain $i successfully validated\n"
        dom="$dom -d $i"
      fi
    done

    #only if we have successfully validated at least a single domain we have to continue
    if [ -n "$dom" ]; then
      # check if DOMAINDIRECTORY exists, if it exists use --cert-name to prevent 0001 0002 0003 folders
      if [ -d "$DOMAINDIRECTORY" ]; then
        printf "\nUse certbot-auto certonly %s --cert-name %s\n" "${args[*]}" "${arr[0]}";
        certbot-auto certonly "${args[@]}" --cert-name "${arr[0]}" $dom
      else
        printf "\nUse certbot-auto certonly %s\n" "${args[*]}";
        certbot-auto certonly "${args[@]}" $dom
      fi
    fi

  done
}