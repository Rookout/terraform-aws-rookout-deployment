##Global variables
variable "environment" {
  type        = string
  default     = "demo"
  description = "Environment name"
}
variable "region" {
  type        = string
  default     = "eu-west-1"
  description = "Aws region"
}

## DNS
variable "domain_name" {
  type    = string
  default = ""
  validation {
    condition     = length(var.domain_name) > 0
    error_message = "Domain not provided"
  }
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

variable "rookout_token" {
  type = string
  validation {
    condition     = length(var.rookout_token) == 64
    error_message = "Rookout token have to be 64 characters in length"
  }
  description = "Rookout token"
}

variable "secret_key" {
  type        = string
  default     = "rookout-token"
  description = "Key of secret in secret manager"
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

variable "vpc_avilability_zones" {
  type    = list(string)
  default = ["eu-west-1a", "eu-west-1b"]
}

variable "vpc_private_subnets" {
  type    = list(string)
  default = ["172.30.1.0/27", "172.30.1.32/27"]
}

variable "vpc_public_subnets" {
  type    = list(string)
  default = ["172.30.1.64/27", "172.30.1.96/27"]
}

## IAM ECS execution role
variable "custom_iam_task_exec_role_arn" {
  type        = string
  default     = ""
  description = "ECS execution IAM Role overwrite, please pass arn of existing IAM Role"
}

