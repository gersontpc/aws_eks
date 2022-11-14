apiVersion: karpenter.k8s.aws/v1alpha1
kind: AWSNodeTemplate
metadata:
  name: ${PROVIDER_NAME}
spec:
  subnetSelector:
    karpenter.sh/discovery: ${CLUSTER_NAME}
  launchTemplate: ${LAUNCH_TEMPLATE}
