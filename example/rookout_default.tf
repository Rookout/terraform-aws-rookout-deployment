module "rookout" {
    source = "rookout/aws-deployment"
    # version = x.y.z
    
    domain_name = "YOUR_ROUTE53_DOMAIN"
    rookout_token = "YOUR_TOKEN"
}
