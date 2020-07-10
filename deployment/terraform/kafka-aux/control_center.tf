variable "control_center_external_port" {
}

resource "kubernetes_service" "control_center" {
  metadata {
    name      = "control-center"
    namespace = var.namespace
  }

  spec {
    port {
      protocol    = "TCP"
      port        = var.control_center_external_port
      node_port   = var.control_center_external_port
      target_port = "9021"
    }

    selector = {
      app = "control-center"
    }

    type = "NodePort"
  }
}

resource "kubernetes_deployment" "control_center" {
  metadata {
    name      = "control-center"
    namespace = var.namespace
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "control-center"
      }
    }

    template {
      metadata {
        labels = {
          app = "control-center"
        }
      }

      spec {
        container {
          name  = "control-center"
          image = "confluentinc/cp-enterprise-control-center:5.2.2"

          port {
            container_port = 9021
          }

          env {
            name  = "CONTROL_CENTER_BOOTSTRAP_SERVERS"
            value = "broker:9092"
          }

          env {
            name  = "CONTROL_CENTER_ZOOKEEPER_CONNECT"
            value = "zookeeper:2181"
          }

          env {
            name  = "CONTROL_CENTER_CONNECT_CLUSTER"
            value = "connect:30808"
          }

          env {
            name  = "CONTROL_CENTER_SCHEMA_REGISTRY_URL"
            value = "http://schema-registry-service:8081"
          }

          env {
            name  = "CONTROL_CENTER_REPLICATION_FACTOR"
            value = "1"
          }

          env {
            name  = "CONTROL_CENTER_INTERNAL_TOPICS_PARTITIONS"
            value = "1"
          }

          env {
            name  = "CONTROL_CENTER_MONITORING_INTERCEPTOR_TOPIC_PARTITIONS"
            value = "1"
          }

          env {
            name  = "CONFLUENT_METRICS_TOPIC_REPLICATION"
            value = "1"
          }

          env {
            name  = "PORT"
            value = "9021"
          }
        }
      }
    }
  }
}

