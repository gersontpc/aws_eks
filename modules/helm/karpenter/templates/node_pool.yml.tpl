apiVersion: karpenter.sh/v1beta1
kind: NodePool
metadata:
  name: ${NODEPOOL_NAME}
spec:
  template:
    metadata:
      labels:
%{ for labels in LABELS ~}
        - ${labels}
%{ endfor ~}
      annotations:
%{ for key, value in LABELS ~}
      ${key}: ${value}
%{ endfor ~}
    spec:
      requirements:
        - key: "karpenter.k8s.aws/instance-category"
          operator: In
          values:
%{ for instance_category in INSTANCE_CATEGORY ~}
          - ${instance_category}
%{ endfor ~}
        - key: "karpenter.k8s.aws/instance-cpu"
          operator: In
          values:
%{ for instance_cpu in INSTANCE_CPU ~}
          - ${instance_cpu}
%{ endfor ~}
        - key: "karpenter.k8s.aws/instance-hypervisor"
          operator: In
          values:
%{ for instance_hypervisor in INSTANCE_HYPERVISOR ~}
          - ${instance_hypervisor}
%{ endfor ~}
        - key: "karpenter.k8s.aws/instance-generation"
          operator: Gt
          values:
%{ for instance_generation in INSTANCE_GENERATION ~}
          - ${instance_generation}
%{ endfor ~}
        - key: "topology.kubernetes.io/zone"
          operator: In
          values:
%{ for availability_zone in AVAILABILITY_ZONES ~}
          - ${availability_zone}
%{ endfor ~}
        - key: "kubernetes.io/arch"
          operator: In
          values: ["arm64", "amd64"]
%{ for cpu_arch in CPU_ARQ ~}
          - ${CPU_ARQ}
%{ endfor ~}
        - key: "karpenter.sh/capacity-type"
          operator: In
          values:
%{ for capacity_type in CAPACITY_TYPE ~}
          - ${capacity_type}
%{ endfor ~}
  disruption:
    consolidationPolicy: ${DISRUPTION_CONSOLIDATION_POLICY}
    consolidateAfter: ${DISRUPTION_COSOLIDATION_AFTER}
    expireAfter: ${DISRUPTION_EXPIRE_AFTER}
  limits:
    cpu: ${CPU_LIMIT}
    memory: ${MEMORY_LIMIT}
  weight: ${NODEPOOL_WEIGHT}
