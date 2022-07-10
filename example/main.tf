module "rookout_vanilla" {
    source = "./rookout-module"
    
    environment = "demo"
    region = "eu-west-1"
    domain_name = "rookout-example.com"

    deploy_datastore = true
    deploy_demo_app = true

    create_cluster = true
    cluster_name = ""
    
    rookout_token_arn = ""
    secret_key = "rookout-token"

    create_vpc = true
    vpc_id = ""
    vpc_public_subnets = ["10.0.0.64/27", "10.0.0.128/27"]
}

module "rookout_existing_vpc" {
    source = "./rookout-module"
    
    environment = "demo"
    region = "eu-west-1"
    domain_name = "rookout-example.com"

    deploy_datastore = true
    deploy_demo_app = true

    create_cluster = true
    cluster_name = ""
    
    rookout_token_arn = ""
    secret_key = "rookout-token"

    create_vpc = false
    vpc_id = "<your's vpc id>"
    vpc_public_subnets = ["10.0.0.64/27", "10.0.0.128/27"]
    vpc_private_subnets = ["10.0.0.0/27", "10.0.0.32/27"]
}

module "rookout_existing_vpc_and_cluster" {
    source = "./rookout-module"
    
    environment = "demo"
    region = "eu-west-1"
    domain_name = "rookout-example.com"

    deploy_datastore = true
    deploy_demo_app = true

    create_cluster = false
    cluster_name = "<your's existing cluster name>"
    
    rookout_token_arn = ""
    secret_key = "rookout-token"

    create_vpc = false
    vpc_id = "<your's vpc id>"
    vpc_public_subnets = ["10.0.0.64/27", "10.0.0.128/27"]
    vpc_private_subnets = ["10.0.0.0/27", "10.0.0.32/27"]
}