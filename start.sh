#!/bin/bash -e
/etc/init.d/postgresql start
sleep 10
/etc/init.d/foreman start
sleep 15
/etc/init.d/puppetserver start
sleep 10
/etc/init.d/foreman-proxy start
/usr/sbin/apache2ctl -D FOREGROUND
