variable "namespace" {
}

resource "kubernetes_config_map" "broker_config" {
  metadata {
    name      = "broker-config"
    namespace = var.namespace
  }

  data = {
    "init.sh" = file("${path.module}/init.sh")

    "log4j.properties" = file("${path.module}/log4j.properties")

    "server.properties" = file("${path.module}/server.properties")
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

resource "kubernetes_service" "outside0" {
  metadata {
    name      = "kafka-outside-0"
    namespace = var.namespace
  }

  spec {
    selector = {
      app = "kafka"
      kafka-broker-id = "0"
    }

    port {
      target_port = "9094"
      port = "32400"
      node_port = "32400"
    }

    type = "NodePort"
  }
}

resource "kubernetes_service" "outside1" {
  metadata {
    name      = "kafka-outside-1"
    namespace = var.namespace
  }

  spec {
    selector = {
      app = "kafka"
      kafka-broker-id = "1"
    }

    port {
      target_port = "9094"
      port = "32401"
      node_port = "32401"
    }

    type = "NodePort"
  }
}

resource "kubernetes_service" "outside2" {
  metadata {
    name      = "kafka-outside-2"
    namespace = var.namespace
  }

  spec {
    selector = {
      app = "kafka"
      kafka-broker-id = "2"
    }

    port {
      target_port = "9094"
      port = "32402"
      node_port = "32402"
    }

    type = "NodePort"
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
              memory = "500Mi"
            }

            requests {
              cpu    = "100m"
              memory = "400Mi"
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
            storage = "1Gi"
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
