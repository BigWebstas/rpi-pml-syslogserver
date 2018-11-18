FROM ubuntu:14.04
#Change timezone.
RUN ln -snf /usr/share/zoneinfo/America/Recife /etc/localtime && echo "America/Recife" > /etc/timezone
#Add cron job to cleanup logs every half month.
ADD crontab /etc/cron.d/syslog-cleanup-cron
RUN chmod 0644 /etc/cron.d/syslog-cleanup-cron
RUN touch /var/log/cron.log

RUN apt-get update \
    && apt-get install -y git net-tools vim nginx rsyslog supervisor php5-fpm php5-cli apache2-utils\
    && rm -rf /var/lib/apt/lists/*

RUN sed -i -e 's/listen\ =\ 127.0.0.1:9000/listen\ =\ \/var\/run\/php5-fpm.sock/' /etc/php5/fpm/pool.d/www.conf
RUN sed -i '1idaemon off;' /etc/nginx/nginx.conf

RUN rm -rf /var/www && git clone https://github.com/potsky/PimpMyLog.git /var/www
RUN sed -i -e 's/;daemonize\ =\ yes/daemonize\ =\ no/' /etc/php5/fpm/php-fpm.conf
RUN sed -i 's/^variables_order\ =.*/variables_order\ =\ \"GPCSE\"'/ /etc/php5/cli/php.ini

RUN sed -i -e 's/#$ModLoad\ imudp/$ModLoad\ imudp/' -e 's/#$UDPServerRun\ 514/$UDPServerRun\ 514/' /etc/rsyslog.conf
RUN sed -i -e 's/$ActionFileDefaultTemplate\ RSYSLOG_TraditionalFileFormat/$ActionFileDefaultTemplate\ RSYSLOG_SyslogProtocol23Format/' /etc/rsyslog.conf

RUN mkdir -p /var/log/net/ && touch /var/log/net/syslog.log && ln -s /var/log/net/syslog.log /var/www/
RUN chown -R syslog:adm /var/log/net/
RUN adduser www-data adm

COPY nginx-default /etc/nginx/sites-enabled/default
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf
COPY config.user.php /var/www/
COPY rsyslog.conf /etc/rsyslog.conf
COPY create-user.php /var/www/
COPY run.sh /

EXPOSE 80 514/udp

CMD cron && tail -f /var/log/cron.log && run.sh
