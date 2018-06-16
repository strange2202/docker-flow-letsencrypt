#use 16.04 lts, install certbot-auto to get newest certbot version
FROM ubuntu:16.04

#set default env variables
ENV DEBIAN_FRONTEND=noninteractive \
    CERTBOT_EMAIL="" \
    PROXY_ADDRESS="proxy" \
    CERTBOT_CRON_RENEW="('0 3 * * *' '0 15 * * *')" \
    PATH="$PATH:/root"

# Update/Upgrade apt-get
RUN  apt-get update -y && \
     apt-get upgrade -y && \
     apt-get dist-upgrade -y && \
     apt-get -y autoremove && \
     apt-get clean

# http://stackoverflow.com/questions/33548530/envsubst-command-getting-stuck-in-a-container
RUN apt-get -y install cron supervisor curl

# install certbot-auto
RUN curl -o /root/certbot-auto https://dl.eff.org/certbot-auto && \
    chmod a+x /root/certbot-auto && \
    /root/certbot-auto --version --non-interactive

# install aws-cli and jq
RUN apt-get install -y unzip && \
    curl "https://s3.amazonaws.com/aws-cli/awscli-bundle.zip" -o "awscli-bundle.zip" && \
    unzip awscli-bundle.zip && \
    rm awscli-bundle.zip && \
    ./awscli-bundle/install -i /usr/local/aws -b /usr/local/bin/aws && \
    rm -rf awscli-bundle && \
    apt-get install -y jq

# Clean Up apt-get
RUN apt-get purge -y --auto-remove gcc libc6-dev && \
    apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Add supervisord.conf
ADD configs/supervisord.conf /etc/supervisor/conf.d/supervisord.conf 

# Create Soft Link for dockeroutput.log
RUN ln -sf /proc/1/fd/1 /var/log/dockeroutput.log

# Add Script Modules
ADD script-modules /root/script-modules

# Create Empty cron file, which will be setup during startup
RUN touch /etc/cron.d/certRenewal && \
    chmod u+x /etc/cron.d/certRenewal

# Add certRenewal script
ADD ./certRenewal.sh /root/certRenewal.sh
RUN chmod u+x /root/certRenewal.sh

# Add Entrypoint script
ADD .ci/entrypoint.sh /root/entrypoint.sh
RUN chmod u+x /root/entrypoint.sh

# Run the command on container startup
CMD ["/root/entrypoint.sh"]

EXPOSE 80
