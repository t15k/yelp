FROM ubuntu:17.10

RUN 	apt update \
	&& apt -y install default-jdk curl \
	&& curl -O https://d3kbcqa49mib13.cloudfront.net/spark-2.1.1-bin-hadoop2.7.tgz \
	&& mkdir -p /opt/ \
	&& cd /opt/ && tar xzf /spark-2.1.1-bin-hadoop2.7.tgz \
 	&& rm /spark-2.1.1-bin-hadoop2.7.tgz

COPY	*.yelp /
ENTRYPOINT ["/opt/spark-2.1.1-bin-hadoop2.7/bin/spark-shell"]
