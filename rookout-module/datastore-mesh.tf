resource "aws_appmesh_mesh" "rookout" {
  name = "rookout-service-mesh"

  spec {
    egress_filter {
      type = "ALLOW_ALL"
    }
  }
}

resource "aws_appmesh_virtual_node" "datastore" {
  name      = "rookout-datastore"
  mesh_name = aws_appmesh_mesh.rookout.name

  spec {
    backend {
      virtual_service {
        virtual_service_name = "rookout-datastore.rookout-example.local"
      }
    }

    listener {
      port_mapping {
        port     = 8080
        protocol = "http"
      }

      health_check {
        protocol            = "http"
        path                = "/healthz"
        healthy_threshold   = 2
        unhealthy_threshold = 2
        timeout_millis      = 2000
        interval_millis     = 5000
      }
    }

    service_discovery {
      dns {
        hostname = "rookout-datastore.rookout-example.local"
      }
    }
  }
}

resource "aws_appmesh_virtual_service" "datastore" {
  name      = "rookout-datastore"
  mesh_name = aws_appmesh_mesh.rookout.name

  spec {
    provider {
      virtual_node {
        virtual_node_name = aws_appmesh_virtual_node.datastore.name
      }
    }
  }
}

resource "aws_appmesh_virtual_gateway" "rookout" {
  name      = "rookout-virtual-gateway"
  mesh_name = aws_appmesh_mesh.rookout.name

  spec {
    listener {
      port_mapping {
        port     = 8080
        protocol = "http"
      }

      # tls {
      #   certificate {
      #     acm {
      #       certificate_arn = module.mesh_self_signed_cert_root.certificate_arn
      #     }
      #   }

      #   mode = "STRICT"
      # }
    }

  }
}

resource "aws_appmesh_gateway_route" "route" {
  name                 = "rookout-datastore-gateway-route"
  virtual_gateway_name = aws_appmesh_virtual_gateway.rookout.name
  mesh_name            = aws_appmesh_mesh.rookout.name
  spec {
    http_route {
      action {
        target {
          virtual_service {
            virtual_service_name = aws_appmesh_virtual_service.datastore.name
          }
        }
      }

      match {
        prefix = "/"
      }
    }
  }
}

################ Mesh internal Certificate ####################
resource "aws_acmpca_certificate_authority" "mesh" {
  type = "ROOT"

  certificate_authority_configuration {
    key_algorithm     = "RSA_2048"
    signing_algorithm = "SHA256WITHRSA"

    subject {
      common_name = "rookout-datastore.rookout-example.local"
    }
  }

  permanent_deletion_time_in_days = 7
}

resource "aws_acmpca_certificate" "mesh" {
  certificate_authority_arn   = aws_acmpca_certificate_authority.mesh.arn
  certificate_signing_request = aws_acmpca_certificate_authority.mesh.certificate_signing_request
  signing_algorithm           = "SHA256WITHRSA"
  
  validity {
    type  = "YEARS"
    value = 10
  }
}

resource "aws_acmpca_certificate_authority_certificate" "mesh" {
  certificate_authority_arn = aws_acmpca_certificate_authority.mesh.arn

  certificate       = aws_acmpca_certificate.mesh.certificate
  certificate_chain = aws_acmpca_certificate.mesh.certificate_chain
}

resource "tls_private_key" "key" {
  algorithm = "RSA"
}

resource "tls_cert_request" "csr" {
  key_algorithm   = "RSA"
  private_key_pem = tls_private_key.key.private_key_pem

  subject {
    common_name = "rookout-datastore.rookout-example.local"
  }
}