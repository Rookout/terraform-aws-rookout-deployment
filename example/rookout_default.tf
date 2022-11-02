module "rookout" {
    source  = "Rookout/rookout-deployment/aws"    
    domain_name = "YOUR_DOMAIN"
    rookout_token = "YOUR_TOKEN"
}

output "rookout" {
    value = module.rookout
}