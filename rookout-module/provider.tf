
provider "aws" {
  region = "eu-west-1"
}

provider "awsutils" {
  region = "eu-west-1"
}

#Should be removed !!!
terraform {
  backend "s3" {
    bucket         = "tf-remote-state20220627150551250100000002"
    key            = "rookout/terraform.tfstate"
    region         = "eu-west-1"
    encrypt        = true
    kms_key_id     = "arn:aws:kms:eu-west-1:032275105219:key/a7493436-0d7b-455b-91af-eaee07a312b8"
    dynamodb_table = "tf-remote-state-lock"
  }
}