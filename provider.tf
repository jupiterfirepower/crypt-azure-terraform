terraform {
  required_version = "~> v1.8.0"

  required_providers {
    azurerm = {
      version = "~> 3.96.0"
      source = "hashicorp/azurerm"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 2.47.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.12.1"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.27.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0.5"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6.0"
    }
    /*
    random_id
    random_integer
    random_password
    random_pet
    random_shuffle
    random_string
    random_uuid

    resource "random_string" "randomname" {
    length  = 16
    count   = 2
    special = false
    upper   = false
    }
    */
    /*cloudflare = {
      source = "registry.terraform.io/cloudflare/cloudflare"
      version = "2.18.0"
    }*/
  }
}

provider "azurerm" {
#    features {}
    features {
      resource_group {
        prevent_deletion_if_contains_resources = false
      }
    }
}

provider "azuread" {
  environment = "${environment}"
}

#provider "kubernetes" {
#    config_path    = "~/.kube/config"
#    config_context = "minikube"
#}
