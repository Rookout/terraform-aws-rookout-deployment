# resource "tls_private_key" "default" {
# #   count = local.create_private_key ? 1 : 0
#   algorithm = "RSA"
#   rsa_bits  = 2048
# }

# resource "tls_self_signed_cert" "default" {
# #   count = local.enabled && ! var.use_locally_signed ? 1 : 0

#   is_ca_certificate = false

#   private_key_pem = coalesce(join("", tls_private_key.default.*.private_key_pem))

#   validity_period_hours = 87600
#   early_renewal_hours   = null

#   allowed_uses = [
#     "key_encipherment",
#     "digital_signature",
#     "server_auth",
#     "client_auth",
#   ]

#   subject {
#     common_name         = "rookout-example"
#     organization        = "rookout"
#     organizational_unit = "Terraform"
#   }

#   set_subject_key_id = false
# }

# resource "aws_acm_certificate" "default" {
# #   count             = local.acm_enabled ? 1 : 0
#   private_key       = tls_private_key.default.private_key_pem
#   certificate_body  = tls_self_signed_cert.default.cert_pem
#   certificate_chain = null
# }