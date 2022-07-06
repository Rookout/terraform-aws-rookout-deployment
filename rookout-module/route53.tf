# module "acm" {
#   source  = "terraform-aws-modules/acm/aws"
#   version = "~> 3.0"

#   domain_name  = "rookout-example.com"
#   zone_id      = lookup(module.zones.route53_zone_zone_id,"rookout-example.com",null)

#   subject_alternative_names = [
#     "*.rookout-example.com",
#   ]

#   wait_for_validation = true

#   tags = {
#     Name = "rookout-example.com"
#   }
# }

# module "zones" {
#   source  = "terraform-aws-modules/route53/aws//modules/zones"
#   version = "~> 2.0"

#   zones = {
#     "rookout-example.com" = {
#       # in case than private and public zones with the same domain name
#       domain_name = "rookout-example.com"
#       comment     = "rookout-example.com"
#       vpc = [
#         {
#           vpc_id = module.vpc[0].vpc_id
#         },
#       ]
#       tags = {
#         Name = "rookout-example.com"
#       }
#     }
#   }

#   tags = {
#     ManagedBy = "Terraform"
#   }
# }
