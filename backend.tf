#terraform {
#  backend "s3" {
#    bucket  = "terraform-states"
#    key     = "exercise-state"
#    region  = "eu-west-1"
#    encrypt = true
#  }
#}
#
#data "terraform_remote_state" "remote-state" {
#  backend = "s3"
#  config = {
#    bucket = "terraform-states"
#  }
#}
#