FROM ubuntu:16.04
MAINTAINER Rumen LISHKOV "rumenlishkov@gmail.com"

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
	ln -s /opt/puppetlabs/bin/puppet /usr/sbin/ && \
	chmod 700 /start.sh && \
    /etc/init.d/puppetserver stop && \
    export PATH=$PATH:/opt/puppetlabs/bin && \
    sed -i 's?:/usr/bin:?:/usr/bin:/opt/puppetlabs/bin:?' /etc/environment && \
    /opt/puppetlabs/bin/puppet resource service puppet ensure=stopped && \
    /opt/puppetlabs/bin/puppet resource service apache2 ensure=stopped && \
    export SSLDIR=`puppet config print ssldir --section master` && \
    rm -rf $SSLDIR && \
	touch /var/lib/foreman/.firsttime

ENTRYPOINT /start.sh
