data "aws_route53_zone" "selected" {
  name         = var.domain_name
  private_zone = false
}

resource "aws_route53_zone" "sub_domain" {
  name    = "rookout.${var.domain_name}"
  comment = "rookout.${var.domain_name}"
}

resource "aws_route53_record" "rookout" {
  allow_overwrite = true
  zone_id         = data.aws_route53_zone.selected.zone_id
  name            = "rookout.${data.aws_route53_zone.selected.name}"
  type            = "NS"
  ttl             = "172800"
  records         = aws_route53_zone.sub_domain.name_servers
}

module "acm" {
  source  = "terraform-aws-modules/acm/aws"
  version = "~> 3.0"

  domain_name = "rookout.${var.domain_name}"
  zone_id     = aws_route53_zone.sub_domain.zone_id

  subject_alternative_names = [
    "datastore.rookout.${var.domain_name}",
    "controller.rookout.${var.domain_name}",
    "demo.rookout.${var.domain_name}",
  ]

  wait_for_validation = true
  tags                = local.tags
}

resource "aws_route53_record" "controller" {
  zone_id = aws_route53_zone.sub_domain.id
  name    = "controller.rookout.${var.domain_name}"
  type    = "A"

  alias {
    name                   = aws_alb.controller.dns_name
    zone_id                = aws_alb.controller.zone_id
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "datastore" {
  zone_id = aws_route53_zone.sub_domain.id
  name    = "datastore.rookout.${var.domain_name}"
  type    = "A"

  alias {
    name                   = aws_alb.datastore.dns_name
    zone_id                = aws_alb.datastore.zone_id
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "demo" {
  count   = var.deploy_demo ? 1 : 0
  zone_id = aws_route53_zone.sub_domain.id
  name    = "demo.rookout.${var.domain_name}"
  type    = "A"

  alias {
    name                   = aws_alb.demo[0].dns_name
    zone_id                = aws_alb.demo[0].zone_id
    evaluate_target_health = true
  }
}
