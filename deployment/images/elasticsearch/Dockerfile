FROM openjdk:8-jdk-slim

RUN apt update && apt install -y curl
RUN curl -L -O https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-7.8.0-linux-x86_64.tar.gz && \
    tar -xvf elasticsearch-7.8.0-linux-x86_64.tar.gz && rm elasticsearch-7.8.0-linux-x86_64.tar.gz

ADD jvm.options /elasticsearch-7.8.0/config/jvm.options

EXPOSE 9200

RUN useradd es
RUN chown -R es /elasticsearch-7.8.0
USER es
ENTRYPOINT /elasticsearch-7.8.0/bin/elasticsearch
