module "rookout" {
    source = "./rookout-module"
    
    environment = "demo"
    region = "eu-west-1"
    domain_name = "YOUR_DOMAIN.com"

    deploy_datastore = true
    deploy_demo_app = false

    create_cluster = true
    cluster_name = ""
    
    rookout_token = "YOUR ROOKOUT TOKEN"
    secret_key = "rookout-token"

    create_vpc = true
    vpc_id = ""
    vpc_cidr = "10.0.0.0/27"
    vpc_public_subnets = ["10.0.0.64/27", "10.0.0.128/27"]
    vpc_private_subnets = ["10.0.0.0/27", "10.0.0.32/27"]
}
