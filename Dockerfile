FROM airdata/foreman-docker

ENV LANG='en_US.UTF-8' LANGUAGE='en_US:en' LC_ALL='en_US.UTF-8'
ENV FOREOPTS  --enable-foreman-compute-ec2 \
	--foreman-admin-password='admin' \
	--enable-foreman-plugin-docker \
	--enable-foreman-plugin-tasks \
	--enable-foreman-plugin-templates 
	
RUN apt-get update -y && apt-get upgrade -y

COPY start.sh /
RUN	chmod 700 /start.sh 
ENTRYPOINT /start.sh
