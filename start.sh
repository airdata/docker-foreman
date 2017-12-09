#!/bin/bash -e
/etc/init.d/postgresql start
echo "sleeping for postgresql to ensure started"
sleep 10
/etc/init.d/foreman start
/etc/init.d/puppetserver start
service foreman-proxy restart
/usr/sbin/apache2 -k start
