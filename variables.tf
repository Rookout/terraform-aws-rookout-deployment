##Global variables
variable "environment" {
  type        = string
  default     = "rookout"
  description = "Environment name"
}
variable "region" {
  type        = string
  default     = ""
  description = "AWS region, using providers region as default"
}

## DNS
variable "domain_name" {
  type    = string
  default = ""
  # validation {
  #   condition     = length(var.domain_name) > 0
  #   error_message = "Domain not provided"
  # }
  description = "DNS domain which sub"
}


## ECS variables
variable "create_cluster" {
  type        = bool
  default     = true
  description = "whether create a cluster or use existing one"
}

#should be configured only of create_cluster = false
variable "cluster_name" {
  type        = string
  default     = ""
  description = "ECS cluster name, if we want to deploy to existing one"
}

## Rookout variables
variable "deploy_datastore" {
  type        = bool
  default     = true
  description = "(Optional) If true will deploy demo Rookout's datastore locally"
}
variable "deploy_demo_app" {
  type        = bool
  default     = false
  description = "(Optional) If true will deploy demo flask application to start debuging"
}

variable "controller_resource" {
  type = map(any)
  default = {
    cpu    = 2048,
    memory = 4096
  }
  description = "Rookout's onprem controller resource map"
}

variable "controller_replicas" {
  type        = string
  default     = 2
  description = "Rookout's onprem controller replica count"
}


variable "datastore_resource" {
  type = map(any)
  default = {
    cpu    = 2048,
    memory = 4096
  }
  description = "Rookout's onprem datastore resource map"
}

variable "datastore_image" {
  type        = string
  default     = "rookout/data-on-prem"
  description = "Datastore image name"
}

variable "datastore_version" {
  type        = string
  default     = "latest"
  description = "Datastore image version"
}

variable "controller_version" {
  type        = string
  default     = "latest"
  description = "Controller image version"
}

variable "controller_image" {
  type        = string
  default     = "rookout/controller"
  description = "Controller image name"
}

variable "rookout_token" {
  type = string
  validation {
    condition     = var.rookout_token == "" || length(var.rookout_token) == 64
    error_message = "Rookout token have to be 64 characters in length."
  }
  default     = ""
  description = "Rookout token"
}

variable "enforce_token" {
  type        = bool
  default     = true
  description = "Whether to enforce the token in controller"
}

## VPC variables. 
variable "create_vpc" {
  type    = bool
  default = true
}

variable "vpc_id" {
  type        = string
  description = "VPC id should be passed only if create_vpc = false"
  default     = ""
}

variable "vpc_cidr" {
  type    = string
  default = "172.30.1.0/25"
}

variable "vpc_availability_zones" {
  type    = list(string)
  default = [""]
}

variable "vpc_private_subnets" {
  type    = list(string)
  default = ["172.30.1.0/27", "172.30.1.32/27"]
}

variable "vpc_public_subnets" {
  type    = list(string)
  default = ["172.30.1.64/27", "172.30.1.96/27"]
}

variable "subdomain_vpc_association" {
  type        = bool
  default     = true
  description = "flag for association of a hosted zone with a vpc"
}

## IAM ECS execution role
variable "custom_iam_task_exec_role_arn" {
  type        = string
  default     = ""
  description = "ECS execution IAM Role overwrite, please pass arn of existing IAM Role"
}

## ALB
variable "deploy_alb" {
  type        = bool
  default     = true
  description = "Radio button to not deploy ALB for ECS tasks, if false please provide target group for each"
}

variable "controller_target_group_arn" {
  type        = string
  default     = ""
  description = "Target group used by controller ECS tasks"
}

variable "datastore_target_group_arn" {
  type        = string
  default     = ""
  description = "Target group used by datastore ECS tasks"
}

variable "demo_app_target_group_arn" {
  type        = string
  default     = ""
  description = "Target group used by demo applicatino ECS tasks"
}

variable "demo_app_controller_host" {
  type        = string
  default     = ""
  description = "Host which the demo rook connect to controller using WebSocket"
}

variable "internal_controller_alb" {
  type        = bool
  default     = false
  description = "If domain provided, switching in on will make controller be reachable internaly only"
}

## ENV vars
# {
#     "EXAMPLE_ENV" = "changethisvalue"
# }
variable "additional_controller_env_vars" {
  type        = any
  description = "Additional env variables of contorller, configure as map of key=values"
  default     = {}
}

variable "additional_datastore_env_vars" {
  type        = any
  description = "Additional env variables of contorller, configure as map of key=values"
  default     = {}
}

variable "additional_demo_app_env_vars" {
  type        = any
  description = "Additional env variables of contorller, configure as map of key=values"
  default     = {}
}

## Self managed ACM certificates
variable "datastore_acm_certificate_arn" {
  type        = string
  default     = ""
  description = "ARN of pre-imported SSL certificate to ACM for Rookouts datastore public access"
}

variable "controller_acm_certificate_arn" {
  type        = string
  default     = ""
  description = "ARN of pre-imported SSL certificate to ACM for Rookouts controller public access, if datastore ACM provided controller alb will be internal"
}

variable "internal" {
  type        = bool
  default     = false
  description = "Flag to switch the deployment to be internal"
}

variable "controller_sg_igress_cidr_blocks" {
  type        = list(string)
  default     = ["0.0.0.0/0"]
  description = "Ingress CIDRs of controller security group"
}

variable "controller_alb_sg_igress_cidr_blocks" {
  type        = list(string)
  default     = ["0.0.0.0/0"]
  description = "Ingress CIDRs for controller's ALB security group"
}

variable "datastore_sg_igress_cidr_blocks" {
  type        = list(string)
  default     = ["0.0.0.0/0"]
  description = "Ingress CIDRs of datastore security group"
}

variable "datastore_alb_sg_igress_cidr_blocks" {
  type        = list(string)
  default     = ["0.0.0.0/0"]
  description = "Ingress CIDRs datastore's ALB security group"
}

variable "demo_app_sg_igress_cidr_blocks" {
  type        = list(string)
  default     = ["0.0.0.0/0"]
  description = "Ingress CIDRs of datastore security group"
}

variable "demo_app_alb_sg_igress_cidr_blocks" {
  type        = list(string)
  default     = ["0.0.0.0/0"]
  description = "Ingress CIDRs datastore's ALB security group"
}

variable "deploy_dynatrace_agent" {
  type = bool
  default = false
  description = "Flag to deploy dynatrace oneagent inside the application"
}

variable "dynatrace_pass_token" {
  type = string
  default = ""
  sensitive = true
  description = "Dynatrace pass token"
}