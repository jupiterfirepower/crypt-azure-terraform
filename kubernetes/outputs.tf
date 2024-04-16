output client_certificate {
  value     = azurerm_kubernetes_cluster.cryptk8s.kube_config[0].client_certificate
  sensitive = true
}

output client_key {
  value     = azurerm_kubernetes_cluster.cryptk8s.kube_config[0].client_key
  sensitive = true
}

output "cluster_ca_certificate" {
  value     = azurerm_kubernetes_cluster.cryptk8s.kube_config[0].cluster_ca_certificate
  sensitive = true
}

output "cluster_password" {
  value     = azurerm_kubernetes_cluster.cryptk8s.kube_config[0].password
  sensitive = true
}

output "cluster_username" {
  value     = azurerm_kubernetes_cluster.cryptk8s.kube_config[0].username
  sensitive = true
}

output "host" {
  value     = azurerm_kubernetes_cluster.cryptk8s.kube_config[0].host
  sensitive = true
}

output "kube_config" {
  value     = azurerm_kubernetes_cluster.cryptk8s.kube_config_raw
  sensitive = true
}

#output "resource_group_name" {
#  value = azurerm_resource_group.crypteksrg.name
#}

# AKS cluster name 
output "kubernetes_cluster_name" {
  value       = azurerm_kubernetes_cluster.cryptk8s.name
  description = "Name of the AKS Cluster"
}

# AKS Cluster ID
output "kubernetes_cluster_id" {
  value       = azurerm_kubernetes_cluster.cryptk8s.id
  description = "ID of the AKS Cluster"
}

# FQDN of nodes
output "kubernetes_cluster_fqdn" {
  value = azurerm_kubernetes_cluster.cryptk8s.fqdn
}

# ACR ID
output "acr_id" {
  value = azurerm_container_registry.acr.id
}

# kubeconfig file path for next module
output "kubeconfig_file" {
  value = "~/.kube/cryptk8s"
}

# kubeconfig file
/*resource "local_file" "kubeconfig" {
  depends_on = [azurerm_kubernetes_cluster.cryptk8s]
  filename   = "kubeconfig"
  content    = azurerm_kubernetes_cluster.cryptk8s.kube_config_raw
}*/