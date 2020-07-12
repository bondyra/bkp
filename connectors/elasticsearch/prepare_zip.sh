#!/usr/bin/env bash
set -e

if [ $# -ne 1 ]; then
    echo "Provide [connector_zips_folder] to proceed"
    exit 1
fi

curl -X GET \
https://d1i4a15mxbxib1.cloudfront.net/api/plugins/confluentinc/kafka-connect-elasticsearch/versions/5.2.2/confluentinc-kafka-connect-elasticsearch-5.2.2.zip \
-o $1/elasticsearch.zip
