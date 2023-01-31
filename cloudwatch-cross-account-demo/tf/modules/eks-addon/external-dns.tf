locals {
  role_name = "${var.cluster_name}-external-dns"
}

resource "kubernetes_namespace" "external-dns" {
  metadata {
    name = "external-dns"
  }
}

module "iam_assumable_role_external_dns" {
  source                        = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version                       = "5.9.0"
  create_role                   = true
  role_name                     = local.role_name
  # force_detach_policies         = true
  provider_url                  = var.cluster_oidc_issuer_url
  oidc_fully_qualified_subjects = ["system:serviceaccount:external-dns:external-dns"]
}

resource "kubernetes_service_account" "external_dns" {
  depends_on = [
    kubernetes_namespace.external-dns,
  ]
  metadata {
    name      = "external-dns"
    namespace = "external-dns"
    # labels = {
    #   "app.kubernetes.io/instance" = "adot-collector"
    #   "app.kubernetes.io/name" = "adot-collector"
    # }
    annotations = {
      "eks.amazonaws.com/role-arn" = module.iam_assumable_role_external_dns.iam_role_arn
    }
  }
}

resource "kubernetes_cluster_role" "external_dns" {
  metadata {
    name = "external-dns"
  }

  rule {
    verbs      = ["get", "watch", "list"]
    api_groups = [""]
    resources  = ["services"]
  }

  rule {
    verbs      = ["get", "watch", "list"]
    api_groups = [""]
    resources  = ["pods"]
  }

  rule {
    verbs      = ["get", "watch", "list"]
    api_groups = ["extensions", "networking.k8s.io"]
    resources  = ["ingresses"]
  }

  rule {
    verbs      = ["list", "watch"]
    api_groups = [""]
    resources  = ["nodes"]
  }

  rule {
    verbs      = ["get", "watch", "list"]
    api_groups = [""]
    resources  = ["endpoints"]
  }
}

resource "kubernetes_cluster_role_binding" "external_dns_viewer" {
  metadata {
    name = "external-dns-viewer"
  }

  subject {
    kind      = "ServiceAccount"
    name      = "external-dns"
    namespace = "external-dns"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "external-dns"
  }
}

resource "kubernetes_deployment" "external_dns" {
  depends_on = [
    kubernetes_namespace.external-dns,
    kubernetes_service_account.external_dns
  ]
  metadata {
    name = "external-dns"
    namespace = "external-dns"
  }

  spec {
    selector {
      match_labels = {
        app = "external-dns"
      }
    }

    template {
      metadata {
        labels = {
          app = "external-dns"
        }
      }

      spec {
        container {
          name  = "external-dns"
          image = "k8s.gcr.io/external-dns/external-dns:v0.11.0"
          args  = ["--source=service", "--source=ingress", "--provider=aws", "--policy=upsert-only", "--aws-zone-type=public", "--registry=txt", "--txt-owner-id=${var.owner_id}"]
        }
        service_account_name = "external-dns"
      }
    }

    strategy {
      type = "Recreate"
    }
  }
}

