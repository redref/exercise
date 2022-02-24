#
# AWS Provider
#
variable "provider_aws_access_key" {
  default = "AKIAXTT44CQKD7Q3GGXH"
}

variable "provider_aws_secret_key_sops_file" {
  default = "aws_secret_key.json.enc"
}

variable "region" {
  default = "eu-west-1"
}

variable "az_count" {
  default = 2
}

variable "app_port" {
  description = "Port exposed by the docker image to redirect traffic to"
  default     = 80
}

variable "app_image" {
  description = "Docker image to run in the ECS cluster"
  default     = "kennethreitz/httpbin:latest"
}

variable "app_count" {
  description = "Minimum number of docker containers to run"
  default     = 2
}

variable "fargate_cpu" {
  description = "Fargate instance CPU units to provision (1 vCPU = 1024 CPU units)"
  default     = 512
}

variable "fargate_memory" {
  description = "Fargate instance memory to provision (in MiB)"
  default     = 128
}

variable "mock_aws" {
  description = "Enable mock for AWS"
  default     = false
}

variable "mock_zones" {
  description = "Dummy zone names used for testing"
  default     = ["a", "b", "c"]
}
