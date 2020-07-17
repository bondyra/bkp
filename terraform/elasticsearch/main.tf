variable "namespace" {
}

variable "elasticsearch_external_port" {
}

resource "kubernetes_service" "elasticsearch_service" {
  metadata {
    name      = "elasticsearch-service"
    namespace = var.namespace
  }

  spec {
    port {
      port = 9020
    }

    selector = {
      app = "elasticsearch"
    }
  }
}

resource "kubernetes_service" "elasticsearch_service_outside" {
  metadata {
    name      = "elasticsearch-service-outside"
    namespace = var.namespace
  }

  spec {
    port {
      protocol    = "TCP"
      port        = var.elasticsearch_external_port
      node_port   = var.elasticsearch_external_port
      target_port = "9020"
    }

    selector = {
      app = "elasticsearch"
    }

    type = "NodePort"
  }
}

resource "kubernetes_deployment" "elasticsearch" {
  metadata {
    name      = "elasticsearch"
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
            container_port = 9020
          }


          resources {
            limits {
              memory = "300Mi"
            }

            requests {
              cpu    = "100m"
              memory = "100Mi"
            }
          }
        }
      }
    }
  }
}
