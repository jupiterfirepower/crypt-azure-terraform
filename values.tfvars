# AKS
agent_node_count = 2
# aks_service_principal_app_id = ""
# aks_service_principal_client_secret = ""

admin_username = "cryptadm"
cluster_name = "cryptk8s"
dns_prefix   = "dnscryptk8s"

#admin_username = "crypt"
#cluster_name = "cryptk8s"
#dns_prefix   = "dnscryptk8s"
# resource_group_location = "West Europe"
resource_group_name = "crypt-terraform-kubernetes-eks-rg"
#resource_group_name = "crypt-eks-rg"
resource_group_location = "West US"
#resource_group_location = "East US"
ssh_public_key = "~/.ssh/id_rsa.pub"

vnetCIDR            = ["10.163.0.0/16"]
subnetCIDRs         = ["10.163.0.0/21"]
min_node_count      = 2
max_node_count      = 4
node_vm_size        = "Standard_DS2_v2" # Dev/Test 2 - 100 nodes.
environment         = "dev"
#environment         = "Development"
