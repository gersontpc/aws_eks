# https://istio.io/latest/docs/ops/deployment/requirements/

resource "helm_release" "istio_base" {
  count            = local.create_istio
  name             = "base"
  chart            = "base"
  repository       = "https://istio-release.storage.googleapis.com/charts"
  version          = "1.14.0"
  namespace        = "istio-system"
  create_namespace = true

  depends_on = [
    aws_eks_cluster.master,
    aws_eks_node_group.this
  ]
}

resource "helm_release" "istio_discovery" {
  count      = local.create_istio
  name       = "istiod"
  chart      = "istiod"
  repository = "https://istio-release.storage.googleapis.com/charts"
  version    = "1.14.0"
  namespace  = "istio-system"

  depends_on = [
    helm_release.istio_base
  ]
}

resource "helm_release" "istio_operator" {
  count      = local.create_istio
  name       = "operator"
  chart      = "operator"
  repository = "https://istio-release.storage.googleapis.com/charts"
  version    = "1.14.0"
  namespace  = "istio-system"

  depends_on = [
    helm_release.istio_base
  ]
}

resource "helm_release" "istio_ingress" {
  count      = local.create_istio
  name       = "istio-ingress"
  chart      = "istio-ingress"
  repository = "https://istio-release.storage.googleapis.com/charts"
  version    = "1.14.0"
  namespace  = "istio-system"

  set {
    name  = "gateways.istio-ingressgateway.autoscaleMin"
    value = 2
  }

  depends_on = [
    helm_release.istio_base
  ]
}

resource "helm_release" "istio_egress" {
  count      = local.create_istio
  name       = "istio-egress"
  chart      = "istio-egress"
  repository = "https://istio-release.storage.googleapis.com/charts"
  version    = "1.14.0"
  namespace  = "istio-system"

  set {
    name  = "gateways.istio-egressgateway.autoscaleMin"
    value = 2
  }

  depends_on = [
    helm_release.istio_base
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
    helm_release.alb_ingress_controller
  ]

}

