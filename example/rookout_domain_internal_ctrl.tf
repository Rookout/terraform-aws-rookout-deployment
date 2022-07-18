module "rookout" {
    source = "rookout/aws-deployment"

    domain_name = "YOUR_ROUTE53_DOMAIN"
    rookout_token = "YOUR_TOKEN"
    internal_controller_alb = true
}
