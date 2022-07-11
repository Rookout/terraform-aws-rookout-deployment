module "rookout" {
    source = "./rookout-module"
    
    environment = "demo"
    region = "eu-west-1"
    domain_name = "YOUR_DOMAIN.com"

    deploy_datastore = true
    deploy_demo_app = false

    create_cluster = false
    cluster_name = "<your's existing cluster name>"
    
    rookout_token_arn = ""

    create_vpc = false
    vpc_id = "<your's vpc id>"
    vpc_public_subnets = ["<first_sub_domain>", "<second_sub_domain>"]
    vpc_private_subnets = ["<first_sub_domain>", "<second_sub_domain>"]
}