variable "namespace" {
}

variable "zk_dependency"{
}

resource "kubernetes_config_map" "broker_config" {
  metadata {
    name      = "broker-config"
    namespace = var.namespace
  }

  depends_on = [var.zk_dependency]  # TODO: pass zookeeper hostname to server.properties to do that better
  data = {
    "init.sh" = file("${path.module}/init.sh")

    "log4j.properties" = "# Unspecified loggers and loggers with additivity=true output to server.log and stdout\n# Note that INFO only applies to unspecified loggers, the log level of the child logger is used otherwise\nlog4j.rootLogger=INFO, stdout\n\nlog4j.appender.stdout=org.apache.log4j.ConsoleAppender\nlog4j.appender.stdout.layout=org.apache.log4j.PatternLayout\nlog4j.appender.stdout.layout.ConversionPattern=[%d] %p %m (%c)%n\n\nlog4j.appender.kafkaAppender=org.apache.log4j.DailyRollingFileAppender\nlog4j.appender.kafkaAppender.DatePattern='.'yyyy-MM-dd-HH\nlog4j.appender.kafkaAppender.File=$${kafka.logs.dir}/server.log\nlog4j.appender.kafkaAppender.layout=org.apache.log4j.PatternLayout\nlog4j.appender.kafkaAppender.layout.ConversionPattern=[%d] %p %m (%c)%n\n\nlog4j.appender.stateChangeAppender=org.apache.log4j.DailyRollingFileAppender\nlog4j.appender.stateChangeAppender.DatePattern='.'yyyy-MM-dd-HH\nlog4j.appender.stateChangeAppender.File=$${kafka.logs.dir}/state-change.log\nlog4j.appender.stateChangeAppender.layout=org.apache.log4j.PatternLayout\nlog4j.appender.stateChangeAppender.layout.ConversionPattern=[%d] %p %m (%c)%n\n\nlog4j.appender.requestAppender=org.apache.log4j.DailyRollingFileAppender\nlog4j.appender.requestAppender.DatePattern='.'yyyy-MM-dd-HH\nlog4j.appender.requestAppender.File=$${kafka.logs.dir}/kafka-request.log\nlog4j.appender.requestAppender.layout=org.apache.log4j.PatternLayout\nlog4j.appender.requestAppender.layout.ConversionPattern=[%d] %p %m (%c)%n\n\nlog4j.appender.cleanerAppender=org.apache.log4j.DailyRollingFileAppender\nlog4j.appender.cleanerAppender.DatePattern='.'yyyy-MM-dd-HH\nlog4j.appender.cleanerAppender.File=$${kafka.logs.dir}/log-cleaner.log\nlog4j.appender.cleanerAppender.layout=org.apache.log4j.PatternLayout\nlog4j.appender.cleanerAppender.layout.ConversionPattern=[%d] %p %m (%c)%n\n\nlog4j.appender.controllerAppender=org.apache.log4j.DailyRollingFileAppender\nlog4j.appender.controllerAppender.DatePattern='.'yyyy-MM-dd-HH\nlog4j.appender.controllerAppender.File=$${kafka.logs.dir}/controller.log\nlog4j.appender.controllerAppender.layout=org.apache.log4j.PatternLayout\nlog4j.appender.controllerAppender.layout.ConversionPattern=[%d] %p %m (%c)%n\n\nlog4j.appender.authorizerAppender=org.apache.log4j.DailyRollingFileAppender\nlog4j.appender.authorizerAppender.DatePattern='.'yyyy-MM-dd-HH\nlog4j.appender.authorizerAppender.File=$${kafka.logs.dir}/kafka-authorizer.log\nlog4j.appender.authorizerAppender.layout=org.apache.log4j.PatternLayout\nlog4j.appender.authorizerAppender.layout.ConversionPattern=[%d] %p %m (%c)%n\n\n# Change the two lines below to adjust ZK client logging\nlog4j.logger.org.I0Itec.zkclient.ZkClient=INFO\nlog4j.logger.org.apache.zookeeper=INFO\n\n# Change the two lines below to adjust the general broker logging level (output to server.log and stdout)\nlog4j.logger.kafka=INFO\nlog4j.logger.org.apache.kafka=INFO\n\n# Change to DEBUG or TRACE to enable request logging\nlog4j.logger.kafka.request.logger=WARN, requestAppender\nlog4j.additivity.kafka.request.logger=false\n\n# Uncomment the lines below and change log4j.logger.kafka.network.RequestChannel$ to TRACE for additional output\n# related to the handling of requests\n#log4j.logger.kafka.network.Processor=TRACE, requestAppender\n#log4j.logger.kafka.server.KafkaApis=TRACE, requestAppender\n#log4j.additivity.kafka.server.KafkaApis=false\nlog4j.logger.kafka.network.RequestChannel$=WARN, requestAppender\nlog4j.additivity.kafka.network.RequestChannel$=false\n\nlog4j.logger.kafka.controller=TRACE, controllerAppender\nlog4j.additivity.kafka.controller=false\n\nlog4j.logger.kafka.log.LogCleaner=INFO, cleanerAppender\nlog4j.additivity.kafka.log.LogCleaner=false\n\nlog4j.logger.state.change.logger=TRACE, stateChangeAppender\nlog4j.additivity.state.change.logger=false\n\n# Change to DEBUG to enable audit log for the authorizer\nlog4j.logger.kafka.authorizer.logger=WARN, authorizerAppender\nlog4j.additivity.kafka.authorizer.logger=false"

    "server.properties" = "############################# Log Basics #############################\n\n# A comma seperated list of directories under which to store log files\n# Overrides log.dir\nlog.dirs=/var/lib/kafka/data/topics\n\n# The default number of log partitions per topic. More partitions allow greater\n# parallelism for consumption, but this will also result in more files across\n# the brokers.\nnum.partitions=12\n\ndefault.replication.factor=3\n\nmin.insync.replicas=2\n\nauto.create.topics.enable=false\n\n# The number of threads per data directory to be used for log recovery at startup and flushing at shutdown.\n# This value is recommended to be increased for installations with data dirs located in RAID array.\n#num.recovery.threads.per.data.dir=1\n\n############################# Server Basics #############################\n\n# The id of the broker. This must be set to a unique integer for each broker.\n#init#broker.id=#init#\n\n#init#broker.rack=#init#\n\n############################# Socket Server Settings #############################\n\n# The address the socket server listens on. It will get the value returned from \n# java.net.InetAddress.getCanonicalHostName() if not configured.\n#   FORMAT:\n#     listeners = listener_name://host_name:port\n#   EXAMPLE:\n#     listeners = PLAINTEXT://your.host.name:9092\n#listeners=PLAINTEXT://:9092\nlisteners=PLAINTEXT://:9092,OUTSIDE://:9094\n\n# Hostname and port the broker will advertise to producers and consumers. If not set, \n# it uses the value for \"listeners\" if configured.  Otherwise, it will use the value\n# returned from java.net.InetAddress.getCanonicalHostName().\n#advertised.listeners=PLAINTEXT://your.host.name:9092\n#init#advertised.listeners=PLAINTEXT://#init#\n\n# Maps listener names to security protocols, the default is for them to be the same. See the config documentation for more details\n#listener.security.protocol.map=PLAINTEXT:PLAINTEXT,SSL:SSL,SASL_PLAINTEXT:SASL_PLAINTEXT,SASL_SSL:SASL_SSL\nlistener.security.protocol.map=PLAINTEXT:PLAINTEXT,SSL:SSL,SASL_PLAINTEXT:SASL_PLAINTEXT,SASL_SSL:SASL_SSL,OUTSIDE:PLAINTEXT\ninter.broker.listener.name=PLAINTEXT\n\n# The number of threads that the server uses for receiving requests from the network and sending responses to the network\n#num.network.threads=3\n\n# The number of threads that the server uses for processing requests, which may include disk I/O\n#num.io.threads=8\n\n# The send buffer (SO_SNDBUF) used by the socket server\n#socket.send.buffer.bytes=102400\n\n# The receive buffer (SO_RCVBUF) used by the socket server\n#socket.receive.buffer.bytes=102400\n\n# The maximum size of a request that the socket server will accept (protection against OOM)\n#socket.request.max.bytes=104857600\n\n############################# Internal Topic Settings  #############################\n# The replication factor for the group metadata internal topics \"__consumer_offsets\" and \"__transaction_state\"\n# For anything other than development testing, a value greater than 1 is recommended for to ensure availability such as 3.\n#offsets.topic.replication.factor=1\n#transaction.state.log.replication.factor=1\n#transaction.state.log.min.isr=1\n\n############################# Log Flush Policy #############################\n\n# Messages are immediately written to the filesystem but by default we only fsync() to sync\n# the OS cache lazily. The following configurations control the flush of data to disk.\n# There are a few important trade-offs here:\n#    1. Durability: Unflushed data may be lost if you are not using replication.\n#    2. Latency: Very large flush intervals may lead to latency spikes when the flush does occur as there will be a lot of data to flush.\n#    3. Throughput: The flush is generally the most expensive operation, and a small flush interval may lead to excessive seeks.\n# The settings below allow one to configure the flush policy to flush data after a period of time or\n# every N messages (or both). This can be done globally and overridden on a per-topic basis.\n\n# The number of messages to accept before forcing a flush of data to disk\n#log.flush.interval.messages=10000\n\n# The maximum amount of time a message can sit in a log before we force a flush\n#log.flush.interval.ms=1000\n\n############################# Log Retention Policy #############################\n\n# The following configurations control the disposal of log segments. The policy can\n# be set to delete segments after a period of time, or after a given size has accumulated.\n# A segment will be deleted whenever *either* of these criteria are met. Deletion always happens\n# from the end of the log.\n\n# https://cwiki.apache.org/confluence/display/KAFKA/KIP-186%3A+Increase+offsets+retention+default+to+7+days\noffsets.retention.minutes=10080\n\n# The minimum age of a log file to be eligible for deletion due to age\nlog.retention.hours=-1\n\n# A size-based retention policy for logs. Segments are pruned from the log unless the remaining\n# segments drop below log.retention.bytes. Functions independently of log.retention.hours.\n#log.retention.bytes=1073741824\n\n# The maximum size of a log segment file. When this size is reached a new log segment will be created.\n#log.segment.bytes=1073741824\n\n# The interval at which log segments are checked to see if they can be deleted according\n# to the retention policies\n#log.retention.check.interval.ms=300000\n\n############################# Zookeeper #############################\n\n# Zookeeper connection string (see zookeeper docs for details).\n# This is a comma separated host:port pairs, each corresponding to a zk\n# server. e.g. \"127.0.0.1:3000,127.0.0.1:3001,127.0.0.1:3002\".\n# You can also append an optional chroot string to the urls to specify the\n# root directory for all kafka znodes.\nzookeeper.connect=zookeeper:2181\n\n# Timeout in ms for connecting to zookeeper\n#zookeeper.connection.timeout.ms=6000\n\n\n############################# Group Coordinator Settings #############################\n\n# The following configuration specifies the time, in milliseconds, that the GroupCoordinator will delay the initial consumer rebalance.\n# The rebalance will be further delayed by the value of group.initial.rebalance.delay.ms as new members join the group, up to a maximum of max.poll.interval.ms.\n# The default value for this is 3 seconds.\n# We override this to 0 here as it makes for a better out-of-the-box experience for development and testing.\n# However, in production environments the default value of 3 seconds is more suitable as this will help to avoid unnecessary, and potentially expensive, rebalances during application startup.\n#group.initial.rebalance.delay.ms=0"
  }
}

resource "kubernetes_service" "broker" {
  metadata {
    name      = "broker"
    namespace = var.namespace
  }

  spec {
    port {
      port = 9092
    }

    selector = {
      app = "kafka"
    }

    cluster_ip = "None"
  }
}

resource "kubernetes_service" "bootstrap" {
  metadata {
    name      = "bootstrap"
    namespace = var.namespace
  }

  spec {
    port {
      port = 9092
    }

    selector = {
      app = "kafka"
    }
  }
}

resource "kubernetes_stateful_set" "kafka" {
  metadata {
    name      = "kafka"
    namespace = var.namespace
  }

  spec {
    replicas = 3

    selector {
      match_labels = {
        app = "kafka"
      }
    }

    template {
      metadata {
        labels = {
          app = "kafka"
        }
      }

      spec {
        service_account_name = "default"
        automount_service_account_token = true
        share_process_namespace = true

        volume {
          name = "configmap"

          config_map {
            name = "broker-config"
          }
        }

        volume {
          name = "config"
        }

        volume {
          name = "extensions"
        }

        init_container {
          name    = "init-config"
          image   = "solsson/kafka-initutils@sha256:f6d9850c6c3ad5ecc35e717308fddb47daffbde18eb93e98e031128fe8b899ef"
          command = ["/bin/bash", "/etc/kafka-configmap/init.sh"]

          env {
            name = "NODE_NAME"

            value_from {
              field_ref {
                field_path = "spec.nodeName"
              }
            }
          }

          env {
            name = "POD_NAME"

            value_from {
              field_ref {
                field_path = "metadata.name"
              }
            }
          }

          env {
            name = "POD_NAMESPACE"

            value_from {
              field_ref {
                field_path = "metadata.namespace"
              }
            }
          }

          volume_mount {
            name       = "configmap"
            mount_path = "/etc/kafka-configmap"
          }

          volume_mount {
            name       = "config"
            mount_path = "/etc/kafka"
          }

          volume_mount {
            name       = "extensions"
            mount_path = "/opt/kafka/libs/extensions"
          }
        }

        container {
          name    = "broker"
          image   = "solsson/kafka:2.2.1@sha256:450c6fdacae3f89ca28cecb36b2f120aad9b19583d68c411d551502ee8d0b09b"
          command = ["./bin/kafka-server-start.sh", "/etc/kafka/server.properties"]

          port {
            name           = "inside"
            container_port = 9092
          }

          port {
            name           = "outside"
            container_port = 9094
          }

          port {
            name           = "jmx"
            container_port = 5555
          }

          env {
            name  = "CLASSPATH"
            value = "/opt/kafka/libs/extensions/*"
          }

          env {
            name  = "KAFKA_LOG4J_OPTS"
            value = "-Dlog4j.configuration=file:/etc/kafka/log4j.properties"
          }

          env {
            name  = "JMX_PORT"
            value = "5555"
          }

          resources {
            limits {
              memory = "600Mi"
            }

            requests {
              cpu    = "100m"
              memory = "100Mi"
            }
          }

          volume_mount {
            name       = "config"
            mount_path = "/etc/kafka"
          }

          volume_mount {
            name       = "data"
            mount_path = "/var/lib/kafka/data"
          }

          volume_mount {
            name       = "extensions"
            mount_path = "/opt/kafka/libs/extensions"
          }

          readiness_probe {
            tcp_socket {
              port = "9092"
            }

            timeout_seconds = 1
          }

          lifecycle {
            pre_stop {
              exec {
                command = ["sh", "-ce", "kill -s TERM 1; while $(kill -0 1 2>/dev/null); do sleep 1; done"]
              }
            }
          }
        }

        termination_grace_period_seconds = 30
      }
    }

    volume_claim_template {
      metadata {
        name = "data"
      }

      spec {
        access_modes = ["ReadWriteOnce"]

        resources {
          requests = {
            storage = "10Gi"
          }
        }

        storage_class_name = "standard"
      }
    }

    service_name          = "broker"
    pod_management_policy = "Parallel"

    update_strategy {
      type = "RollingUpdate"
    }
  }
}
