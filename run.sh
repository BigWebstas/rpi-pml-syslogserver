#!/bin/bash

logfile="/var/log/net/syslog.log"
if [ -f "$logfile" ];then
    echo "Log File Found."
else
    echo "Log File Not Found, Creating it..."
    touch $logfile
    ln -s $logfile /var/www/
    chown -R syslog:adm /var/log/net/
fi

if [ -e /run/secrets/syslog-password ]; then
    password=$(< /run/secrets/syslog-password)
    export SYSLOG_PASSWORD=$password
fi

if [ -z "$SYSLOG_USERNAME" ];then
    export SYSLOG_USERNAME=admin
fi
if [ -z "$SYSLOG_PASSWORD" ];then
    export SYSLOG_PASSWORD=SyslogP4ss
fi

htpasswd -c -b /etc/nginx/.htpasswd $SYSLOG_USERNAME $SYSLOG_PASSWORD

cd /var/www || exit
php5 -f create-user.php
chown www-data:www-data config.auth.user.php
rm -f create-user.php
cd || exit
supervisord
