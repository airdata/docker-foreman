#!/bin/bash -e
/etc/init.d/postgresql start
/etc/init.d/foreman start
/etc/init.d/puppetserver start
/etc/init.d/foreman-proxy start
/usr/sbin/apache2ctl -D FOREGROUND
