# https://istio.io/latest/docs/ops/deployment/requirements/

resource "helm_release" "istio_base" {
  count            = local.create_istio
  name             = "istio-base"
  chart            = "./helm/istio/base"
  namespace        = "istio-system"
  create_namespace = true

  depends_on = [
    aws_eks_cluster.master,
    aws_eks_node_group.this
  ]
}

resource "helm_release" "istio_discovery" {
  count     = local.create_istio
  name      = "istio-discovery"
  chart     = "./helm/istio/istio-control/istio-discovery"
  namespace = "istio-system"

  depends_on = [
    helm_release.istio_base
  ]
}

resource "helm_release" "istio_operator" {
  count     = local.create_istio
  name      = "istio-operator"
  chart     = "./helm/istio/istio-operator"
  namespace = "istio-system"

  depends_on = [
    helm_release.istio_base
  ]
}

resource "helm_release" "istio_ingress" {
  count     = local.create_istio
  name      = "istio-ingress"
  chart     = "./helm/istio/gateways/istio-ingress"
  namespace = "istio-system"

  set {
    name  = "gateways.istio-ingressgateway.autoscaleMin"
    value = 2
  }

  depends_on = [
    helm_release.istio_base
  ]
}

resource "helm_release" "istio_egress" {
  count     = local.create_istio
  name      = "istio-egress"
  chart     = "./helm/istio/gateways/istio-egress"
  namespace = "istio-system"

  set {
    name  = "gateways.istio-egressgateway.autoscaleMin"
    value = 2
  }

  depends_on = [
    helm_release.istio_base
  ]
}

resource "kubectl_manifest" "ingress_daemonset" {
  count     = local.create_istio
  yaml_body = <<EOF
apiVersion: install.istio.io/v1alpha1
kind: IstioOperator
metadata:
  name: istio-ingress-daemonset
  namespace: istio-system
spec:
  components:
    ingressGateways:
    - name: istio-ingressgateway
      enabled: true
      k8s:
        overlays:
        - apiVersion: apps/v1
          kind: Deployment
          name: istio-ingressgateway
          patches:
          - path: kind
            value: DaemonSet
          - path: spec.strategy
          - path: spec.updateStrategy
            value:
              rollingUpdate:
                maxUnavailable: 1
              type: RollingUpdate
        - apiVersion: apps/v1
          kind: Service
          name: istio-ingressgateway
          patches:
          - path: spec.type
            value: NodePort
EOF

  depends_on = [
    helm_release.istio_ingress,
    helm_release.istio_operator
  ]
}

resource "kubectl_manifest" "istio_gateway" {
  count     = local.create_istio
  yaml_body = <<EOF
apiVersion: networking.istio.io/v1beta1
kind: Gateway
metadata:
  name: ${var.cluster_name}-gateway
spec:
  selector:
    istio: ingressgateway # use istio default controller
  servers:
  - port:
      number: 80
      name: http
      protocol: HTTP
    hosts:
    - "*"
EOF

  depends_on = [
    helm_release.istio_ingress,
    helm_release.istio_operator
  ]
}

resource "kubectl_manifest" "tg_binding" {
  count     = local.create_istio
  yaml_body = <<YAML
apiVersion: elbv2.k8s.aws/v1beta1
kind: TargetGroupBinding
metadata:
  name: istio-tgb-80-nlb
  namespace: istio-system
spec:
  serviceRef:
    name: istio-ingressgateway # route traffic to the awesome-service
    port: 80
  targetGroupARN: ${aws_lb_target_group.istio.arn}
  targetType: instance # Instance for EC2, IP for fargate
  networking:
    ingress:
    - from:
      - ipBlock:
          cidr: 0.0.0.0/0 # subnet-1 cidr
      ports:
      - protocol: TCP # Allow all TCP traffic from ALB SG
        port: 31381 # NodePort from Istio Ingress
YAML

  depends_on = [
    aws_lb.this,
    aws_lb_target_group.istio,
    helm_release.alb_ingress_controller,
    helm_release.istio_ingress
  ]

}
