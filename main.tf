provider "aws" {
  region = var.aws_region
}

data "aws_eks_cluster_auth" "ms-sssm" {
  name = var.kubernetes_cluster_id
}

provider "helm" {
  kubernetes {
    cluster_ca_certificate = base64decode(var.kubernetes_cluster_cert_data)
    host                   = var.kubernetes_cluster_endpoint
    token                  = data.aws_eks_cluster_auth.ms-sssm.token
  }
}

resource "helm_release" "traefik-ingress" {
  name       = "ms-traefik-ingress"
  chart      = "traefik"
  repository = "https://traefik.github.io/charts"
  values = [<<EOF
  service:
    annotations:
      service.beta.kubernetes.io/aws-load-balancer-type: nlb
      externalTrafficPolicy: Local
  EOF
  ]
}