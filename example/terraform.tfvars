subnet_ids  = ["subnet-a7f29fc0", "subnet-5a2f4474", "subnet-267a466c"]
k8s_version = "1.23"

node_groups = [
  {
    name = "infra-resources"
    labels = {
      "namespace" = "karpenter-poc",
      "env"       = "dev"
    }
    instance_types = [
      "t3.medium",
      "t3a.medium"
    ]
    capacity_type              = "SPOT"
    max_unavailable_percentage = 50
    desired_capacity           = 2
    max_capacity               = 5
    min_capacity               = 2
  }
]

karpenter_provider = [
  {
    provider_name = "karpenter"
    capacity_type = [
      "on-demand",
      "spot"
    ]
    instance_family = [
      "t3",
      "t2",
      "t3a"
    ]
    instance_sizes = [
      "medium"
    ]
    availability_zones = [
      "us-east-1a",
      "us-east-1b",
      "us-east-1c"
    ]
    cpu_limit         = "20"
    memory_limit      = "10000Gi"
    ttl_scaling_empty = "30"
    ttl_nodes         = "2592000"
  }
]

tags = {
  "Environment" = "Lab"
}

# map_roles = [
#   {
#     rolearn  = "arn:aws:iam::66666666666:role/role1"
#     username = "role1"
#     groups   = ["system:masters"]
#   },
#   {
#     rolearn  = "arn:aws:iam::66666666666:role/role2"
#     username = "role1"
#     groups   = ["system:masters"]
#   }
# ]

# map_users = [
#   {
#     userarn  = "arn:aws:iam::66666666666:user/user1"
#     username = "user1"
#     groups   = ["system:masters"]
#   },
#   {
#     userarn  = "arn:aws:iam::66666666666:user/user2"
#     username = "user2"
#     groups   = ["system:masters"]
#   },
# ]

# map_accounts = [
#   "777777777777",
#   "888888888888",
# ]
