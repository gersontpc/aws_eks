variable "cluster_name" {
  default     = "backend"
  description = "Cluster name"
  type        = string
}

variable "subnet_ids" {
  type        = list(string)
  description = "Subnets Ids"
  default     = []
}

variable "k8s_version" {
  type        = string
  description = "(optional) describe your variable"
}

variable "tags" {
  type        = map(string)
  description = "A map of tags to add to all resources"
}

# AWS Auth

variable "map_accounts" {
  description = "Additional AWS account numbers to add to the aws-auth configmap."
  type        = list(string)
  default     = []
}

variable "map_roles" {
  description = "Additional IAM roles to add to the aws-auth configmap."
  type = list(object({
    rolearn  = string
    username = string
    groups   = list(string)
  }))
  default = []
}

variable "map_users" {
  description = "Additional IAM users to add to the aws-auth configmap."
  type = list(object({
    userarn  = string
    username = string
    groups   = list(string)
  }))
  default = []
}

# Node Group

variable "node_groups" {
  description = "config block for node groups"
  type = list(object({
    name                       = string
    labels                     = map(string)
    instance_types             = list(string)
    capacity_type              = string
    max_unavailable_percentage = number
    desired_capacity           = number
    max_capacity               = number
    min_capacity               = number
  }))
}

# Karpenter Capacity

variable "karpenter_provider" {
  description = "Set capacity for Karpenter nodes"
  type = list(object({
    provider_name      = string
    capacity_type      = list(string)
    instance_family    = list(string)
    instance_sizes     = list(string)
    availability_zones = list(string)
    cpu_limit          = number
    memory_limit       = string
    ttl_scaling_empty  = number
    ttl_nodes          = number
  }))
}

# AddOns

variable "addon_coredns_version" {
  type        = string
  description = "CoreDNS addon version"
  default     = "v1.8.7-eksbuild.3"
}

variable "addon_kubeproxy_version" {
  type        = string
  description = "KubeProxy addon version"
  default     = "v1.23.8-eksbuild.2"
}

variable "addon_cni_version" {
  type        = string
  description = "VPC CNI addon version"
  default     = "v1.12.0-eksbuild.1"
}
