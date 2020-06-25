variable "connect_external_port" {
}

variable "connect_plugin_path" {
}

resource "kubernetes_service" "connect" {
  metadata {
    name      = "connect"
    namespace = var.namespace
  }

  spec {
    port {
      protocol    = "TCP"
      port        = var.connect_external_port
      node_port   = var.connect_external_port
      target_port = "8080"
    }

    selector = {
      app = "connect"
    }

    type = "NodePort"
  }
}

resource "kubernetes_persistent_volume_claim" "connect_plugins_pv_claim" {
  metadata {
    name      = "connect-plugins-pv-claim"
    namespace = var.namespace
  }

  spec {
    access_modes = ["ReadWriteOnce"]

    resources {
      requests = {
        storage = "100M"
      }
    }
  }
}

resource "kubernetes_deployment" "connect" {
  metadata {
    name      = "connect"
    namespace = var.namespace
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "connect"
      }
    }

    template {
      metadata {
        labels = {
          app = "connect"
        }
      }

      spec {
        volume {
          name = "connect-plugins-storage"

          persistent_volume_claim {
            claim_name = "connect-plugins-pv-claim"
          }
        }

        container {
          name  = "connect"
          image = "confluentinc/cp-kafka-connect-base:5.2.2"

          port {
            container_port = 8080
          }

          env {
            name  = "CONNECT_BOOTSTRAP_SERVERS"
            value = "broker:9092"
          }

          env {
            name  = "CONNECT_GROUP_ID"
            value = "connect-group"
          }

          env {
            name  = "CONNECT_CONFIG_STORAGE_TOPIC"
            value = "connect-config-storage"
          }

          env {
            name  = "CONNECT_OFFSET_STORAGE_TOPIC"
            value = "connect-offset-storage"
          }

          env {
            name  = "CONNECT_STATUS_STORAGE_TOPIC"
            value = "connect-status-storage"
          }

          env {
            name  = "CONNECT_KEY_CONVERTER"
            value = "org.apache.kafka.connect.storage.StringConverter"
          }

          env {
            name  = "CONNECT_VALUE_CONVERTER"
            value = "org.apache.kafka.connect.storage.StringConverter"
          }

          env {
            name  = "CONNECT_INTERNAL_KEY_CONVERTER"
            value = "org.apache.kafka.connect.json.JsonConverter"
          }

          env {
            name  = "CONNECT_INTERNAL_VALUE_CONVERTER"
            value = "org.apache.kafka.connect.json.JsonConverter"
          }

          env {
            name  = "CONNECT_PLUGIN_PATH"
            value = var.connect_plugin_path
          }

          env {
            name  = "CONNECT_REST_ADVERTISED_HOST_NAME"
            value = "connect"
          }

          env {
            name  = "CONNECT_REST_PORT"
            value = "8080"
          }

          env {
            name  = "CONNECT_CONFIG_STORAGE_REPLICATION_FACTOR"
            value = "3"
          }

          env {
            name  = "CONNECT_OFFSET_STORAGE_REPLICATION_FACTOR"
            value = "3"
          }

          env {
            name  = "CONNECT_STATUS_STORAGE_REPLICATION_FACTOR"
            value = "3"
          }

          env {
            name  = "CONNECT_LOG4J_ROOT_LOGLEVEL"
            value = "INFO"
          }

          env {
            name  = "CLASSPATH"
            value = "/usr/share/java/monitoring-interceptors/monitoring-interceptors-5.1.1.jar"
          }

          env {
            name  = "CONNECT_PRODUCER_INTERCEPTOR_CLASSES"
            value = "io.confluent.monitoring.clients.interceptor.MonitoringProducerInterceptor"
          }

          env {
            name  = "CONNECT_CONSUMER_INTERCEPTOR_CLASSES"
            value = "io.confluent.monitoring.clients.interceptor.MonitoringConsumerInterceptor"
          }

          volume_mount {
            name       = "connect-plugins-storage"
            mount_path = var.connect_plugin_path
          }
        }
      }
    }
  }
}
