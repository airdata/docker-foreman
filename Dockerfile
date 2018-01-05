FROM ubuntu:16.04
MAINTAINER Rumen LISHKOV "rlishkov@ingimax.com"

COPY start.sh /
ENV LANG='en_US.UTF-8' LANGUAGE='en_US:en' LC_ALL='en_US.UTF-8'
ENV FOREOPTS  --enable-foreman-compute-ec2 \
    --foreman-admin-password='Pd2$*@%s' \
    --enable-foreman-plugin-docker

RUN apt-get update && apt-get install --yes ca-certificates wget nano net-tools locales && \
	locale-gen "en_US.UTF-8" && \
	wget https://apt.puppetlabs.com/puppet5-release-xenial.deb && \
	dpkg -i puppet5-release-xenial.deb  && \
	rm puppet5-release-xenial.deb  && \
	echo "deb http://deb.theforeman.org/ xenial 1.16" > /etc/apt/sources.list.d/foreman.list && \
	echo "deb http://deb.theforeman.org/ plugins 1.16" >> /etc/apt/sources.list.d/foreman.list && \
	wget -q https://deb.theforeman.org/pubkey.gpg -O- | apt-key add -

RUN apt-get update && apt-get --yes install foreman-installer foreman-postgresql && \
	rm -f /usr/share/foreman-installer/checks/hostname.rb && \
	export FACTER_fqdn="foreman.lab" && \
	echo "127.0.0.1  foreman.lab" >> /etc/hosts && \
	echo "Running foreman installer" && \
    (/usr/sbin/foreman-installer $FOREOPTS || /bin/true) && \
	sed -i -e "s/START=no/START=yes/g" /etc/default/foreman && \
	sed -i -e "s/:require_ssl: true/:require_ssl: false/g" /etc/foreman/settings.yaml && \
	sed -i -e "s/:puppetrun: false/:puppetrun: true/g" /etc/foreman/settings.yaml && \
	cp -p /etc/puppetlabs/puppet/ssl/private_keys/*.pem /etc/puppetlabs/puppet/ssl/private_keys/foreman.lab.pem && \
	cp -p /etc/puppetlabs/puppet/ssl/public_keys/*.pem /etc/puppetlabs/puppet/ssl/public_keys/foreman.lab.pem && \
	sed -i "s/client_certname: .*$/client_certname: foreman.lab/" /etc/foreman-installer/scenarios.d/foreman-answers.yaml && \
	sed -i "s/server_certname: .*$/server_certname: foreman.lab/" /etc/foreman-installer/scenarios.d/foreman-answers.yaml && \
	sed -i "s?:ssl_cert: .*?:ssl_cert: \"/etc/puppetlabs/puppet/ssl/certs/foreman.lab.pem\"?" /etc/puppetlabs/puppet/foreman.yaml && \
	sed -i "s?:ssl_key: .*?:ssl_key: \"/etc/puppetlabs/puppet/ssl/private_keys/foreman.lab.pem\"?" /etc/puppetlabs/puppet/foreman.yaml && \
	sed -i "s/certname = .*/certname = foreman.lab/g" /etc/puppetlabs/puppet/puppet.conf && \
	sed -i "s?ssl-cert: .*?ssl-cert: /etc/puppetlabs/puppet/ssl/certs/foreman.lab.pem?" /etc/puppetlabs/puppetserver/conf.d/webserver.conf && \
	sed -i "s?ssl-key: .*?ssl-key: /etc/puppetlabs/puppet/ssl/private_keys/foreman.lab.pem?" /etc/puppetlabs/puppetserver/conf.d/webserver.conf && \
	sed -i "s/client_certname: = .*/client_certname: = foreman.lab/g" /etc/foreman-installer/scenarios.d/foreman-answers.yaml && \
	sed -i "s?:ssl-cert: .*?:ssl_cert: \"/etc/puppetlabs/puppet/ssl/certs/foreman.lab.pem\"?" /etc/puppetlabs/puppetserver/conf.d/webserver.conf && \
	sed -i "s?:ssl-key: .*?:ssl_key: \"/etc/puppetlabs/puppet/ssl/private_keys/foreman.lab.pem\"?" /etc/puppetlabs/puppetserver/conf.d/webserver.conf && \
	ln -s /opt/puppetlabs/puppet/bin/puppet /usr/sbin/ && \
	chmod 700 /start.sh

ENTRYPOINT /start.sh

