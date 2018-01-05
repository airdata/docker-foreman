Foreman 1.16
-------------
The docker image is published to nexus.lab:8860/foreman

The image is desing to install foreman with ec2 and docker plugin.
Requierments to running this image is to start container with a hostname - foreman.lab.

Run container
========================
```
docker run -d -h foreman.lab nexus.lab:8860/foreman

```
docker-compose
===============
```
git clone https://github.com/airdata/foreman-docker.git && \
 cd foreman-docker && \
 docker-compose up -d
```

Persistent Volumes 
==================

Running container in with persistent volumes for to avoiding losing data:

 ```
 /var/lib/postgresql:/var/lib/postgresql
 /etc/puppetlabs/code:/etc/puppetlabs/code
 /opt/puppetlabs:/opt/puppetlabs
```
