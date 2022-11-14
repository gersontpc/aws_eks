apiVersion: karpenter.sh/v1alpha5
kind: Provisioner
metadata:
  name: ${PROVIDER_NAME}
spec:
  requirements:
    - key: karpenter.sh/capacity-type
      operator: In
      values:
%{ for capacity_type in CAPACITY_TYPE ~}
      - ${capacity_type}
%{ endfor ~}
    - key: karpenter.k8s.aws/instance-family
      operator: In
      values:
%{ for instance_family in INSTANCE_FAMILY ~}
      - ${instance_family}
%{ endfor ~}
    - key: karpenter.k8s.aws/instance-size
      operator: In
      values:
%{ for instance_size in INSTANCE_SIZES ~}
      - ${instance_size}
%{ endfor ~}
    - key: "topology.kubernetes.io/zone"
      operator: In
      values:
%{ for availability_zone in AVAILABILITY_ZONES ~}
      - ${availability_zone}
%{ endfor ~}
  limits:
    resources:
      cpu: ${CPU_LIMIT}
      memory: ${MEMORY_LIMIT}
  providerRef:                                                # optional, recommended to use instead of `provider`
    name: ${PROVIDER_NAME}
  ttlSecondsAfterEmpty: ${TTL_SCALING_EMPTY}                  # optional (30), but never scales down if not set
  ttlSecondsUntilExpired: ${TTL_NODES}                        # optional(2592000), but never expires
