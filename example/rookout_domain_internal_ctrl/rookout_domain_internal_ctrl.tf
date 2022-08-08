module "rookout" {
    source  = "../../"
    environment = var.environment
    # version = x.y.z
    
    domain_name = var.YOUR_DOMAIN
    rookout_token = var.YOUR_TOKEN

    internal_controller_alb = true

    deploy_demo_app = true

    vpc_cidr = "10.10.0.0/16"
    vpc_private_subnets = ["10.10.0.0/22", "10.10.4.0/22"]
    vpc_public_subnets = ["10.10.8.0/22", "10.10.12.0/22"]

}
