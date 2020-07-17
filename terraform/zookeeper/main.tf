variable "namespace" {
}

resource "kubernetes_config_map" "zookeeper_config" {
  metadata {
    name = "zookeeper-config"
    namespace = var.namespace
  }

  data = {
    "init.sh" = file("${path.module}/init.sh")

    "log4j.properties" = file("${path.module}/log4j.properties")

    "zookeeper.properties" = file("${path.module}/zookeeper.properties")
  }
}

resource "kubernetes_service" "pzoo" {
  metadata {
    name = "pzoo"
    namespace = var.namespace
  }

  spec {
    port {
      name = "peer"
      port = 2888
    }

    port {
      name = "leader-election"
      port = 3888
    }

    selector = {
      app = "zookeeper"

      storage = "persistent"
    }

    cluster_ip = "None"
  }
}

resource "kubernetes_service" "zoo" {
  metadata {
    name = "zoo"
    namespace = var.namespace
  }

  spec {
    port {
      name = "peer"
      port = 2888
    }

    port {
      name = "leader-election"
      port = 3888
    }

    selector = {
      app = "zookeeper"

      storage = "persistent-regional"
    }

    cluster_ip = "None"
  }
}

resource "kubernetes_service" "zookeeper" {
  metadata {
    name = "zookeeper"
    namespace = var.namespace
  }

  spec {
    port {
      name = "client"
      port = 2181
    }

    selector = {
      app = "zookeeper"
    }
  }
}

resource "kubernetes_stateful_set" "pzoo" {
  metadata {
    name = "pzoo"
    namespace = var.namespace
  }

  spec {
    replicas = 3

    selector {
      match_labels = {
        app = "zookeeper"

        storage = "persistent"
      }
    }

    template {
      metadata {
        labels = {
          app = "zookeeper"

          storage = "persistent"
        }
      }

      spec {
        volume {
          name = "configmap"

          config_map {
            name = kubernetes_config_map.zookeeper_config.metadata[0].name
          }
        }

        volume {
          name = "config"
        }

        init_container {
          name = "init-config"
          image = "solsson/kafka-initutils@sha256:f6d9850c6c3ad5ecc35e717308fddb47daffbde18eb93e98e031128fe8b899ef"
          command = [
            "/bin/bash",
            "/etc/kafka-configmap/init.sh"]

          volume_mount {
            name = "configmap"
            mount_path = "/etc/kafka-configmap"
          }

          volume_mount {
            name = "config"
            mount_path = "/etc/kafka"
          }

          volume_mount {
            name = "data"
            mount_path = "/var/lib/zookeeper"
          }
        }

        container {
          name = "zookeeper"
          image = "solsson/kafka:2.2.1@sha256:450c6fdacae3f89ca28cecb36b2f120aad9b19583d68c411d551502ee8d0b09b"
          command = [
            "./bin/zookeeper-server-start.sh",
            "/etc/kafka/zookeeper.properties"]

          port {
            name = "client"
            container_port = 2181
          }

          port {
            name = "peer"
            container_port = 2888
          }

          port {
            name = "leader-election"
            container_port = 3888
          }

          env {
            name = "KAFKA_LOG4J_OPTS"
            value = "-Dlog4j.configuration=file:/etc/kafka/log4j.properties"
          }

          resources {
            limits {
              memory = "120Mi"
            }

            requests {
              cpu = "10m"
              memory = "100Mi"
            }
          }

          volume_mount {
            name = "config"
            mount_path = "/etc/kafka"
          }

          volume_mount {
            name = "data"
            mount_path = "/var/lib/zookeeper"
          }

          readiness_probe {
            exec {
              command = [
                "/bin/sh",
                "-c",
                "[ \"imok\" = \"$(echo ruok | nc -w 1 -q 1 127.0.0.1 2181)\" ]"]
            }
          }

          lifecycle {
            pre_stop {
              exec {
                command = [
                  "sh",
                  "-ce",
                  "kill -s TERM 1; while $(kill -0 1 2>/dev/null); do sleep 1; done"]
              }
            }
          }
        }

        termination_grace_period_seconds = 10
      }
    }

    volume_claim_template {
      metadata {
        name = "data"
      }

      spec {
        access_modes = [
          "ReadWriteOnce"]

        resources {
          requests = {
            storage = "200M"
          }
        }

        storage_class_name = "standard"
      }
    }

    service_name = "pzoo"
    pod_management_policy = "Parallel"

    update_strategy {
      type = "RollingUpdate"
    }
  }
}

resource "kubernetes_stateful_set" "zoo" {
  metadata {
    name = "zoo"
    namespace = var.namespace
  }

  spec {
    replicas = 2

    selector {
      match_labels = {
        app = "zookeeper"

        storage = "persistent-regional"
      }
    }

    template {
      metadata {
        labels = {
          app = "zookeeper"

          storage = "persistent-regional"
        }
      }

      spec {
        volume {
          name = "configmap"

          config_map {
            name = kubernetes_config_map.zookeeper_config.metadata[0].name
          }
        }

        volume {
          name = "config"
        }

        init_container {
          name = "init-config"
          image = "solsson/kafka-initutils@sha256:f6d9850c6c3ad5ecc35e717308fddb47daffbde18eb93e98e031128fe8b899ef"
          command = [
            "/bin/bash",
            "/etc/kafka-configmap/init.sh"]

          env {
            name = "ID_OFFSET"
            value = "4"
          }

          volume_mount {
            name = "configmap"
            mount_path = "/etc/kafka-configmap"
          }

          volume_mount {
            name = "config"
            mount_path = "/etc/kafka"
          }

          volume_mount {
            name = "data"
            mount_path = "/var/lib/zookeeper"
          }
        }

        container {
          name = "zookeeper"
          image = "solsson/kafka:2.2.1@sha256:450c6fdacae3f89ca28cecb36b2f120aad9b19583d68c411d551502ee8d0b09b"
          command = [
            "./bin/zookeeper-server-start.sh",
            "/etc/kafka/zookeeper.properties"]

          port {
            name = "client"
            container_port = 2181
          }

          port {
            name = "peer"
            container_port = 2888
          }

          port {
            name = "leader-election"
            container_port = 3888
          }

          env {
            name = "KAFKA_LOG4J_OPTS"
            value = "-Dlog4j.configuration=file:/etc/kafka/log4j.properties"
          }

          resources {
            limits {
              memory = "120Mi"
            }

            requests {
              cpu = "10m"
              memory = "100Mi"
            }
          }

          volume_mount {
            name = "config"
            mount_path = "/etc/kafka"
          }

          volume_mount {
            name = "data"
            mount_path = "/var/lib/zookeeper"
          }

          readiness_probe {
            exec {
              command = [
                "/bin/sh",
                "-c",
                "[ \"imok\" = \"$(echo ruok | nc -w 1 -q 1 127.0.0.1 2181)\" ]"]
            }
          }

          lifecycle {
            pre_stop {
              exec {
                command = [
                  "sh",
                  "-ce",
                  "kill -s TERM 1; while $(kill -0 1 2>/dev/null); do sleep 1; done"]
              }
            }
          }
        }

        termination_grace_period_seconds = 10
      }
    }

    volume_claim_template {
      metadata {
        name = "data"
      }

      spec {
        access_modes = [
          "ReadWriteOnce"]

        resources {
          requests = {
            storage = "200M"
          }
        }

        storage_class_name = "standard"
      }
    }

    service_name = "zoo"
    pod_management_policy = "Parallel"

    update_strategy {
      type = "RollingUpdate"
    }
  }
}
