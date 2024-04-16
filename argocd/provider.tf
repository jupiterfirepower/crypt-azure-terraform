/*data "terraform_remote_state" "vpc" {
  backend = "local"

  config = {
    path = "${path.module}/../terraform.tfstate"
  }
}*/

locals {
  kube_host = var.kube-host
  kube_client_certificate = base64decode(var.kube-client_certificate)
  kube_client_key         = base64decode(var.kube-client_key)
  kube_cluster_ca_certificate = base64decode(var.kube-cluster_ca_certificate)
}

provider "helm" {
    kubernetes {
       host                   = local.kube_host
       client_certificate     = local.kube_client_certificate
       client_key             = local.kube_client_key
       cluster_ca_certificate = local.kube_cluster_ca_certificate
    }
}

provider "kubernetes" {
    host                   = local.kube_host
    client_certificate     = local.kube_client_certificate
    client_key             = local.kube_client_key
    cluster_ca_certificate = local.kube_cluster_ca_certificate
}