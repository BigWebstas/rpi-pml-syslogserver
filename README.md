Based on: https://github.com/andreppedroza/ufcg-syslogserver Which is based on >> https://github.com/pbertera/dockerfiles/tree/master/syslogserver

## RaspberryPi + Rsyslogd + PimpMyLogs

This container creates a Syslog server with Rsyslogd, logs are accessible via PimpMyLogs interface (http://pimpmylog.com).

PympMylogs credentials are created using the script create-user.php:

```Set env variables(Optional)
SYSLOG_USERNAME  ->> User
SYSLOG_PASSORD   ->> pw
(if not set the default user is admin and pw is SyslogP4ss)

Networking (Mandatory)
Set ports UDP 514  ->> 515
Set ports TCP 80   ->> 80

Map volumes (Optional)
/var/log/net/ --> /local/storage
```

You can run the container with:

    docker run -it -e SYSLOG_USERNAME=admin -e SYSLOG_PASSWORD=1234 -p 8080:80 -p 514:515/udp -v /host/path:/var/log/net/syslog.log BigWebstas/rpi-pml-syslogserver

