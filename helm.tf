resource "helm_release" "nginx_ingress" {
  namespace = "ingress-nginx"
  wait      = true
  timeout   = 600

  name = "ingress-nginx"
  create_namespace = true


  repository = "https://kubernetes.github.io/ingress-nginx"
  chart      = "ingress-nginx"
  version    = "v4.11.2"
  values = [
    <<-EOF
    controller:
      service:
        annotations:
          service.beta.kubernetes.io/aws-load-balancer-type: nlb
    EOF
  ]
}