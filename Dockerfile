# INFO

FROM ubuntu:16.04
MAINTAINER Rumen LISHKOV "rlishkov@ingimax.com"

# Prepare required files and environments
COPY start.sh /
RUN chmod 700 /start.sh
ENV LANG='en_US.UTF-8' LANGUAGE='en_US:en' LC_ALL='en_US.UTF-8'
ENV PATH /usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/opt/puppetlabs/bin:/sbin:/bin
ENV FOREOPTS --enable-foreman-compute-ec2 \
  --enable-puppet \
  --puppet-server-ca=false \
  --puppet-server-foreman-url=https://foreman.lab \
  --enable-foreman-proxy \
  --foreman-proxy-puppetca=false \
  --foreman-proxy-tftp=false \
  --foreman-proxy-foreman-base-url=https://foreman.lab \
  --foreman-proxy-trusted-hosts=foreman.lab 

# Run and install that shit
RUN apt-get update && apt-get install --yes ca-certificates wget nano net-tools locales && \
	locale-gen "en_US.UTF-8" && \
	wget https://apt.puppetlabs.com/puppet5-release-xenial.deb && \
	dpkg -i puppet5-release-xenial.deb  && \
	rm puppet5-release-xenial.deb  && \
	echo "deb http://deb.theforeman.org/ xenial 1.16" > /etc/apt/sources.list.d/foreman.list && \
	echo "deb http://deb.theforeman.org/ plugins 1.16" >> /etc/apt/sources.list.d/foreman.list && \
	wget -q https://deb.theforeman.org/pubkey.gpg -O- | apt-key add - && \
	apt-get install -y software-properties-common && \
	apt-get update && \
	apt-get --yes install foreman-installer foreman-postgresql && \
	apt-get install -y git python-pip python-dev python-jinja2 python-yaml python-paramiko python-httplib2 python-six python-crypto sshpass && \
	apt-get purge -y python-requests python-requests-whl && \
	apt-get autoremove -y && \
	apt-get install -y libffi-dev libssl-dev && \
	/usr/bin/pip install --upgrade --ignore-installed pip setuptools urllib3 && \
	/usr/bin/pip install netaddr && \
	/usr/bin/pip install 'pywinrm>=0.1.1' && \
	/usr/bin/pip install pyvmomi==6.0.0.2016.6 && \
	rm -f /usr/share/foreman-installer/checks/hostname.rb && \
	export FACTER_fqdn="foreman.lab" && \
	echo "127.0.0.1  foreman.lab" >> /etc/hosts && \
	echo "Running foreman installer" && \
    (/usr/sbin/foreman-installer $FOREOPTS || /bin/true) && \
	sed -i -e "s/START=no/START=yes/g" /etc/default/foreman && \
	sed -i -e "s/:require_ssl: true/:require_ssl: false/g" /etc/foreman/settings.yaml && \
	sed -i -e "s/:puppetrun: false/:puppetrun: true/g" /etc/foreman/settings.yaml 

# Container run on start "start.sh"
ENTRYPOINT /bin/bash /start.sh
