Foreman 1.16
============
This image is desing to install foreman with ec2 plugin.
Requierments to running this image is a hostname - foreman.lab.
  - example:  'docker run -d -h foreman.lab nexus.lab:8860/foreman'

We should run the image with the following persistant docker volumes for to avoind losing data:
  - Postgresql where db is ALREADY! installed (/var/lib/postgresql)
  - Puppetlabs where certs and envoirments are ALREADY! installed (/etc/puppetlabs)

ENTRYPOINT will start postgresql, foreman, puppet and apache.
