module "rookout" {
    source = "./rookout-module"
    
    environment = "demo"
    region = "eu-west-1"
    domain_name = "YOUR_DOMAIN.com"

    deploy_datastore = true
    deploy_demo_app = true

    create_cluster = true
    cluster_name = ""
    
    rookout_token_arn = ""
    secret_key = "rookout-token"

    create_vpc = false
    vpc_id = "<your's vpc id>"
    vpc_public_subnets = ["<first_sub_domain>", "<second_sub_domain>"]
    vpc_private_subnets = ["<first_sub_domain>", "<second_sub_domain>"]
}