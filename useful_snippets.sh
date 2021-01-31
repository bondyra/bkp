curl -XGET `minikube ip`:32000/test/_search --data '{"query": {"match": {"content.text": "e"}}}' --header 'Content-Type: application/json'

curl 192.168.99.100:30064/search?pattern=8c4d354576cc445f830c586f9cd3b41d

# this is how the tests can be run, provided that: 1) everything is correctly deployed, 2) you set up proper ports (I cannot hardwire search app service port with jkube plugin)
python3 e2e_test.py -o ./bkp-test-data/data-1/input -b `minikube ip`:32400 -s ./bkp-test-data/schema.avsc -r http://`minikube ip`:30801 -t $TOPIC_NAME -u http://`minikube ip`:30064

curl -XDELETE `minikube ip`:${CONNECT_PORT}/connectors/es-sink
