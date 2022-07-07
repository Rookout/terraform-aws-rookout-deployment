##Global variables
variable "environment" {
    type = string
    default = "demo"
    description = "Enviorment name"
}
variable "region" {
    type = string
    default = "eu-west-1"
    description = "Aws region"
}

## Demo
variable "deploy_demo" {
    type = bool
    default = true
    description = "whether to deploy demo application"
}
## ECS variables
variable "create_cluster" {
    type = bool
    default = true
    description = "whether create a cluster or use existing one"
}


## DNS

variable "domain_name" {
    type = string
    default = "rookout-example.com"
    description = "DNS domain which sub"
}

#should be configured only of create_cluster = false
variable "cluster_name" {
    type = string
    default = ""
    description = "ECS cluster name, if we want to deploy to existing one"
}


## Rookout variables

variable "deploy_demo_app" {
    type = bool
    default = true
    description = "(Optional) If true will deploy demo flask application to start debuging"
}

variable "rookout_token_arn" {
    type = string
    default = ""
    description = "arn of rookout secret in secret manager"
}

variable "secret_key" {
    type = string
    default = "rookout-token"
    description = "Key of secret in secret manager"
}
## ALB variables
#if this variable set to false. please set manully the varibels
variable "create_alb" {
    type = bool
    default = true  
}

variable "alb_arn" {
  type = string
  description = "VPC should be passed only if creat_alb = false"
  default = ""
}

## VPC variables. 
#if this variable set to false. please set manully the varibels
variable "create_vpc" {
    type = bool
    default = true  
}

variable "vpc_id" {
  type = string
  description = "VPC id should be passed only if create_vpc = false"
  default = ""
}

variable "vpc_cidr" {
    type = string
    default = "10.0.0.0/16"
}

variable "vpc_avilability_zones" {
    type = list(string)
    default = ["eu-west-1a", "eu-west-1b"]
}

variable "vpc_private_subnets" {
    type = list(string)
    default = ["10.0.0.0/27", "10.0.0.32/27"]
}

variable "vpc_public_subnets" {
    type = list(string)
    default = ["10.0.0.64/27", "10.0.0.128/27"]
}