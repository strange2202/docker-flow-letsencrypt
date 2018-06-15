#use 16.04 lts, install certbot-auto to get newest certbot version
FROM ubuntu:16.04

#set default env variables
ENV DEBIAN_FRONTEND=noninteractive \
    CERTBOT_EMAIL="" \
    PROXY_ADDRESS="proxy" \
    CERTBOT_CRON_RENEW="('0 3 * * *' '0 15 * * *')" \
    PATH="$PATH:/root"

# http://stackoverflow.com/questions/33548530/envsubst-command-getting-stuck-in-a-container
RUN apt-get update && \
    apt-get -y install cron supervisor curl && \
    apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# install certbot-auto
RUN curl -o /root/certbot-auto https://dl.eff.org/certbot-auto && \
    chmod a+x /root/certbot-auto && \
    /root/certbot-auto --version --non-interactive && \
    apt-get purge -y --auto-remove gcc libc6-dev && \
    apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

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
