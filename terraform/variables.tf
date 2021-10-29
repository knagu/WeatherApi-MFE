variable "aws_region" {
  default     = "us-west-2"
  description = "AWS region"
}

variable "registry_username" {
  default = "AWS"
}
#variable "registry_password" {
#}
variable "docker_build_tag" {
  default = "btag"  
}

variable "prefix" {
  default = "dax"
}

variable "project" {
  default = "coreinfra"
}
variable "auth0_client_id" {
}

variable "auth0_client_secret" {
}

variable "namespace" {
  default = "dev"
}

