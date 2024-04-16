# creating azure resource group
resource "azurerm_resource_group" "crypteksrg" {
  location = var.resource_group_location
  name     = var.resource_group_name
}

# datasource to get Latest Azure AKS latest Version
data "azurerm_kubernetes_service_versions" "current" {
  location        = var.resource_group_location
  include_preview = false
}

# creating azure container registry 
resource "azurerm_container_registry" "acr" {
  name                = "cryptazure${lower(var.environment)}registry"
  resource_group_name = azurerm_resource_group.crypteksrg.name  # var.resource_group_name
  location            = azurerm_resource_group.crypteksrg.location  # var.resource_group_location
  sku                 = "Basic"
  admin_enabled       = false
  #admin_username      = "admin"
  #admin_password      = "adminpassword"
  # depends_on = [ azurerm_resource_group.crypteksrg ]
}

# creating AKS cluster
resource "azurerm_kubernetes_cluster" "cryptk8s" {
  #location           = azurerm_resource_group.crypteksrg.location
  location            = azurerm_resource_group.crypteksrg.location # var.resource_group_location
  name                = var.cluster_name
  #resource_group_name = azurerm_resource_group.crypteksrg.name
  resource_group_name = azurerm_resource_group.crypteksrg.name # var.resource_group_name
  
  dns_prefix          = var.dns_prefix
  kubernetes_version  = data.azurerm_kubernetes_service_versions.current.latest_version # automatic upgrades
  node_resource_group = "crypt-${lower(var.environment)}-node-group"

  tags                = {
    Environment = var.environment
  }

  default_node_pool {
    name       = "sysagentpool"
    vm_size    = var.node_vm_size
    node_count = var.agent_node_count
    # vnet_subnet_id = data.azurerm_subnet.app_aks.id
    # vnet_subnet_id  = var.vnet_subnet_id
    # zones           = [1, 2, 3] not available in westus

    type = "VirtualMachineScaleSets"
    orchestrator_version = data.azurerm_kubernetes_service_versions.current.latest_version # automatic upgrades
    enable_auto_scaling = true
    min_count           = var.min_node_count
    max_count           = var.max_node_count

    node_labels = {
      "nodepool-type" = "system"
      "environment"   = "${var.environment}"
      "nodepoolos"    = "linux"
    }
    tags = {
      "nodepool-type" = "system"
      "environment"   = "${var.environment}"
      "nodepoolos"    = "linux"
    }
  }

  identity {
    type = "SystemAssigned"
  }

  linux_profile {
    admin_username = var.admin_username

    ssh_key {
      key_data = file(var.ssh_public_key)
    }
  }

  network_profile {
    network_plugin    = "kubenet" # kubenet - azure (CNI),  "azure"
    #network_plugin    = "azure" #  
    load_balancer_sku = "standard"
  }

  auto_scaler_profile {
    balance_similar_node_groups = true
  }
  
  depends_on = [ azurerm_resource_group.crypteksrg ]
}

resource "null_resource" "kubeconfig_save" {
    provisioner "local-exec" {
    command = <<EOT
    echo "${azurerm_kubernetes_cluster.cryptk8s.kube_config_raw}" > ~/.kube/cryptk8s
    EOT
    }
    depends_on = [azurerm_kubernetes_cluster.cryptk8s]
}

#resource "azurerm_management_group" "root" {
  #display_name = "Root Management Group"
#}

data azurerm_subscription "current" { }

#data azurerm_subscription "my_subscription" {
#  subscription_id = "00000000-0000-0000-0000-000000000000"
#}

#resource "azurerm_management_group_subscription_association" "add_subscription_to_mg" {
#  management_group_id = azurerm_management_group.root.id
#  subscription_id     = "/subscriptions/${data.azurerm_subscription.current.subscription_id}"
#}

/*
resource "azurerm_role_definition" "role_assignment_contributor" {
    name  = "Role Assignment Owner"
    scope = azurerm_management_group.root.id
    description = "A role designed for writing and deleting role assignments"

    permissions {
        actions = [
            "Microsoft.Authorization/roleAssignments/write",
            "Microsoft.Authorization/roleAssignments/delete",
        ]
        not_actions = []
    }

    assignable_scopes = [
        azurerm_management_group.root.id
    ]

    #depends_on = [azurerm_kubernetes_cluster.cryptk8s]
}

# role assignment for AKS to pull images from ACR
resource "azurerm_role_assignment" "role_acr_pull" {
  scope                            = azurerm_container_registry.acr.id
  role_definition_name             = "AcrPull"
  principal_id                     = azurerm_kubernetes_cluster.cryptk8s.kubelet_identity[0].object_id
  skip_service_principal_aad_check = true
}
*/

locals {
  cluster_principal_id   = azurerm_kubernetes_cluster.cryptk8s.identity[0].principal_id
  agentpool_principal_id = azurerm_kubernetes_cluster.cryptk8s.kubelet_identity[0].object_id
}
/*
data "azuread_service_principal" "aks-enterprise-application" {
  object_id = local.cluster_principal_id      
}
data "azuread_service_principal" "aks-enterprise-application-managed-id" {
  object_id = local.agentpool_principal_id
}

data "azuread_service_principal" "aks-enterprise-application" {
  display_name = var.cluster_name
  depends_on = [
    azurerm_kubernetes_cluster.cryptk8s,
  ]
}

data "azuread_service_principal" "aks-enterprise-application-managed-id" {
  display_name = "${var.cluster_name}-agentpool"
  depends_on = [
    azurerm_kubernetes_cluster.cryptk8s,
  ]
}

resource "azurerm_role_assignment" "aks-rg-contributor" {
  scope                = "/subscriptions/${data.azurerm_subscription.current.subscription_id}"
  role_definition_name = "Contributor"
  principal_id         = local.cluster_principal_id
}

resource "azurerm_role_assignment" "aks-rg-network-contributor" {
  scope                = "/subscriptions/${data.azurerm_subscription.current.subscription_id}"
  role_definition_name = "Network Contributor"
  principal_id         = local.cluster_principal_id
}*/

# The user assigned managed identity created and used by the cluster needs acrPull role on the Azure Registries
# to be able to pull Docker images
/*resource "azurerm_role_assignment" "aks-agentpool-rg-acr-acrpull" {
  scope                = "/subscriptions/${data.azurerm_subscription.current.subscription_id}/resourceGroups/${var.resource_group_name}"
  role_definition_name = "AcrPull"
  principal_id         = data.azuread_service_principal.aks-enterprise-application-managed-id.id
}
*/

# role assignment for AKS to pull images from ACR
resource "azurerm_role_assignment" "role_acr_pull" {
  #scope                = "/subscriptions/${data.azurerm_subscription.current.subscription_id}/resourceGroups/${var.resource_group_name}"
  scope                            = azurerm_container_registry.acr.id
  role_definition_name             = "AcrPull"
  principal_id                     = local.agentpool_principal_id
  skip_service_principal_aad_check = true
  depends_on = [ azurerm_container_registry.acr ]
}

# role assignment for AKS to pull images from ACR
resource "azurerm_role_assignment" "role_acr_push" {
  #scope                = "/subscriptions/${data.azurerm_subscription.current.subscription_id}/resourceGroups/${var.resource_group_name}"
  scope                            = azurerm_container_registry.acr.id
  role_definition_name             = "AcrPush"
  principal_id                     = local.agentpool_principal_id
  skip_service_principal_aad_check = true
  depends_on = [ azurerm_container_registry.acr ]
}




/*resource "null_resource" "kubeconfig_save-argocd-deploy" {
  provisioner "local-exec" {
    working_dir = "./argocd"
    command = <<EOT
    export KUBECONFIG=~/.kube/cryptk8s && \
    kubectl create namespace argocd && \
    kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/core-install.yaml && \
    kubectl -n argocd-${lower(var.environment)} get secret argocd-initial-admin-secret -o jsonpath={.data.password} | base64 -d > argocd-login.txt
    EOT
  }
  depends_on = [null_resource.kubeconfig_save]
}*/



#    kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml && \
/*resource "null_resource" "fix_dns_problem" {
    provisioner "local-exec" {
    command = <<EOT
    export KUBECONFIG=~/.kube/cryptk8s && az aks get-credentials --resource-group ${azurerm_resource_group.crypteksrg.name} --name ${var.cluster_name}
    EOT
    }
    depends_on = [null_resource.kubeconfig_save]
}*/

#kubectl config current-context                       # показать текущий контекст (current-context)
#kubectl config use-context my-cluster-name 

/*resource "null_resource" "argocd-namespace" {
  provisioner "local-exec" {
    working_dir = "./argocd"
    command     = "export KUBECONFIG=~/.kube/cryptk8s && kubectl create namespace argocd"
  }
  depends_on = [null_resource.kubeconfig_save]
}

resource "null_resource" "argocd-deploy-in-eks" {
  provisioner "local-exec" {
    working_dir = "./argocd"
    command     = "export KUBECONFIG=~/.kube/cryptk8s && kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml"
  }
  depends_on = [null_resource.argocd-namespace]
}

resource "null_resource" "password" {
  provisioner "local-exec" {
    working_dir = "./argocd"
    command     = "export KUBECONFIG=~/.kube/cryptk8s && kubectl -n argocd-${lower(var.environment)} get secret argocd-initial-admin-secret -o jsonpath={.data.password} | base64 -d > argocd-login.txt"
  }
  depends_on = [null_resource.argocd-deploy-in-eks]
}

resource "null_resource" "argocd-port-forwarding" {
  provisioner "local-exec" {
    working_dir = "./argocd"
    command     = "export KUBECONFIG=~/.kube/cryptk8s && kubectl port-forward svc/argocd-server -n argocd 8080:443"
  }
  depends_on = [null_resource.argocd-deploy-in-eks]
}*/


# && \
# export KUBECONFIG=~/.kube/cryptk8s

#echo "${azurerm_kubernetes_cluster.cryptk8s.kube_config_raw}" > ~/.kube/cryptk8s

#rm -rf /tmp/kubeconfig 
#echo "${azurerm_kubernetes_cluster.cryptk8s.kube_config_raw}" > /tmp/kubeconfig

#kube_admin_config = azurerm_kubernetes_cluster.cryptk8s.kube_admin_config_raw
#kubectl ${var.command} --kubeconfig <(echo ${base64encode(var.kube_admin_config)} | base64 --decode)

#resource "null_resource" "kubectl" {
#  provisioner "local-exec" {
#    command = "kubectl ${var.command} --kubeconfig <(echo $KUBECONFIG | base64 --decode)"
#    interpreter = ["/bin/bash", "-c"]
#environment = {
#      KUBECONFIG = base64encode(var.kubeconfig)
#  }
#}