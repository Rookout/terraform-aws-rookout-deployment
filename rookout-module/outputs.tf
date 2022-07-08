output "vpc" {
  value = var.create_vpc ? module.vpc : null
}
