resource "kubernetes_pod" "kafka_maintenance_pod" {
  metadata {
    name = "kafka-maintenance"
    namespace = var.namespace
  }

  spec {
    container {
      name  = "kafka-maintenance"
      image = "solsson/kafka"
      command = ["sleep", "infinity"]
    }
  }
}
