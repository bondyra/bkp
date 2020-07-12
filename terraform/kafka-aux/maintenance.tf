variable "pod_name" {
}

resource "kubernetes_pod" "kafka_maintenance_pod" {
  metadata {
    name = var.pod_name
    namespace = var.namespace
  }

  spec {
    container {
      name  = var.pod_name
      image = "solsson/kafka"
      command = ["sleep", "infinity"]
    }
  }
}
