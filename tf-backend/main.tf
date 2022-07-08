provider "aws" {
  region = "eu-west-1"
}

provider "aws" {
  alias  = "replica"
  region = "eu-west-2"
}

## https://github.com/nozaq/terraform-aws-remote-state-s3-backend
module "remote_state" {
  source = "nozaq/remote-state-s3-backend/aws"
  enable_replication = false
  
  providers = {
    aws         = aws
    aws.replica = aws.replica
  }
}
