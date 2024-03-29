module "rookout" {
    source  = "Rookout/rookout-deployment/aws"
    # version = x.y.z
    
    environment = "rookout"
    region = "YOUR REGION" # will use provider region if not provided
    domain_name = "YOUR_DOMAIN"

    deploy_datastore = true
    deploy_demo_app = false

    create_cluster = true
    
    rookout_token = "YOUR TOKEN"

    create_vpc = false
    vpc_id = "<your vpc id>"
    vpc_public_subnets = ["<first_sub_domain>", "<second_sub_domain>"]
    vpc_private_subnets = ["<first_sub_domain>", "<second_sub_domain>"]
}

output "rookout" {
    value = module.rookout
}