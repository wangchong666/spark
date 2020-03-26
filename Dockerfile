FROM centos as builder
WORKDIR /spark
# COPY ./build/settings.xml /usr/share/maven/ref/
RUN yum -y install wget && wget http://us.mirrors.quenda.co/apache/spark/spark-3.0.0-preview2/spark-3.0.0-preview2-bin-hadoop2.7.tgz
RUN tar zxvf spark-3.0.0-preview2-bin-hadoop2.7.tgz
