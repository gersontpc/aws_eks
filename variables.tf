variable "cluster_name" {
  default = "gson-labs-new"
}

# variable "vpc_id" {
#   description = "ID of the VPC where the cluster and its nodes will be provisioned"
#   type        = string
#   default     = null
# }

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
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}

variable "karpenter_capacity_type" {
  type        = list(any)
  description = "Capacity Type; Ex spot, on_demand"
  default = [
    "on-demand"
  ]
}

variable "karpenter_instance_family" {
  type        = list(any)
  description = "Instance family list to launch on karpenter"
  default = [
    "t3"
  ]
}

variable "karpenter_instance_sizes" {
  type        = list(any)
  description = "Instance sizes to diversify into instance family"
  default = [
    "nano"
  ]
}

variable "karpenter_availability_zones" {
  type        = list(any)
  description = "Availability zones to launch nodes"
  default = [
    "us-east-1a",
    "us-east-1b",
    "us-east-1c"
  ]
}

variable "karpenter_cpu_limit" {
  type        = string
  description = "CPU Limits to launch total nodes"
  default     = "100"
}

variable "karpenter_memory_limit" {
  type        = string
  description = "Memory Limits to launch total nodes"
  default     = "4000Gi"
}

variable "addon_coredns_version" {
  type        = string
  description = "CoreDNS addon version"
  default     = "v1.8.7-eksbuild.1"
}

variable "addon_kubeproxy_version" {
  type        = string
  description = "KubeProxy addon version"
  default     = "v1.20.4-eksbuild.2"
}

variable "addon_cni_version" {
  type        = string
  description = "VPC CNI addon version"
  default     = "v1.11.2-eksbuild.1"
}