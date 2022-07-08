
resource "aws_ssm_parameter" "kms_key_arn" {
  name        = "/rookout/kms_key_arn"
  description = "KMS key used for state bucket"
  type        = "String"
  value       = module.remote_state.kms_key.arn
  overwrite = true
  tags = {
    environment = "rookout"
  }
}

resource "aws_ssm_parameter" "state_bucket_name" {
  name        = "/rookout/state_bucket_name"
  description = "Main state bucket name"
  type        = "String"
  value       = module.remote_state.state_bucket.bucket
  overwrite = true
  tags = {
    environment = "rookout"
  }
}

resource "aws_ssm_parameter" "state_bucket_arn" {
  name        = "/rookout/state_bucket_arn"
  description = "Main state bucket arn"
  type        = "String"
  value       = module.remote_state.state_bucket.arn
  overwrite = true
  tags = {
    environment = "rookout"
  }
}


resource "aws_ssm_parameter" "dynamo_lock_table_id" {
  name        = "/rookout/dynamo_lock_table_id"
  description = "DyanmoDB lock table id"
  type        = "String"
  value       = module.remote_state.dynamodb_table.id
  overwrite = true
  tags = {
    environment = "rookout"
  }
}