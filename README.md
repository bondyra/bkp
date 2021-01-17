# Bondyra's kafka playground
My personal "playground", where I'm creating generic local sandbox to play with simplistic event sourcing / CQRS / event-driven architectures if I find the time.

# Design
The loose idea of this project is to have a system that:
- Scraps data from various sources,
- Puts the data as events to log repository (Kafka), which is the only source of truth,
- Transforms data into various forms and loads it to different storage services ("views"),
- Provides a number of downstream user-facing microservices that allow querying the views for different purposes.

# Current implementation
Current implementation is a PoC - it is definitely not a production ready system.
It works as follows:
- loads data from test logs (stored in private repo, accessed by a git submodule),
- has a functional middleware based on Kafka, Kafka Connect and Schema Registry,
- provides simplistic full text query feature using Elasticsearch pod and a very basic Spring microservice.

Following diagram shows what are the building blocks of this implementation:
![Alt text](docs/overview.png?raw=true)

For the details - navigate to top directories to get other READMEs.

# Prerequisites
- Linux
- Docker
- Local kubernetes cluster - I recommend minikube with VirtualBox driver allocated with at least 4 GB of RAM (tested empirically, lesser values will result in OOMs - a lot of stuff is spinning up).
- Python 3
- Maven 2 as a build tool for Spring microservice
- Java 11

# Deployment notes
See README in /deployment top folder.
