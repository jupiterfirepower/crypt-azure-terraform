# Azure AKS Cluster
variable agent_node_count { 
    type= number
    default = 2 
}

# The following two variable declarations are placeholder references.
# Set the values for these variable in terraform.tfvars
# variable aks_service_principal_app_id { type= string}
# variable aks_service_principal_client_secret { type= string}
variable admin_username { type= string}
variable cluster_name { type= string}
variable dns_prefix { type= string}

variable resource_group_location {
  type= string
  description = "Location of the resource group."
  default     = "westus"
}

variable resource_group_name {
  type= string
  description = "Resource group name that is unique in your Azure subscription."
}

variable ssh_public_key {
  default = "~/.ssh/id_rsa.pub"
}

# Virtual Network CIDR
variable "vnetCIDR" {
  type        = list(string)
  description = "Virtual Network CIDR"
}

# subnet CIDRs
variable "subnetCIDRs" {
  type        = list(string)
  description = "Subnet CIDRs"
}

# size of worker node
variable "node_vm_size" {
  type        = string
  description = "Size of worker node"
}

# max node count 
variable "max_node_count" {
  type        = number
  description = "Maximun node count for worker node"
}

# min node count 
variable "min_node_count" {
  type        = number
  description = "Minimum node count for worker node"
}

# environment
variable "environment" {
  type        = string
  description = "Environment"
}

