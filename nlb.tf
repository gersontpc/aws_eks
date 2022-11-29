resource "aws_lb" "this" {
  name               = format("%s-nlb", var.cluster_name)
  internal           = true
  load_balancer_type = "network"
  subnets            = var.subnet_ids

  enable_deletion_protection       = false
  enable_cross_zone_load_balancing = true

  tags = {
    name = format("%s-nlb", var.cluster_name)
  }
}

resource "aws_lb_target_group" "istio" {
  name                   = format("%s-tg", var.cluster_name)
  port                   = 31381 # http node port on istio ingress (80 -> 31381)
  protocol               = "TCP"
  vpc_id                 = var.vpc_id
  target_type            = "instance" # Instance for EC2, IP for fargate
  deregistration_delay   = 5
  connection_termination = true

  health_check {
    path = "/healthz/ready"
    port = "31371" # status node port on istio ingress (80 -> 31371)
  }
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.this.arn
  port              = "80"
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.istio.arn
  }

}

resource "helm_release" "alb_ingress_controller" {
  name       = "aws-load-balancer-controller"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  namespace  = "kube-system"

  create_namespace = true

  set {
    name  = "clusterName"
    value = var.cluster_name
  }

  set {
    name  = "serviceAccount.create"
    value = false
  }

  set {
    name  = "serviceAccount.name"
    value = "aws-load-balancer-controller"
  }

  set {
    name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = aws_iam_role.alb_controller.arn
  }

  set {
    name  = "region"
    value = var.region
  }


  set {
    name  = "vpcId"
    value = var.vpc_id

  }

  # set {
  #   name  = "image.repository"
  #   value = "602401143452.dkr.ecr.sa-east-1.amazonaws.com/amazon/aws-load-balancer-controller"
  # }

  # set {
  #   name  = "image.tag"
  #   value = "v2.2.1"
  # }

  depends_on = [
    aws_eks_cluster.master,
    aws_eks_node_group.this,
    kubernetes_config_map.aws-auth
  ]
}
