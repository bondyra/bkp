provider "kubernetes" {}

terraform {
  backend "local" {
    workspace_dir = "/home/bondyra/bkp-state"
  }
}

variable "schema_registry_port" {
}

variable "control_center_port" {
}

variable "connect_port" {
}

variable "connect_pv_claim_name" {
}

variable "connect_plugin_path" {
}

variable "kafka_maintenance_pod_name" {
}

variable "elasticsearch_port" {
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
}

module "kafka-aux" {
  source = "./kafka-aux"
  namespace = kubernetes_namespace.kafka_workspace.metadata[0].name

  schema_registry_external_port = var.schema_registry_port
  control_center_external_port = var.control_center_port

  connect_external_port = var.connect_port
  connect_pv_claim_name = var.connect_pv_claim_name
  connect_plugin_path = var.connect_plugin_path

  pod_name = var.kafka_maintenance_pod_name
}

module "elasticsearch" {
  source = "./elasticsearch"
  namespace = kubernetes_namespace.kafka_workspace.metadata[0].name

  elasticsearch_external_port = var.elasticsearch_port
}