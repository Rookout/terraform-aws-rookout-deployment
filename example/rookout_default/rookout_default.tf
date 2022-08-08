module "rookout" {
    source  = "../../"
    environment = var.environment
    # version = x.y.z
    
    domain_name = var.YOUR_DOMAIN
    rookout_token = var.YOUR_TOKEN
}
