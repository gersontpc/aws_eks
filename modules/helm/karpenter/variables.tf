variable "karpenter_nodepool" {
  description = "Set capacity for Karpenter nodes"
  type = list(object({
    labels                  = map(string)
    nodepool_name           = string
    instance_category       = list(string)
    instance_cpu            = list(string)
    instance_hypervisor     = list(string)
    instance_generation     = list(string)
    avaiability_zones       = list(string)
    cpu_arq                 = list(string)
    capacity_type           = list(string)
    disruption_policy       = string
    disruption_after        = string
    disruption_after_expire = string
    cpu_limit               = number
    memory_limit            = number
    nodepool_weight         = number
  }))
}