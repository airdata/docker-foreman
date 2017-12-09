FROM ubuntu:16.04
MAINTAINER Rumen LISHKOV "rlishkov@ingimax.com"
ENV LANG='en_US.UTF-8' LANGUAGE='en_US:en' LC_ALL='en_US.UTF-8'
RUN apt update && apt-get install -y ca-certificates wget nano net-tools locales
RUN locale-gen en_US.UTF-8
RUN wget https://apt.puppetlabs.com/puppet5-release-xenial.deb && \
dpkg -i puppet5-release-xenial.deb  && \
echo "deb http://deb.theforeman.org/ xenial 1.16" > /etc/apt/sources.list.d/foreman.list && \
echo "deb http://deb.theforeman.org/ plugins 1.16" >> /etc/apt/sources.list.d/foreman.list && \
wget -q https://deb.theforeman.org/pubkey.gpg -O- | apt-key add -
RUN apt-get update && apt-get -y install foreman-installer foreman-postgresql
COPY start.sh /
RUN chmod 700 /start.sh
EXPOSE 80
EXPOSE 8140
EXPOSE 8443
