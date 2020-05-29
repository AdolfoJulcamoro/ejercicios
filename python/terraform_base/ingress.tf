module "nginx-ingress-controller" {
  source  = "byuoitav/nginx-ingress-controller/kubernetes"
  version = "0.1.5"
}

resource "kubernetes_ingress" "example_ingress" {
  metadata {
    name = "example-ingress"
  }

  spec {
    backend {
      service_name = var.service_name
      service_port = 80
    }

    rule {
      http {
        path {
          backend {
            service_name = var.service_name
            service_port = 80
          }

          path = "/"
        }
      }
    }
  }
}