module "vpc" {
    count = var.create_vpc ? 1 : 0
    source = "terraform-aws-modules/vpc/aws"
    version = "3.14.2"

    name = "${var.environment}-rookout-vpc"
    cidr = var.vpc_cidr

    azs             = var.vpc_avilability_zones
    private_subnets = var.vpc_private_subnets
    public_subnets  = var.vpc_public_subnets

    enable_nat_gateway = true
    single_nat_gateway = true
    one_nat_gateway_per_az = false

    enable_vpn_gateway = true
    enable_dns_hostnames = true
    enable_dns_support   = true

    tags = {
     Terraform   = "true"
     Environment = var.environment
     Service     = "rookout"
   }
 }


module "ec2_client_vpn" {
  count = var.create_vpc ? 1 : 0
  source  = "cloudposse/ec2-client-vpn/aws"
  version = "0.12.2"
  
  vpc_id = module.vpc[0].vpc_id
  client_cidr             = var.client_cidr
  organization_name       = "Rookout"
  logging_enabled         = false
  associated_subnets      = module.vpc[0].private_subnets
  retention_in_days       = 0
  logging_stream_name     = "rookout"
  
  ca_common_name     = "vpn.internal.rookout-example.local"
  root_common_name   = "vpn-client.internal.rookout-example.local"
  server_common_name = "vpn-server.internal.rookout-example.local"

  export_client_certificate = true
  split_tunnel = true
  authorization_rules = [
    {
      authorize_all_groups = true
      description = "all access"
      target_network_cidr = var.vpc_cidr
    }
  ]
  dns_servers = [tolist(aws_route53_resolver_endpoint.rookout.ip_address)[0].ip,"8.8.8.8"]
  additional_routes = [
    # {
    #   destination_cidr_block = "0.0.0.0/0"
    #   description            = "Internet Route"
    #   target_vpc_subnet_id   = element(module.vpc[0].private_subnets, 0)
    # }
  ]

}

data "aws_ssm_parameter" "ca_key" {
  count = var.create_vpc ? 1 : 0
  name = "self-signed-cert-ca.key"
  with_decryption = true
  depends_on = [ module.ec2_client_vpn ]
}

data "aws_ssm_parameter" "ca_cert" {
  count = var.create_vpc ? 1 : 0
  name = "self-signed-cert-ca.pem"
  with_decryption = true
  depends_on = [ module.ec2_client_vpn ]
}

resource "local_file" "private_key" {
  count = var.create_vpc ? 1 : 0
  content  = join("\n",[module.ec2_client_vpn[0].client_configuration,"<key>",data.aws_ssm_parameter.ca_key[0].value,"</key>","<cert>",data.aws_ssm_parameter.ca_cert[0].value,"</cert>"])
  filename = "client_configuration.ovpn"
  depends_on = [ module.ec2_client_vpn ]
}

