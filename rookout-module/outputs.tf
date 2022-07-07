output "vpc_id" {
    value = var.create_vpc ? module.vpc : null
}
