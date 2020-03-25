FROM maven:3.6.3-jdk-8 as builder
WORKDIR /spark
COPY . .
# COPY ./build/settings.xml /usr/share/maven/ref/
RUN mvn -Pkubernetes -DskipTests clean package
