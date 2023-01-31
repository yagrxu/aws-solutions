locals {
    loki_storage = <<EOT
loki:
  auth_enabled: false
  storage:
    bucketNames:
      chunks: ${var.cluster_name}-loki-yagr
      ruler: ${var.cluster_name}-loki-yagr
      admin: ${var.cluster_name}-loki-yagr
    type: s3
    s3:
      s3: ${var.cluster_name}-loki-yagr
      endpoint: s3.${var.region}.amazonaws.com
      region: ${var.region}
      secretAccessKey: ${data.external.env.result["secretAccessKey"]}
      accessKeyId: ${data.external.env.result["accessKeyId"]}
      s3ForcePathStyle: false
      insecure: false
EOT
}

data "external" "env" {
  program = ["sh", "${path.module}/env.sh"]
}

resource "aws_s3_bucket" "loki" {
  bucket = "${var.cluster_name}-loki-yagr"
  force_destroy = true
}

resource "helm_release" "loki" {
  name       = "loki"

  repository = "https://grafana.github.io/helm-charts"
  chart      = "loki"

  values = [local.loki_storage]
}

resource "helm_release" "fluentbit" {
  name       = "fluentbit"

  repository = "https://grafana.github.io/helm-charts"
  chart      = "fluent-bit"

  set {
    name = "loki.serviceName"
    value = "loki-write.default.svc.cluster.local"
  }
}

resource "kubernetes_ingress_v1" "loki_read_ingress" {
  metadata {
    name      = "loki-read-ingress"
    namespace = "default"

    annotations = {
      "alb.ingress.kubernetes.io/scheme" = "internal"

      "alb.ingress.kubernetes.io/target-type" = "ip"
    }
  }

  spec {
    ingress_class_name = "alb"

    rule {
      http {
        path {
          path      = "/"
          path_type = "Prefix"

          backend {
            service {
              name = "loki-read"

              port {
                number = 3100
              }
            }
          }
        }
      }
    }
  }
}

