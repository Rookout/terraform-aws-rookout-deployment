module "rookout" {
    source  = "Rookout/rookout-deployment/aws"    
    # version = x.y.z
    
    domain_name = "YOUR_DOMAIN"
    rookout_token = "YOUR_TOKEN"
}

output "rookout" {
    value = module.rookout
}