Foreman 1.16
============
The docker image is published to nexus.lab:8860/foreman

The image is desing to install foreman with ec2 and docker plugin.
Requierments to running this image is to start container with a hostname - foreman.lab.

###Example to run container

```bash
docker run -d -h foreman.lab nexus.lab:8860/foreman

```
###Persistent Volumes 
We should running container in owr env with this persistent volumes for to avoiding losing data:
 ```bash
 foreman/var/lib/postgresql:/var/lib/postgresql
 foreman/etc/puppetlabs/code:/etc/puppetlabs/code
 foreman/opt/puppetlabs:/opt/puppetlabs
```
ENTRYPOINT will start postgresql, foreman, puppet and apache.
