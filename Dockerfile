FROM ubuntu:17.10

RUN apt update \
	&& apt -y install default-jdk curl
run 	curl -O https://d3kbcqa49mib13.cloudfront.net/spark-2.1.1-bin-hadoop2.7.tgz
RUN	mkdir -p /opt/ \
	&& cd /opt/ && tar xzf /spark-2.1.1-bin-hadoop2.7.tgz
RUN 	rm /spark-2.1.1-bin-hadoop2.7.tgz

#openjdk-8-jre-headless
