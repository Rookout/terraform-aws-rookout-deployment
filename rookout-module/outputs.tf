output "vpc_id" {
    value = var.create_vpc ? module.vpc : null
}

output "ec2_client_vpn" {
    value = var.create_vpc ? module.ec2_client_vpn[0].client_configuration : null
}


# output "self_signed_cert" {
#     value = module.self_signed_cert
# }
