data "aws_route53_zone" "selected" {
  count        = var.deploy_alb && var.datastore_acm_certificate_arn == "" ? 1 : 0
  name         = var.domain_name
  private_zone = false
}

resource "aws_route53_zone" "sub_domain" {
  count   = var.deploy_alb && var.datastore_acm_certificate_arn == "" ? 1 : 0
  name    = "rookout.${var.domain_name}"
  comment = "rookout.${var.domain_name}"

  dynamic "vpc" {
    for_each = var.internal ? [1] : []
    content {
      vpc_id = var.create_vpc ? module.vpc[0].vpc_id : var.vpc_id
    }
  }
}

resource "aws_route53_record" "rookout" {
  count           = var.deploy_alb && var.datastore_acm_certificate_arn == "" ? 1 : 0
  allow_overwrite = true
  zone_id         = data.aws_route53_zone.selected[0].zone_id
  name            = "rookout.${data.aws_route53_zone.selected[0].name}"
  type            = "NS"
  ttl             = "172800"
  records         = aws_route53_zone.sub_domain[0].name_servers
}

module "acm" {
  count   = var.deploy_alb && var.datastore_acm_certificate_arn == "" && var.wildcard_certificate_arn == "" ? 1 : 0
  source  = "terraform-aws-modules/acm/aws"
  version = "~> 3.0"

  domain_name = "rookout.${var.domain_name}"
  zone_id     = aws_route53_zone.sub_domain[0].zone_id

  subject_alternative_names = [
    "datastore.rookout.${var.domain_name}",
    "controller.rookout.${var.domain_name}",
    "demo.rookout.${var.domain_name}",
  ]

  wait_for_validation = true
  tags                = local.tags
}

resource "aws_route53_record" "controller" {
  count = var.deploy_alb && var.datastore_acm_certificate_arn == "" && !var.internal_controller_alb ? 1 : 0

  zone_id = aws_route53_zone.sub_domain[0].id
  name    = "controller.rookout.${var.domain_name}"
  type    = "A"

  alias {
    name                   = aws_alb.controller[0].dns_name
    zone_id                = aws_alb.controller[0].zone_id
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "datastore" {
  count = var.deploy_datastore && var.deploy_alb && var.datastore_acm_certificate_arn == "" ? 1 : 0

  zone_id = aws_route53_zone.sub_domain[0].id
  name    = "datastore.rookout.${var.domain_name}"
  type    = "A"

  alias {
    name                   = aws_alb.datastore[0].dns_name
    zone_id                = aws_alb.datastore[0].zone_id
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "demo" {
  count   = var.deploy_demo_app && var.deploy_alb && var.datastore_acm_certificate_arn == "" ? 1 : 0
  zone_id = aws_route53_zone.sub_domain[0].id
  name    = "demo.rookout.${var.domain_name}"
  type    = "A"

  alias {
    name                   = aws_alb.demo[0].dns_name
    zone_id                = aws_alb.demo[0].zone_id
    evaluate_target_health = true
  }
}
