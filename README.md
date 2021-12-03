# Ubuntu services docker image

This [base image](https://github.com/axllent/docker-ubuntu-services) is intended for docker containers that run multiple services using the [`runit`](http://smarden.org/runit/) service supervisor.

A Ubuntu docker base build image based off the current stable Ubuntu LTS, with some basic additions for common use. This image is not intended for direct use, but rather extended from by other docker images.


## Adding services

The image will run `/run.sh` (which runs `runsvdir -P /etc/service` by default), so any services you add should be added to the `/etc/service/` folder.

For more information [see docs](http://smarden.org/runit/).


## Cron

There is a simple cron service set up, which runs by default (daily, weekly, monthly, set to run just after midnight). Cron tasks should be added to:

- `/etc/cron.daily`
- `/etc/cron.weekly`
- `/etc/cron.monthly`


## Setting the timezone

Set your container timezone by setting the `TZ` environment, eg: `-e TZ=Pacific/Auckland`.


## `netcat-openbsd`

To provide TCP health checks in your image, eg:

```
HEALTHCHECK --interval=60s --timeout=2s --retries=3 \
    CMD nc -znvw 1 127.0.0.1 80 || exit 1
```


## Log rotating

Services using runit's [svlogd](http://smarden.org/runit/svlogd.8.html) logging shouldn't require any additional log rotation, however if your service does, then a basic [logrotate.sh](https://github.com/axllent/docker-ubuntu-services/blob/master/root/usr/local/sbin/logrotate.sh) script should be all you need to add to a cron task, eg:

`/etc/crond.daily/apache`

```shell
#!/bin/sh
bash /usr/local/sbin/logrotate.sh --source="/var/log/apache/" --name="*.log" --min=100
```
