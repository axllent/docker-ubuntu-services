FROM ubuntu:20.04

LABEL maintainer="Ralph Slooten"

RUN apt-get update -q -q && \
apt-get upgrade -y -q && \
apt-get install --yes runit tzdata netcat-openbsd cron && \
apt-get clean && \
rm -rf /etc/sv /var/lib/apt/lists/* /tmp/* /var/tmp/* ~/.cache ~/.npm /var/log/* /var/cache/* /mnt /media /etc/logrotate.d/ /etc/cron.*/*

COPY /root /

CMD ["/run.sh"]
