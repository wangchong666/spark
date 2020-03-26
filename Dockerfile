FROM centos as builder
WORKDIR /
# COPY ./build/settings.xml /usr/share/maven/ref/
RUN yum -y install wget && wget http://us.mirrors.quenda.co/apache/spark/spark-3.0.0-preview2/spark-3.0.0-preview2-bin-hadoop2.7.tgz
RUN tar zxvf spark-3.0.0-preview2-bin-hadoop2.7.tgz -C /build

FROM openjdk:8-jdk-slim

ARG spark_uid=185

# Before building the docker image, first build and make a Spark distribution following
# the instructions in http://spark.apache.org/docs/latest/building-spark.html.
# If this docker file is being used in the context of building your images from a Spark
# distribution, the docker build command should be invoked from the top level directory
# of the Spark distribution. E.g.:
# docker build -t spark:latest -f kubernetes/dockerfiles/spark/Dockerfile .

#ENV http_proxy http://198.218.33.88:3128
RUN printf "deb https://mirrors.aliyun.com/debian  stable main contrib non-free\ndeb https://mirrors.aliyun.com/debian  stable-updates main contrib non-free " > /etc/apt/sources.list
RUN set -ex && \
    apt-get update && \
    ln -s /lib /lib64 && \
    apt install -y bash tini libc6 libpam-modules krb5-user libnss3 && \
    mkdir -p /opt/spark && \
    mkdir -p /opt/spark/examples && \
    mkdir -p /opt/spark/work-dir && \
    touch /opt/spark/RELEASE && \
    rm /bin/sh && \
    ln -sv /bin/bash /bin/sh && \
    echo "auth required pam_wheel.so use_uid" >> /etc/pam.d/su && \
    chgrp root /etc/passwd && chmod ug+rw /etc/passwd && \
    rm -rf /var/cache/apt/*

COPY --chown=0:0 --from=builder /build/jars /opt/spark/jars
COPY --chown=0:0 --from=builder /build/bin /opt/spark/bin
COPY --chown=0:0 --from=builder /build/sbin /opt/spark/sbin
COPY --chown=0:0 --from=builder /build/kubernetes/dockerfiles/spark/entrypoint.sh /opt/
COPY --chown=0:0 --from=builder /build/examples /opt/spark/examples
COPY --chown=0:0 --from=builder /build/kubernetes/tests /opt/spark/tests
COPY --chown=0:0 --from=builder /build/data /opt/spark/data

ENV SPARK_HOME /opt/spark

WORKDIR /opt/spark/work-dir
RUN chmod g+w /opt/spark/work-dir
