# creating virtual network
/*module vnetwork {
  source                = "./vnetwork"
  resource_group_name   = var.resource_group_name
  location              = var.resource_group_location
  address_space         = var.vnetCIDR
  subnet_address_prefix = var.subnetCIDRs
  environment           = var.environment
}*/

# Creating EKS
module eks {
  source                  = "./kubernetes"
  resource_group_location = var.resource_group_location
  resource_group_name     = var.resource_group_name
  admin_username          = var.admin_username
  cluster_name            = var.cluster_name
  dns_prefix              = var.dns_prefix
  node_vm_size            = var.node_vm_size
  min_node_count          = var.min_node_count
  max_node_count          = var.max_node_count
  #vnet_subnet_id          = module.vnetwork.public_subnet_id
  environment             = var.environment
}

# Creating ArgoCd
module argocd {
  source              = "./argocd"
  eks-name            = module.eks.kubernetes_cluster_name
  kube-config-path    = module.eks.kubeconfig_file
  kube-host           = module.eks.host
  kube-client_certificate = module.eks.client_certificate
  kube-client_key         = module.eks.client_key
  kube-cluster_ca_certificate  = module.eks.cluster_ca_certificate
  environment         = var.environment
}

# Creating Tekton
module tekton {
  source              = "./tekton"
  eks-name            = module.eks.kubernetes_cluster_name
  kube-host           = module.eks.host
  kube-client_certificate = module.eks.client_certificate
  kube-client_key         = module.eks.client_key
  kube-cluster_ca_certificate  = module.eks.cluster_ca_certificate
  environment         = var.environment
}


# Creating Grafana
/*module grafana {
  source              = "./grafana"
  eks-name            = module.eks.kubernetes_cluster_name
  kube-host           = module.eks.host
  kube-client_certificate = module.eks.client_certificate
  kube-client_key         = module.eks.client_key
  kube-cluster_ca_certificate  = module.eks.cluster_ca_certificate
  environment         = var.environment
}*/
/*
# Creating Prometheus and Grafana
module prometheus {
  source              = "./prometheus"
  eks-name            = module.eks.kubernetes_cluster_name
  kube-host           = module.eks.host
  kube-client_certificate = module.eks.client_certificate
  kube-client_key         = module.eks.client_key
  kube-cluster_ca_certificate  = module.eks.cluster_ca_certificate
  environment         = var.environment
}

# Creating Istio
module istio {
  source              = "./istio"
  eks-name            = module.eks.kubernetes_cluster_name
  kube-host           = module.eks.host
  kube-client_certificate = module.eks.client_certificate
  kube-client_key         = module.eks.client_key
  kube-cluster_ca_certificate  = module.eks.cluster_ca_certificate
  environment         = var.environment
}*/
/*
# Creating Keycloak
module mkeycloak {
  source              = "./mkeycloak"
  eks-name            = module.eks.kubernetes_cluster_name
  kube-host           = module.eks.host
  kube-client_certificate = module.eks.client_certificate
  kube-client_key         = module.eks.client_key
  kube-cluster_ca_certificate  = module.eks.cluster_ca_certificate
  http_relative_path = "/"
  replica_count = 1
  cpu_request = "50m"
  memory_request = "100Mi"
  memory_limit = "200Mi"
  enable_autoscaling = false
  enable_metrics = false
  enable_service_monitor  = false
  enable_prometheus_rule = false
  prometheus_namespace = "monitoring"
  keycloak_logging_level = "INFO"
  domain = "cryptkeycloak.org"
  admin_user = "admin"
  keycloak_admin_password = "passWord123"
  postgres_admin_password = "passWord123"
  postgres_user_password = "passWord123"
  environment         = var.environment
}*/


#base64decode(module.eks.kube_config.cluster_ca_certificate)