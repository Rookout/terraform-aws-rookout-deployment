## Deploy Rookout Agent on AWS ECS Fargate Cluster using Terraform
Compatible with Terraform version: `>= v0.13`

This terraform depolying Rookout Controller and Rookout Datastore on AWS ECS Fargate cluster.
The module implements the following architecture:
<img src="https://github.com/Rookout/aws-deployment/blob/RK-12867-quick-deploy-aws-terraform/documentation/AWS_Deployment.jpg" width="852" height="361">

### Prerequisites
1. terraform installed
2. AWS account inlcuding: AWS CLI installed.
    * The AWS default profile should be set with an access key and secret ([reference](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-quickstart.html)).
    * Set profile if used non default profile. Run: `export AWS_PROFILE="<profile_name>"`
3. [Optional] - remote state bucket and dyanmoDB lock. can be created with attached tf-bucked module.
4. Create a secret in the secrets manager with your Rookout token using one of the following options:
    * AWS CLI - Change the <rookout_token> placeholder with your token and run:
       * `aws secretsmanager create-secret --name rookout-token --description "Rookout token" --secret-string "<rookout_token>"`
    * AWS Console - follow this [tutorial](https://docs.aws.amazon.com/secretsmanager/latest/userguide/tutorials_basic.html)
    * If secret stored with other name name, please pass it's name with `rookout_token_arn` variable insted. 

## Level of rookout deployment
1. Controller only
2. Conroller + Datastore
3. Controller + Datastore + Demo application (default)

## Level of infrastcture deployment
1. provided Domain (default)
2. provided Domain + VPC and subnets
3. provided Domain + VPC and subnets + ECS cluster
