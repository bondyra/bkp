# Bondyra's kafka playground
My personal "playground", where I'm creating generic local sandbox to play with simplistic event sourcing / event driven architectures.

# Design
The loose idea of this project is to have a system that:
- Scraps data from various sources
- Puts the data as events to log repository (Kafka), which is the only source of truth
- Processes them to various forms and puts them to different storage engines (views)
- Provides a number of services that allow querying the transformed data for different purposes.

# Current implementation
Current implementation is a PoC that: 
- loads data from test logs (stored in private repo, accessed by a git submodule)
- has a fully functional middleware based on Kafka and Kafka Connect
- provides simplistic full text query feature using Elasticsearch container and a very basic Spring microservice


Current implementation can be depicted in the following diagram:
![Alt text](docs/overview.png?raw=true)

For the details - navigate to top directories to get other READMEs.

# Prerequisites
- Linux
- docker
- Local kubernetes cluster - I recommend minikube with VirtualBox driver with at least 4 GB of RAM for cluster (tested empirically, lesser values will result in OOMs - a lot of stuff is spinning up).
- Python 3
- Maven 2 as a build tool for Spring microservice
- Java 11

# Deployment notes
See README in /deployment top folder.
