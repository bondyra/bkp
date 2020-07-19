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
      port = 9200
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
      target_port = "9200"
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
        app = "elasticsearch"
      }
    }

    template {
      metadata {
        labels = {
          app = "elasticsearch"
        }
      }

      spec {
        container {
          name  = "elasticsearch"
          image = "bkp-es:latest"
          image_pull_policy = "Never"

          port {
            container_port = 9200
          }


          resources {
            limits {
              cpu    = "100m"
              memory = "900Mi"
            }

            requests {
              cpu    = "50m"
              memory = "750Mi"
            }
          }
        }
      }
    }
  }
}
