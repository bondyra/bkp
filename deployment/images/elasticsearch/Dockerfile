FROM openjdk:8-jdk-slim

RUN apt update && apt install -y curl
RUN curl -L -O https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-6.8.10.tar.gz && \
    tar -xvf elasticsearch-6.8.10.tar.gz && rm elasticsearch-6.8.10.tar.gz

ADD jvm.options /elasticsearch-6.8.10/config/jvm.options

EXPOSE 9200

RUN useradd es
RUN chown -R es /elasticsearch-6.8.10
USER es
ENTRYPOINT /elasticsearch-6.8.10/bin/elasticsearch -Enetwork.host=0.0.0.0 -Ediscovery.type="single-node"
