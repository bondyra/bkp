variable "schema_registry_external_port" {
}

resource "kubernetes_service" "schema_registry_service" {
  metadata {
    name      = "schema-registry-service"
    namespace = var.namespace
  }

  spec {
    port {
      port = 8081
    }

    selector = {
      app = "schema-registry"
    }
  }
}

resource "kubernetes_service" "schema_registry_service_outside" {
  metadata {
    name      = "schema-registry-service-outside"
    namespace = var.namespace
  }

  spec {
    port {
      protocol    = "TCP"
      port        = var.schema_registry_external_port
      node_port   = var.schema_registry_external_port
      target_port = "8081"
    }

    selector = {
      app = "schema-registry"
    }

    type = "NodePort"
  }
}

resource "kubernetes_deployment" "schema_registry" {
  metadata {
    name      = "schema-registry"
    namespace = var.namespace
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "schema-registry"
      }
    }

    template {
      metadata {
        labels = {
          app = "schema-registry"
        }
      }

      spec {
        container {
          name  = "schemaregistry"
          image = "confluentinc/cp-schema-registry:5.2.2"

          port {
            container_port = 8081
          }

          env {
            name  = "SCHEMA_REGISTRY_HOST_NAME"
            value = "schema-registry-service"
          }

          env {
            name  = "SCHEMA_REGISTRY_KAFKASTORE_CONNECTION_URL"
            value = "zookeeper:2181"
          }
        }
      }
    }
  }
}
