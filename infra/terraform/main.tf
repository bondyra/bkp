provider "kubernetes" {}

terraform {
  backend "local" {
    path = "/home/bondyra/bkp-state.tfstate"
  }
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
  zk_dependency = module.zookeeper
}

module "aux" {
  source = "./kafka-aux"
  namespace = kubernetes_namespace.kafka_workspace.metadata[0].name
}

module "connect" {
  source = "./connect"
  namespace = kubernetes_namespace.kafka_workspace.metadata[0].name
}
