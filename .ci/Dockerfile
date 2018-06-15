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
RUN apt-get -y install cron supervisor curl && \
    apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# install certbot-auto
RUN curl -o /root/certbot-auto https://dl.eff.org/certbot-auto && \
    chmod a+x /root/certbot-auto && \
    /root/certbot-auto --version --non-interactive && \
    apt-get purge -y --auto-remove gcc libc6-dev && \
    apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# install aws-cli
RUN apt-get install -y unzip && \
    curl "https://s3.amazonaws.com/aws-cli/awscli-bundle.zip" -o "awscli-bundle.zip" && \
    unzip awscli-bundle.zip && \
    rm awscli-bundle.zip && \
    ./awscli-bundle/install -i /usr/local/aws -b /usr/local/bin/aws && \
    aws --version

# Add supervisord.conf
ADD configs/supervisord.conf /etc/supervisor/conf.d/supervisord.conf 

# Add certbot and make it executable
ADD scripts/certbot.sh /root/certbot.sh
RUN chmod u+x /root/certbot.sh

ADD scripts/renewAndSendToProxy.sh /root/renewAndSendToProxy.sh
RUN chmod u+x /root/renewAndSendToProxy.sh

RUN ln -sf /proc/1/fd/1 /var/log/dockeroutput.log

# Add symbolic link in cron.daily directory without ending (important!)
ADD cron.d/renewcron /etc/cron.d/renewcron
RUN chmod u+x /etc/cron.d/renewcron

ADD .ci/entrypoint.sh /root/entrypoint.sh
RUN chmod u+x /root/entrypoint.sh

# Run the command on container startup
CMD ["/root/entrypoint.sh"]

EXPOSE 80
