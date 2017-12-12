Foreman 1.16
============
This image is desing to install foreman with ec2 plugin.
Requierments to running this image is a hostname - foreman.lab.
  - example:  'docker run -d -h foreman.lab nexus.lab:8860/foreman'

The container should be run with volumes with the persistent volumes for to avoiding losing data:
  "foreman/var/lib/postgresql:/var/lib/postgresql",
  "foreman/etc/puppetlabs/puppet/ssl/public_keys:/etc/puppetlabs/puppet/ssl/public_keys",
  "foreman/etc/puppetlabs/code:/etc/puppetlabs/code",
  "foreman/etc/puppetlabs/puppetserver:/etc/puppetlabs/puppetserver",
  "foreman/opt/puppetlabs:/opt/puppetlabs",
  "foreman/etc/puppetlabs/puppet:/etc/puppetlabs/puppet

ENTRYPOINT will start postgresql, foreman, puppet and apache.
