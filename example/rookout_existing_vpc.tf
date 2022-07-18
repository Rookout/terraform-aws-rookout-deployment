module "rookout" {
    source = "rookout/aws-deployment"
    # version = x.y.z
    
    environment = "rookout"
    region = "YOUR REGION" # will use provider region if not provided
    domain_name = "YOUR_DOMAIN.com"

    deploy_datastore = true
    deploy_demo_app = false

    create_cluster = true
    cluster_name = ""
    
    rookout_token = "YOUR TOKEN"

    create_vpc = false
    vpc_id = "<your's vpc id>"
    vpc_public_subnets = ["<first_sub_domain>", "<second_sub_domain>"]
    vpc_private_subnets = ["<first_sub_domain>", "<second_sub_domain>"]
}