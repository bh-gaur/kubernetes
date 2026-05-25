# main.tf
terraform {
  required_version = ">= 1.5.0"
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.23.0"
    }
  }
  backend "kubernetes" {
    secret_suffix = "idp-state-backend"
    namespace     = "idp-system"
  }
}

variable "environment_name" { type = string }
variable "owner_team"       { type = string }
variable "lifecycle_tier"   { type = string }
variable "cpu_limit"        { type = string }
variable "memory_limit"     { type = string }

resource "kubernetes_namespace" "env_space" {
  metadata {
    name = "env-${var.environment_name}"
    labels = {
      "idp.internal/managed-by" = "backstage-scaffolder"
      "idp.internal/owner-team" = var.owner_team
      "idp.internal/lifecycle"  = var.lifecycle_tier
    }
  }
}

resource "kubernetes_resource_quota" "compute_caps" {
  metadata {
    name      = "compute-quota"
    namespace = kubernetes_namespace.env_space.metadata[0].name
  }
  spec {
    hard = {
      "limits.cpu"    = var.cpu_limit
      "limits.memory" = var.memory_limit
      "requests.cpu"  = "${float64(var.cpu_limit) / 2}"
      "requests.memory" = "${parseInt(var.memory_limit, 10) / 2}Gi"
    }
  }
}