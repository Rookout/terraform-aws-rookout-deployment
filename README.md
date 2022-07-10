## Deploy Rookout on AWS ECS Fargate Cluster using Terraform

This terraform depolying Rookout Controller and Rookout Datastore on AWS ECS Fargate cluster.
The module implements the following architecture:

<img src="https://github.com/Rookout/aws-deployment/blob/main/documentation/AWS_Deployment.jpg" width="791" height="416">

Network architecture:

<img src="https://github.com/Rookout/aws-deployment/blob/main/documentation/AWS_Deployment_Network.jpg" width="791" height="325">

### Prerequisites
1. terraform installed
2. AWS account inlcuding: AWS CLI installed.
    * The AWS default profile should be set with an access key and secret ([reference](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-quickstart.html)).
    * Set profile if used non default profile. Run: `export AWS_PROFILE="<profile_name>"`
3. [Optional] - remote state bucket and dyanmoDB lock. can be created with attached tf-backend module.
4. Create a secret in the secrets manager with your Rookout token using one of the following options:
    * AWS CLI - Change the <rookout_token> placeholder with your token and run:
       * `aws secretsmanager create-secret --name rookout-token --description "Rookout token" --secret-string "{\"rookout-token\":\"<rookout_token>\"}"`
    * AWS Console - follow this [tutorial](https://docs.aws.amazon.com/secretsmanager/latest/userguide/tutorials_basic.html)
    * If secret stored with other name name, please configure `rookout_token_arn` variable insted. 

## Level of rookout deployment
1. Controller only
2. Controller + Datastore
3. Controller + Datastore + Demo application (default)

## Level of infrastructure deployment
1. provided Domain (default) ([example](https://github.com/Rookout/aws-deployment/blob/main/example/rookout_default.tf))
```
    Vanilla deployment, reconfigure the folowing variables to avoid CIDRs conflict:
    environment = "ENV_NAME"
    region = "YOUR_REGION"
    domain_name = "YOUR_DOMAIN"

    vpc_public_subnets = ["<first_sub_domain>", "<second_sub_domain>"]
    vpc_private_subnets = ["<first_sub_domain>", "<second_sub_domain>"]

```
2. provided Domain + VPC and subnets ([example](https://github.com/Rookout/aws-deployment/blob/main/example/rookout_existing_vpc.tf))
```
    Configure the following variables:
    environment = "ENV_NAME"
    region = "YOUR_REGION"
    domain_name = "YOUR_DOMAIN"

    create_cluster = false
    vpc_id = "<your's existing vpc id>"
    vpc_public_subnets = ["<first_sub_domain>", "<second_sub_domain>"]
    vpc_private_subnets = ["<first_sub_domain>", "<second_sub_domain>"]

```
3. provided Domain + VPC and subnets + ECS cluster ([example](https://github.com/Rookout/aws-deployment/blob/main/example/rookout_existing_vpc_and_cluster.tf))
```
    Configure the following variables: 
    environment = "ENV_NAME"
    region = "YOUR_REGION"
    domain_name = "YOUR_DOMAIN"

    create_cluster = false
    vpc_id = "<your's vpc id>"
    vpc_public_subnets = ["<first_sub_domain>", "<second_sub_domain>"]
    vpc_private_subnets = ["<first_sub_domain>", "<second_sub_domain>"]

    create_cluster = false
    cluster_name = "<your's existing cluster name>"
```

## DNS
To run this module, controller, datastore (optional) and demo application (optional) endpoint should be created. To accomplish that ALB will be deployed usign ACM and provided domain address. subdomain will be create in route53. if you don't use route53 as your's dns registry, please contect us for support.

## Main variables
For vanilla deployment, inject the secret that described in prerequisites, change dirctory to rookout-moudle, configure aws and awsutil providers, configure "domain_name" variable of your's DNS and run terraform apply.

Main radio buttons of this module are: 

create_vpc - Boolean variable, if true (default) will create VPC (using variables: vpc_cidr, vpc_avilability_zones, vpc_private_subnets, vpc_public_subnets). If false, provide vpc_id of your's.

create_cluster - Boolean variables, if true (default) will be create ECS cluster for service. If false, should be provided with cluster_name variable.

deploy_datastore - Boolean variables, if true (default) will deploy datastore and configure the enviorment variables need in controller. If false, Rookout will use remote datastore for the application.

deploy_demo_app_app - Boolean variable, if true (default) will deploy demo flask application in ECS cluster, injected with: Rookout's token that sotred in AWS Secret Manager, controller URL. Application avilable in demo.PROVIDE_DOMAIN endpoint. if false, will not deploy the application.


## Endpoints
controller.PROVIDED_DOMAIN - url of the controller, used for SDK (rooks) .

datastore.PROVIDED_DOMAIN - url to the datastore, used with rookout client (web browser application).

demo.PROVIDE_DOMAIN - flask demo application for debuging.  

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.14 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 4.0 |
| <a name="requirement_awsutils"></a> [awsutils](#requirement\_awsutils) | >= 0.11.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 4.21.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_acm"></a> [acm](#module\_acm) | terraform-aws-modules/acm/aws | ~> 3.0 |
| <a name="module_vpc"></a> [vpc](#module\_vpc) | terraform-aws-modules/vpc/aws | 3.14.2 |

## Resources

| Name | Type |
|------|------|
| [aws_alb.controller](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/alb) | resource |
| [aws_alb.datastore](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/alb) | resource |
| [aws_alb.demo](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/alb) | resource |
| [aws_cloudwatch_log_group.demo](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_cloudwatch_log_group.rookout](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_cloudwatch_log_stream.controller_log_stream](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_stream) | resource |
| [aws_cloudwatch_log_stream.datastore_log_stream](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_stream) | resource |
| [aws_cloudwatch_log_stream.demo_log_stream](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_stream) | resource |
| [aws_ecs_cluster.rookout](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_cluster) | resource |
| [aws_ecs_service.controller](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_service) | resource |
| [aws_ecs_service.datastore](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_service) | resource |
| [aws_ecs_service.demo](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_service) | resource |
| [aws_ecs_task_definition.controller](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_task_definition) | resource |
| [aws_ecs_task_definition.datastore](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_task_definition) | resource |
| [aws_ecs_task_definition.demo](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_task_definition) | resource |
| [aws_iam_policy.secret_manager_read](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_role.task_exec_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_lb_listener.controller](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener) | resource |
| [aws_lb_listener.datastore](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener) | resource |
| [aws_lb_listener.demo](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener) | resource |
| [aws_lb_target_group.controller](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_target_group) | resource |
| [aws_lb_target_group.datastore](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_target_group) | resource |
| [aws_lb_target_group.demo](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_target_group) | resource |
| [aws_route53_record.controller](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) | resource |
| [aws_route53_record.datastore](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) | resource |
| [aws_route53_record.demo](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) | resource |
| [aws_route53_record.rookout](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) | resource |
| [aws_route53_zone.sub_domain](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_zone) | resource |
| [aws_security_group.alb_controller](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group.alb_datastore](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group.alb_demo](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group.allow_demo](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group.controller](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group.datastore](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_ecs_cluster.provided](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ecs_cluster) | data source |
| [aws_route53_zone.selected](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/route53_zone) | data source |
| [aws_secretsmanager_secret.rookout_token](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/secretsmanager_secret) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | ECS cluster name, if we want to deploy to existing one | `string` | `""` | no |
| <a name="input_create_cluster"></a> [create\_cluster](#input\_create\_cluster) | whether create a cluster or use existing one | `bool` | `true` | no |
| <a name="input_create_vpc"></a> [create\_vpc](#input\_create\_vpc) | # VPC variables. | `bool` | `true` | no |
| <a name="input_deploy_datastore"></a> [deploy\_datastore](#input\_deploy\_datastore) | (Optional) If true will deploy demo Rookout's datastore locally | `bool` | `true` | no |
| <a name="input_deploy_demo_app"></a> [deploy\_demo\_app](#input\_deploy\_demo\_app) | (Optional) If true will deploy demo flask application to start debuging | `bool` | `true` | no |
| <a name="input_domain_name"></a> [domain\_name](#input\_domain\_name) | DNS domain which sub | `string` | `""` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | Environment name | `string` | `"demo"` | no |
| <a name="input_region"></a> [region](#input\_region) | Aws region | `string` | `"eu-west-1"` | no |
| <a name="input_rookout_token_arn"></a> [rookout\_token\_arn](#input\_rookout\_token\_arn) | Manual injecting arn of rookout secret from secret manager | `string` | `""` | no |
| <a name="input_secret_key"></a> [secret\_key](#input\_secret\_key) | Key of secret in secret manager | `string` | `"rookout-token"` | no |
| <a name="input_vpc_avilability_zones"></a> [vpc\_avilability\_zones](#input\_vpc\_avilability\_zones) | n/a | `list(string)` | <pre>[<br>  "eu-west-1a",<br>  "eu-west-1b"<br>]</pre> | no |
| <a name="input_vpc_cidr"></a> [vpc\_cidr](#input\_vpc\_cidr) | n/a | `string` | `"10.0.0.0/16"` | no |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | VPC id should be passed only if create\_vpc = false | `string` | `""` | no |
| <a name="input_vpc_private_subnets"></a> [vpc\_private\_subnets](#input\_vpc\_private\_subnets) | n/a | `list(string)` | <pre>[<br>  "10.0.0.0/27",<br>  "10.0.0.32/27"<br>]</pre> | no |
| <a name="input_vpc_public_subnets"></a> [vpc\_public\_subnets](#input\_vpc\_public\_subnets) | n/a | `list(string)` | <pre>[<br>  "10.0.0.64/27",<br>  "10.0.0.128/27"<br>]</pre> | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_controller_endpoint"></a> [controller\_endpoint](#output\_controller\_endpoint) | Rookout's on-prem controller endpoint |
| <a name="output_datastore_endpoint"></a> [datastore\_endpoint](#output\_datastore\_endpoint) | Rookout's on-prem datastore endpoint |
| <a name="output_demo_endpoint"></a> [demo\_endpoint](#output\_demo\_endpoint) | Rookout's flask application endpoint |
| <a name="output_ecs_cluster_id"></a> [ecs\_cluster\_id](#output\_ecs\_cluster\_id) | ECS cluster |
| <a name="output_vpc_id"></a> [vpc\_id](#output\_vpc\_id) | VPC id that created |
<!-- END_TF_DOCS -->