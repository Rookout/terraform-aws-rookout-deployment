## Deploy Rookout on AWS ECS Fargate Cluster using Terraform

This terraform depolying Rookout Controller and Rookout Datastore on AWS ECS Fargate cluster.

The module implements the following architecture (default deployment):

<img src="https://github.com/Rookout/aws-deployment/blob/main/documentation/AWS_Deployment.jpg?raw=true" width="900">

Network architecture (default deployment):

<img src="https://github.com/Rookout/aws-deployment/blob/main/documentation/AWS_Deployment_Plain_Network.jpg?raw=true" width="900">

### Prerequisites 
1. Terraform installed.
2. AWS account inlcuding: AWS CLI installed.
    * The AWS default profile should be set with an access key and secret ([reference](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-quickstart.html)).
    * Set profile if used non default profile. Run: `export AWS_PROFILE="<profile_name>"`
3. Create a `provider.tf` file ([reference](https://www.terraform.io/language/providers/configuration)).
4. Get your organizational Rookout token, and pass it as a variable to this module
   ```
   rookout_token = "..."
   ```

## Components

This module deploy the Rookout ETL Controller by default. It also allows deployment of the Rookout Datastore, and a demo application with the Rookout agent.

The components to deploy can be configured with the folloiwng boolean variables:

```
    deploy_datastore = true/false
    deploy_demo_app = true/false
```

## Certificate and DNS records management types

There are two methods for certificates and DNS record management that will change the network architecture.

### Module-managed certificate and CNAME record

For deployments where `domain_name` is provided, a `rookout.YOURDOMAIN` subdomain will be created in a route53 public hosted zone, and associated by creating an NS record in your domain's public hosted zone. The subdomain will be used for the controller, datastore (optional) and demo application (optional). A certificate for this subdomain will be created in ACM. ALBs will also be created for those components. The created certificate and DNS records will be associated to those ALBs' domain names.

*Note:* If you don't use route53 as your DNS registry provider, please contact us.

For this type of [deployment](https://github.com/Rookout/aws-deployment/blob/main/example/rookout_default.tf), provide the following variable:

```
    domain_name = "YOUR_DOMAIN"
```

The `internal_controller_alb` boolean variable (false by default) can be used to make the communication with the ETL Controller internal.

### Self-managed certificate and CNAME record

For self managed certificate deployments CNAME record should be created for the Datastore and/or Controller, so we have two options.

1. Provided ACM certificate for the Datastore ([example](https://github.com/Rookout/aws-deployment/blob/main/example/rookout_certificate_datastore.tf))

This deployment will use the pre-imported ARN of the certificate in ACM (Body, private key, and chain of certificate are needed).
THe certificate will be used by the datastore, therefore a CNAME record of the certificate's domain should be recored at your DNS provider with the Datstore endpoint (output of the module).
A Controller will be deployed with an internal load balancer and can be reached from the VPC with the Controller's endpoint (output of the module).
```
    datastore_acm_certificate_arn = "PRE_IMPORTED_ACM_CERTIFICATE_ARN"
```


2. Provided ACM certificate for Datastore and Controller (for internet-facing controller) ([example](https://github.com/Rookout/aws-deployment/blob/main/example/rookout_certificate_datastore_controller.tf))

Same as the previous option, but, the controller is internet facing too. Same procedure of CNAME record registration should be preformed for the Datastore and Controller endpoints that match to their certificate's domain.

```
    datastore_acm_certificate_arn = "PRE_IMPORTED_ACM_CERTIFICATE_ARN"
    controller_acm_certificate_arn = "PRE_IMPORTED_ACM_CERTIFICATE_ARN"
```    

If a demo application is deployed, it should be configured with the Controller's CNAME record:
```
    demo_app_controller_host = "YOUR_CONTROLLER_CNAME_RECORD"
```

## Deplyment matrixes

The following matrixes demonsrate application's components network mode by key variables. HTTP means internal traffic with ALB,  TLS means external secured traffic with ALB. Demo means demo flask application provided with this module. 

<img src="https://github.com/Rookout/aws-deployment/blob/main/documentation/AWS_Deployment_Dep_Matrix_1.jpg?raw=true" width="900">

<img src="https://github.com/Rookout/aws-deployment/blob/main/documentation/AWS_Deployment_Dep_Matrix_2.jpg?raw=true" width="900">

## Endpoints

controller.PROVIDED_DOMAIN - url of the controller, used for SDK (rooks) when DNS provided.

datastore.PROVIDED_DOMAIN - url to the datastore, used with rookout client (web browser application) when DNS provided.

demo.PROVIDE_DOMAIN - flask demo application for debuging when DNS provided.

## Advanced configuration

* Provided Domain + VPC and subnets ([example](https://github.com/Rookout/aws-deployment/blob/main/example/rookout_existing_vpc.tf))

    You can configure the module to use an existing VPC (where your application is running) using the following variables:
    ```
        vpc_id = "<your's existing vpc id>"
        vpc_public_subnets = ["<first_sub_domain>", "<second_sub_domain>"]
        vpc_private_subnets = ["<first_sub_domain>", "<second_sub_domain>"]

    ```

* Provided Domain + VPC and subnets + ECS cluster ([example](https://github.com/Rookout/aws-deployment/blob/main/example/rookout_existing_vpc_and_cluster.tf))

    You can configure the module to use an existing VPC and ECS cluster (where your application is running) using the following variables:
    ```
        vpc_id = "<your's vpc id>"
        vpc_public_subnets = ["<first_sub_domain>", "<second_sub_domain>"]
        vpc_private_subnets = ["<first_sub_domain>", "<second_sub_domain>"]

        create_cluster = false
        cluster_name = "<your's existing cluster name>"
    ```

* custom_iam_task_exec_role_arn - This variable can be used to overwrite the existing IAM Role of ECS tasks execution

* deploy_alb - This variable can be set to false to disable the deployment of ALBs.
    If disabled, DNS subdomain and ACM certificate will not be generated.
    In this case, the following configuration should be set:
    ```
    deploy_alb = false
    controller_target_group_arn = "arn:aws:elasticloadbalancing:AWS_REGION:ACCOUNT_ID:ARN_SUFFIX"
    datastore_target_group_arn = "arn:aws:elasticloadbalancing:AWS_REGION:ACCOUNT_ID:ARN_SUFFIX" #if deploy_datastore=true
    demo_app_target_group_arn = "arn:aws:elasticloadbalancing:AWS_REGION:ACCOUNT_ID:ARN_SUFFIX" #if deploy_demo_app=true
    ```
    If target groups are not passed, the loadbalancer configuration block in task defenitaion will be disbaled.

* internal - boolean variable wich switches the ALBs to be internal only. if provided domain_name will create private hosted zone us that domain. Usually used with wildcard certificate. 

* wildcard certificate can be used with datastore_acm_certificate_arn and controller_acm_certificate_arn variables. when those used, please create CNAME records for controller and datastore out of outputs of this module (controller_endpoint, datastore_endpoint) to match the certificate's domain.


<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.14 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.0 |
| <a name="requirement_awsutils"></a> [awsutils](#requirement\_awsutils) | >= 0.11.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 5.1.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_acm"></a> [acm](#module\_acm) | terraform-aws-modules/acm/aws | ~> 3.0 |
| <a name="module_vpc"></a> [vpc](#module\_vpc) | terraform-aws-modules/vpc/aws | 4.0.2 |

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
| <a name="input_controller_alb_sg_igress_cidr_blocks"></a> [controller\_alb\_sg\_igress\_cidr\_blocks](#input\_controller\_alb\_sg\_igress\_cidr\_blocks) | Ingress CIDRs for controller's ALB security group | `list(string)` | <pre>[<br>  "0.0.0.0/0"<br>]</pre> | no |
| <a name="input_controller_resource"></a> [controller\_resource](#input\_controller\_resource) | Rookout's onprem controller resource map | `map(any)` | <pre>{<br>  "cpu": 2048,<br>  "memory": 4096<br>}</pre> | no |
| <a name="input_controller_sg_igress_cidr_blocks"></a> [controller\_sg\_igress\_cidr\_blocks](#input\_controller\_sg\_igress\_cidr\_blocks) | Ingress CIDRs of controller security group | `list(string)` | <pre>[<br>  "0.0.0.0/0"<br>]</pre> | no |
| <a name="input_controller_target_group_arn"></a> [controller\_target\_group\_arn](#input\_controller\_target\_group\_arn) | Target group used by controller ECS tasks | `string` | `""` | no |
| <a name="input_controller_version"></a> [controller\_version](#input\_controller\_version) | Controller image version | `string` | `"latest"` | no |
| <a name="input_create_cluster"></a> [create\_cluster](#input\_create\_cluster) | whether create a cluster or use existing one | `bool` | `true` | no |
| <a name="input_create_vpc"></a> [create\_vpc](#input\_create\_vpc) | # VPC variables. | `bool` | `true` | no |
| <a name="input_custom_iam_task_exec_role_arn"></a> [custom\_iam\_task\_exec\_role\_arn](#input\_custom\_iam\_task\_exec\_role\_arn) | ECS execution IAM Role overwrite, please pass arn of existing IAM Role | `string` | `""` | no |
| <a name="input_datastore_acm_certificate_arn"></a> [datastore\_acm\_certificate\_arn](#input\_datastore\_acm\_certificate\_arn) | ARN of pre-imported SSL certificate to ACM for Rookouts datastore public access | `string` | `""` | no |
| <a name="input_datastore_alb_sg_igress_cidr_blocks"></a> [datastore\_alb\_sg\_igress\_cidr\_blocks](#input\_datastore\_alb\_sg\_igress\_cidr\_blocks) | Ingress CIDRs datastore's ALB security group | `list(string)` | <pre>[<br>  "0.0.0.0/0"<br>]</pre> | no |
| <a name="input_datastore_resource"></a> [datastore\_resource](#input\_datastore\_resource) | Rookout's onprem datastore resource map | `map(any)` | <pre>{<br>  "cpu": 2048,<br>  "memory": 4096<br>}</pre> | no |
| <a name="input_datastore_sg_igress_cidr_blocks"></a> [datastore\_sg\_igress\_cidr\_blocks](#input\_datastore\_sg\_igress\_cidr\_blocks) | Ingress CIDRs of datastore security group | `list(string)` | <pre>[<br>  "0.0.0.0/0"<br>]</pre> | no |
| <a name="input_datastore_target_group_arn"></a> [datastore\_target\_group\_arn](#input\_datastore\_target\_group\_arn) | Target group used by datastore ECS tasks | `string` | `""` | no |
| <a name="input_datastore_version"></a> [datastore\_version](#input\_datastore\_version) | Datastore image version | `string` | `"latest"` | no |
| <a name="input_demo_app_alb_sg_igress_cidr_blocks"></a> [demo\_app\_alb\_sg\_igress\_cidr\_blocks](#input\_demo\_app\_alb\_sg\_igress\_cidr\_blocks) | Ingress CIDRs datastore's ALB security group | `list(string)` | <pre>[<br>  "0.0.0.0/0"<br>]</pre> | no |
| <a name="input_demo_app_controller_host"></a> [demo\_app\_controller\_host](#input\_demo\_app\_controller\_host) | Host which the demo rook connect to controller using WebSocket | `string` | `""` | no |
| <a name="input_demo_app_sg_igress_cidr_blocks"></a> [demo\_app\_sg\_igress\_cidr\_blocks](#input\_demo\_app\_sg\_igress\_cidr\_blocks) | Ingress CIDRs of datastore security group | `list(string)` | <pre>[<br>  "0.0.0.0/0"<br>]</pre> | no |
| <a name="input_demo_app_target_group_arn"></a> [demo\_app\_target\_group\_arn](#input\_demo\_app\_target\_group\_arn) | Target group used by demo applicatino ECS tasks | `string` | `""` | no |
| <a name="input_deploy_alb"></a> [deploy\_alb](#input\_deploy\_alb) | Radio button to not deploy ALB for ECS tasks, if false please provide target group for each | `bool` | `true` | no |
| <a name="input_deploy_datastore"></a> [deploy\_datastore](#input\_deploy\_datastore) | (Optional) If true will deploy demo Rookout's datastore locally | `bool` | `true` | no |
| <a name="input_deploy_demo_app"></a> [deploy\_demo\_app](#input\_deploy\_demo\_app) | (Optional) If true will deploy demo flask application to start debuging | `bool` | `false` | no |
| <a name="input_domain_name"></a> [domain\_name](#input\_domain\_name) | DNS domain which sub | `string` | `""` | no |
| <a name="input_enforce_token"></a> [enforce\_token](#input\_enforce\_token) | Whether to enforce the token in controller | `bool` | `true` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | Environment name | `string` | `"rookout"` | no |
| <a name="input_internal"></a> [internal](#input\_internal) | Flag to switch the deployment to be internal | `bool` | `false` | no |
| <a name="input_internal_controller_alb"></a> [internal\_controller\_alb](#input\_internal\_controller\_alb) | If domain provided, switching in on will make controller be reachable internaly only | `bool` | `false` | no |
| <a name="input_region"></a> [region](#input\_region) | AWS region, using providers region as default | `string` | `""` | no |
| <a name="input_rookout_token"></a> [rookout\_token](#input\_rookout\_token) | Rookout token | `string` | `""` | no |
| <a name="input_vpc_availability_zones"></a> [vpc\_availability\_zones](#input\_vpc\_availability\_zones) | n/a | `list(string)` | <pre>[<br>  ""<br>]</pre> | no |
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
