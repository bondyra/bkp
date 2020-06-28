provider "kubernetes" {}

terraform {
  backend "local" {
    path = "/home/bondyra/bkp-state.tfstate"
  }
}

variable "broker_port" {
}

variable "schema_registry_port" {
}

variable "control_center_port" {
}

variable "connect_port" {
}

variable "connect_plugin_path" {
}

resource "kubernetes_namespace" "kafka_workspace" {
  metadata {
    name = terraform.workspace
  }
}

resource "kubernetes_cluster_role_binding" "admin_rbac" {
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind = "ClusterRole"
    name = "cluster-admin"
  }
  metadata {
    name = "terraform-admin-for-default-sa"
  }
  subject {
    kind = "ServiceAccount"
    name = "default"
    namespace  = terraform.workspace
  }
}

module "zookeeper" {
  source = "./zookeeper"
  namespace = kubernetes_namespace.kafka_workspace.metadata[0].name
}

module "kafka" {
  source = "./kafka"
  namespace = kubernetes_namespace.kafka_workspace.metadata[0].name
  external_port = var.broker_port
}

module "kafka-aux" {
  source = "./kafka-aux"
  namespace = kubernetes_namespace.kafka_workspace.metadata[0].name

  schema_registry_external_port = var.schema_registry_port
  control_center_external_port = var.control_center_port

  connect_external_port = var.connect_port
  connect_plugin_path = var.connect_plugin_path
}
