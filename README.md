# Bondyra's kafka playground
My personal "playground", where I'm creating generic local sandbox to play with simplistic event sourcing / event driven architectures.

# Design
The loose idea of this project is to have a system that:
- Scraps data from various sources
- Puts the data as events to log repository (Kafka), which is the only source of truth
- Processes them to various forms and puts them to different storage engines (views)
- Provides a number of services that allow querying the transformed data for different purposes.

# Current implementation
Current implementation is a PoC that is powered my local filesystem test data (stored in private repo, accessed by a git submodule), that allows to perform simplistic full text query using Elasticsearch container and a simple Spring application.

To know more - please navigate to top directories to get further READMEs.

Current implementation can be depicted in the following diagram:
![Alt text](docs/overview.png?raw=true)
Feeding the system with data is simple - one has to have an access to Kafka and 

# Prerequisites
- Linux
- Local kubernetes cluster - I recommend minikube with VirtualBox driver with at least 4 GB of RAM for cluster (tested empirically, lesser values will result in OOMs - a lot of stuff is spinning up).
- Python 3
- Maven 2 as a build tool for search microservice
- Java 11

# Deployment notes
See README in /deployment top folder.
