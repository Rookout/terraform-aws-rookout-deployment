## Deploy Rookout on AWS ECS Fargate Cluster using Terraform

This terraform depolying Rookout Controller and Rookout Datastore on AWS ECS Fargate cluster.
The module implements the following architecture (default deployment):

<img src="https://github.com/Rookout/aws-deployment/blob/main/documentation/AWS_Deployment.jpg" width="900">

Network architecture (default deployment):

<img src="https://github.com/Rookout/aws-deployment/blob/main/documentation/AWS_Deployment_Plain_Network.jpg" width="900">

### Prerequisites 
1. terraform installed
2. AWS account inlcuding: AWS CLI installed.
    * The AWS default profile should be set with an access key and secret ([reference](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-quickstart.html)).
    * Set profile if used non default profile. Run: `export AWS_PROFILE="<profile_name>"`
3. [Optional] - remote state bucket and dyanmoDB lock. can be created with attached tf-backend module.
4. Get Rookout token, and pass it as variable to this module (rookout_token = "...")
## Level of rookout deployment
1. Controller only
2. Controller + Datastore (default)
3. Controller + Datastore + Demo application 
```
    This can be configured with the folloiwng boolean variables:
    deploy_datastore = true/false
    deploy_demo_app = true/false
```

## Level of infrastructure deployment

For your's convenience, there are two deployment matrixs:

<img src="https://github.com/Rookout/aws-deployment/blob/main/documentation/AWS_Deployment_Dep_Matrix_1.jpg" width="900">

<img src="https://github.com/Rookout/aws-deployment/blob/main/documentation/AWS_Deployment_Dep_Matrix_2.jpg" width="900">

1. provided Domain (default) ([example](https://github.com/Rookout/aws-deployment/blob/main/example/rookout_default.tf))
```
    domain_name = "YOUR_DOMAIN"
    rookout_token = "YOUR_TOKEN"
```
2. provided Domain with internal controller ([example](https://github.com/Rookout/aws-deployment/blob/main/example/rookout_domain_internal_ctrl.tf))
```
    domain_name = "YOUR_DOMAIN"
    rookout_token = "YOUR_TOKEN"
    internal_controller_alb = true
```
2. provided ACM certificate for datastore ([example](https://github.com/Rookout/aws-deployment/blob/main/example/rookout_certificate_datastore.tf))

This deployment will use pre-imported arn of certificate in ACM ( needed Body, private key and chain of certificate ).
certificate will be used by datastore, therefore CNAME record of certificate's domain should be recored at your's DNS provider with datstore endpoint (output of the module).
controller will be deployed with internal load balancer and can be reached from VPC with controller endpoint (output of the module). 
```
    datastore_acm_certificate_arn = "PRE_IMPORTED_ACM_CERTIFICATE_ARN"
    rookout_token = "YOUR_TOKEN"
```
3. provided ACM certificate for datastore and controller (for internet-facing controller) ([example](https://github.com/Rookout/aws-deployment/blob/main/example/rookout_certificate_datastore_controller.tf))

Same is second deployment but, the controller is internet facing too. same procedure of CNAME record registration should be preformed for datastore and controller endpoints that match to their certificate's domain.
```
    datastore_acm_certificate_arn = "PRE_IMPORTED_ACM_CERTIFICATE_ARN"
    controller_acm_certificate_arn = "PRE_IMPORTED_ACM_CERTIFICATE_ARN"
    rookout_token = "YOUR_TOKEN"

    to configure demo application to adress right address of controller configure with your's CNAME record:
    demo_app_controller_host = "YOUR_CONTROLLER_CNAME"
```
4. provided Domain + VPC and subnets ([example](https://github.com/Rookout/aws-deployment/blob/main/example/rookout_existing_vpc.tf))
```
    Configure the following variables:
    domain_name = "YOUR_DOMAIN"
    rookout_token = "YOUR_TOKEN

    create_cluster = false
    vpc_id = "<your's existing vpc id>"
    vpc_public_subnets = ["<first_sub_domain>", "<second_sub_domain>"]
    vpc_private_subnets = ["<first_sub_domain>", "<second_sub_domain>"]

```
5. provided Domain + VPC and subnets + ECS cluster ([example](https://github.com/Rookout/aws-deployment/blob/main/example/rookout_existing_vpc_and_cluster.tf))
```
    Configure the following variables: 
    domain_name = "YOUR_DOMAIN"
    rookout_token = "YOUR_TOKEN

    create_cluster = false
    vpc_id = "<your's vpc id>"
    vpc_public_subnets = ["<first_sub_domain>", "<second_sub_domain>"]
    vpc_private_subnets = ["<first_sub_domain>", "<second_sub_domain>"]

    create_cluster = false
    cluster_name = "<your's existing cluster name>"
```

## DNS
To run this module, controller, datastore (optional) and demo application (optional) endpoint should be created. To accomplish that ALB will be deployed usign ACM and provided domain address. subdomain will be create in route53. if you don't use route53 as your's dns registry, please contect us for support.

## Endpoints
controller.PROVIDED_DOMAIN - url of the controller, used for SDK (rooks) .

datastore.PROVIDED_DOMAIN - url to the datastore, used with rookout client (web browser application).

demo.PROVIDE_DOMAIN - flask demo application for debuging.  

## Advanced usage
custom_iam_task_exec_role_arn - variable can be used to overwrite the existing IAM Role

deploy_alb - this variable set to false to disable the deployment of ALBs.
If disabled, DNS subdomain and ACM certificate would not be generated too.
following configuration should be set:
```
deploy_alb = false
controller_target_group_arn = "arn:aws:elasticloadbalancing:AWS_REGION:ACCOUNT_ID:ARN_SUFFIX"
datastore_target_group_arn = "arn:aws:elasticloadbalancing:AWS_REGION:ACCOUNT_ID:ARN_SUFFIX" #if deploy_datastore=true
demo_app_target_group_arn = "arn:aws:elasticloadbalancing:AWS_REGION:ACCOUNT_ID:ARN_SUFFIX" #if deploy_demo_app=true
```
If target groups not passed, the loadbalancer configuration block in task defenitaion will be disbaled.


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
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 4.0 |

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
| [aws_iam_policy.task_exec_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
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
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |
| [aws_route53_zone.selected](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/route53_zone) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_additional_controller_env_vars"></a> [additional\_controller\_env\_vars](#input\_additional\_controller\_env\_vars) | Additional env variables of contorller, configure as map of key=values | `any` | `{}` | no |
| <a name="input_additional_datastore_env_vars"></a> [additional\_datastore\_env\_vars](#input\_additional\_datastore\_env\_vars) | Additional env variables of contorller, configure as map of key=values | `any` | `{}` | no |
| <a name="input_additional_demo_app_env_vars"></a> [additional\_demo\_app\_env\_vars](#input\_additional\_demo\_app\_env\_vars) | Additional env variables of contorller, configure as map of key=values | `any` | `{}` | no |
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | ECS cluster name, if we want to deploy to existing one | `string` | `""` | no |
| <a name="input_controller_acm_certificate_arn"></a> [controller\_acm\_certificate\_arn](#input\_controller\_acm\_certificate\_arn) | ARN of pre-imported SSL certificate to ACM for Rookouts controller public access, if datastore ACM provided controller alb will be internal | `string` | `""` | no |
| <a name="input_controller_resource"></a> [controller\_resource](#input\_controller\_resource) | Rookout's onprem controller resource map | `map(any)` | <pre>{<br>  "cpu": 2048,<br>  "memory": 4096<br>}</pre> | no |
| <a name="input_controller_target_group_arn"></a> [controller\_target\_group\_arn](#input\_controller\_target\_group\_arn) | Target group used by controller ECS tasks | `string` | `""` | no |
| <a name="input_create_cluster"></a> [create\_cluster](#input\_create\_cluster) | whether create a cluster or use existing one | `bool` | `true` | no |
| <a name="input_create_vpc"></a> [create\_vpc](#input\_create\_vpc) | # VPC variables. | `bool` | `true` | no |
| <a name="input_custom_iam_task_exec_role_arn"></a> [custom\_iam\_task\_exec\_role\_arn](#input\_custom\_iam\_task\_exec\_role\_arn) | ECS execution IAM Role overwrite, please pass arn of existing IAM Role | `string` | `""` | no |
| <a name="input_datastore_acm_certificate_arn"></a> [datastore\_acm\_certificate\_arn](#input\_datastore\_acm\_certificate\_arn) | ARN of pre-imported SSL certificate to ACM for Rookouts datastore public access | `string` | `""` | no |
| <a name="input_datastore_resource"></a> [datastore\_resource](#input\_datastore\_resource) | Rookout's onprem datastore resource map | `map(any)` | <pre>{<br>  "cpu": 2048,<br>  "memory": 4096<br>}</pre> | no |
| <a name="input_datastore_target_group_arn"></a> [datastore\_target\_group\_arn](#input\_datastore\_target\_group\_arn) | Target group used by datastore ECS tasks | `string` | `""` | no |
| <a name="input_demo_app_controller_host"></a> [demo\_app\_controller\_host](#input\_demo\_app\_controller\_host) | Host which the demo rook connect to controller using WebSocket | `string` | `""` | no |
| <a name="input_demo_app_target_group_arn"></a> [demo\_app\_target\_group\_arn](#input\_demo\_app\_target\_group\_arn) | Target group used by demo applicatino ECS tasks | `string` | `""` | no |
| <a name="input_deploy_alb"></a> [deploy\_alb](#input\_deploy\_alb) | Radio button to not deploy ALB for ECS tasks, if false please provide target group for each | `bool` | `true` | no |
| <a name="input_deploy_datastore"></a> [deploy\_datastore](#input\_deploy\_datastore) | (Optional) If true will deploy demo Rookout's datastore locally | `bool` | `true` | no |
| <a name="input_deploy_demo_app"></a> [deploy\_demo\_app](#input\_deploy\_demo\_app) | (Optional) If true will deploy demo flask application to start debuging | `bool` | `false` | no |
| <a name="input_domain_name"></a> [domain\_name](#input\_domain\_name) | DNS domain which sub | `string` | `""` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | Environment name | `string` | `"rookout"` | no |
| <a name="input_internal_controller_alb"></a> [internal\_controller\_alb](#input\_internal\_controller\_alb) | If domain provided, switching in on will make controller be reachable internaly only | `bool` | `false` | no |
| <a name="input_region"></a> [region](#input\_region) | AWS region, using providers region as default | `string` | `""` | no |
| <a name="input_rookout_token"></a> [rookout\_token](#input\_rookout\_token) | Rookout token | `string` | n/a | yes |
| <a name="input_vpc_avilability_zones"></a> [vpc\_avilability\_zones](#input\_vpc\_avilability\_zones) | n/a | `list(string)` | <pre>[<br>  "eu-west-1a",<br>  "eu-west-1b"<br>]</pre> | no |
| <a name="input_vpc_cidr"></a> [vpc\_cidr](#input\_vpc\_cidr) | n/a | `string` | `"172.30.1.0/25"` | no |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | VPC id should be passed only if create\_vpc = false | `string` | `""` | no |
| <a name="input_vpc_private_subnets"></a> [vpc\_private\_subnets](#input\_vpc\_private\_subnets) | n/a | `list(string)` | <pre>[<br>  "172.30.1.0/27",<br>  "172.30.1.32/27"<br>]</pre> | no |
| <a name="input_vpc_public_subnets"></a> [vpc\_public\_subnets](#input\_vpc\_public\_subnets) | n/a | `list(string)` | <pre>[<br>  "172.30.1.64/27",<br>  "172.30.1.96/27"<br>]</pre> | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_controller_dns"></a> [controller\_dns](#output\_controller\_dns) | Rookout's on-prem controller dns |
| <a name="output_controller_endpoint"></a> [controller\_endpoint](#output\_controller\_endpoint) | Rookout's on-prem controller endpoint |
| <a name="output_datastore_dns"></a> [datastore\_dns](#output\_datastore\_dns) | Rookout's on-prem datastore DNS |
| <a name="output_datastore_endpoint"></a> [datastore\_endpoint](#output\_datastore\_endpoint) | Rookout's on-prem datastore endpoint |
| <a name="output_demo_dns"></a> [demo\_dns](#output\_demo\_dns) | Rookout's flask application DNS |
| <a name="output_demo_endpoint"></a> [demo\_endpoint](#output\_demo\_endpoint) | Rookout's flask application endpoint |
| <a name="output_ecs_cluster_id"></a> [ecs\_cluster\_id](#output\_ecs\_cluster\_id) | ECS cluster |
| <a name="output_vpc_id"></a> [vpc\_id](#output\_vpc\_id) | VPC id that created |
<!-- END_TF_DOCS -->