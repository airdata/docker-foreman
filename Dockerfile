FROM ubuntu:16.04
MAINTAINER Rumen LISHKOV "rlishkov@ingimax.com"

ENV DEBIAN_FRONTEND noninteractive
ENV PATH /usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/opt/puppetlabs/bin:/sbin:/bin
ENV FOREOPTS--enable-foreman-compute-ec2 \
        --enable-puppet \
        --puppet-listen=true \
        --puppet-show-diff=true \
        --puppet-server-envs-dir=/etc/puppet/environments \
        --foreman-proxy-dhcp-option-domain='' \
        --foreman-proxy-dns-zone='' \
        --puppet-srv-domain=''

COPY start-image.sh /

RUN \
    apt-get update && \
    apt-get upgrade -y && \
    apt-get -y install ca-certificates wget && \
    wget https://apt.puppetlabs.com/puppetlabs-release-pc1-xenial.deb && \
    dpkg -i puppetlabs-release-pc1-xenial.deb && \
    apt-get update && \
    apt-get install -y wget aptitude htop vim vim-puppet git traceroute dnsutils && \
    echo "deb http://deb.theforeman.org/ xenial 1.16" > /etc/apt/sources.list.d/foreman.list && \
    echo "deb http://deb.theforeman.org/ plugins 1.16" >> /etc/apt/sources.list.d/foreman.list && \
    wget -q http://deb.theforeman.org/pubkey.gpg -O- | apt-key add - && \
    apt-get install -y software-properties-common && \
    apt-add-repository ppa:git-core/ppa -y && \
    apt-get update && \
    apt-get install -y foreman-installer python-paramiko python-httplib2 python-six python-crypto sshpass && \
    apt-get update && \
    apt-add-repository -y ppa:ansible/ansible && \
    apt-get install -y ansible && \
    apt-get purge -y python-requests python-requests-whl && \
    apt-get autoremove -y && \
    apt-get install -y libffi-dev libssl-dev locales && \
    echo "set modeline" > /root/.vimrc && \
    echo "export TERM=vt100" >> /root/.bashrc && \
    LANG=en_US.UTF-8 locale-gen --purge en_US.UTF-8 && \
    echo 'LANG="en_US.UTF-8"\nLANGUAGE="en_US:en"\n' > /etc/default/locale && \
    (dpkg-reconfigure --frontend=noninteractive locales || /bin/true) && \
    rm -f /usr/share/foreman-installer/checks/hostname.rb && \
    export FACTER_fqdn="foreman.lab" && \
    echo "127.1.1.2  foreman.lab" >> /etc/hosts && \
    echo "Running foreman installer" && \
    (/usr/sbin/foreman-installer $FOREOPTS || /bin/true) && \
    sed -i -e "s/START=no/START=yes/g" /etc/default/foreman && \
    chmod 700 /start-image.sh && \
    /etc/init.d/puppetserver stop && \
    export PATH=$PATH:/opt/puppetlabs/bin && \
    sed -i 's?:/usr/bin:?:/usr/bin:/opt/puppetlabs/bin:?' /etc/environment && \
    sed -i -e "s/START=no/START=yes/g" /etc/default/foreman && \
    sed -i -e "s/:require_ssl: true/:require_ssl: false/g" /etc/foreman/settings.yaml && \
    sed -i -e "s/:puppetrun: false/:puppetrun: true/g" /etc/foreman/settings.yaml

    /opt/puppetlabs/bin/puppet resource service puppet ensure=stopped && \
    /opt/puppetlabs/bin/puppet resource service apache2 ensure=stopped && \
    export SSLDIR=`puppet config print ssldir --section master` && \
    rm -rf $SSLDIR && \
    touch /var/lib/foreman/.firsttime

EXPOSE 443
EXPOSE 8140
EXPOSE 8443

# all future startups
ENTRYPOINT /start-image.sh
