resource "aws_eks_cluster" "eks" {
  name     = "${var.cluster_name}"
  role_arn  = aws_iam_role.eks-role.arn
  version   = "1.30"  # Change to your desired version

  vpc_config {
    subnet_ids = [aws_subnet.subnet_a.id, aws_subnet.subnet_b.id]
  }

  tags = {
    Name = "${var.cluster_name}"
  }
  depends_on = [
    aws_iam_role_policy_attachment.eks_policy_attachment,
    aws_iam_role_policy_attachment.eks_vpc_policy_attachment,
  ]
}


resource "aws_eks_node_group" "this" {


  cluster_name    = aws_eks_cluster.eks.name
  node_group_name = "my-node-group"
  node_role_arn   = aws_iam_role.nodegroup.arn
  subnet_ids      = [aws_subnet.subnet_a.id, aws_subnet.subnet_b.id]
  scaling_config {
    desired_size = 1
    max_size     = 2
    min_size     = 1
  }
  instance_types = ["t3.medium"]  # Change to your desired instance types

  tags = {
    Name = "my-node-group"
  }
  update_config {
    max_unavailable = 1
  }

  # Ensure that IAM Role permissions are created before and deleted after EKS Node Group handling.
  # Otherwise, EKS will not be able to properly delete EC2 Instances and Elastic Network Interfaces.
  depends_on = [
    aws_iam_role_policy_attachment.example-AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.example-AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.example-AmazonEC2ContainerRegistryReadOnly,
  ]
}

data "kubernetes_service" "ingress_nginx" {
  metadata {
    name      = "ingress-nginx-controller"
    namespace = helm_release.nginx_ingress.metadata[0].namespace
  }
}

data "aws_lb" "ingress_nginx" {
  name = regex(
    "(^[^-]+)",
    data.kubernetes_service.ingress_nginx.status[0].load_balancer[0].ingress[0].hostname
  )[0]
}

resource "aws_route53_record" "nginx_ingress" {
  count   = 3
  zone_id = "Z06327881J9KE44VNFZO7"
  name    = count.index == 0 ? "bakarthikkumar.com" : count.index == 1 ? "www.bakarthikkumar.com" : "dotnet-app.bakarthikkumar.com"
  type    = "A"

  alias {
    name                   = data.kubernetes_service.ingress_nginx.status[0].load_balancer[0].ingress[0].hostname
    zone_id                = data.aws_lb.ingress_nginx.zone_id
    evaluate_target_health = true
  }
  depends_on = [
    helm_release.nginx_ingress,
    aws_eks_node_group.this,
    aws_eks_cluster.eks,
    data.aws_lb.ingress_nginx,
  ]
}