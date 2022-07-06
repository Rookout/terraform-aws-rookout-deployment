## Deploy Rookout Agent on AWS ECS Fargate Cluster using Terraform
Compatible with Terraform version: `>= v0.13`

This terraform module is to be used to deploy the Rookout Controller and Rookout Datastore on AWS ECS Fargate cluster.
The module implements the following architecture:
<img src="https://github.com/Rookout/deployment-examples/blob/main//CICD.png" width="852" height="361">

### Prerequisites
1. terraform installed
2. AWS account 
3. AWS CLI installed.
4. The AWS default profile should be set with an access key and secret ([reference](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-quickstart.html)).
    * Set profile if used non default profile. Run: `export AWS_PROFILE="<profile_name>"`
5. Create a secret in the secrets manager with your Rookout token using one of the following options:
    * AWS CLI - Change the <rookout_token> placeholder with your token and run:
       * `aws secretsmanager create-secret --name rookout_token --description "Rookout token" --secret-string "<rookout_token>"`
    * AWS Console - follow this [tutorial](https://docs.aws.amazon.com/secretsmanager/latest/userguide/tutorials_basic.html)
    * Use secret's ARN of token for `rookout_token_arn` variable in `terraform.tfvars`. (See [Module Inputs](#module-inputs))
2. [Optional] - remote state bucket and dyanmoDB lock. can be created with attached tf-bucked module.

## Moduler deployment
This module can be used to deploy ECS Fargate cluster inside your's existing VPC. 








## Level of deployment
1. Full demo deploymeny - VPC + Subnets + LB + NAT + IGW + ECS cluster + services (remote/local datastore) (on/off demo application)
2. ECS clstuer + service + demo applicatino (remote/local datastore) (on/off demo application)