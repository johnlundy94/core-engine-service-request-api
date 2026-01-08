variable "aws_region" {
  type    = string
  default = "us-east-2"
}

variable "project_name" {
  type    = string
  default = "core-engine"
}

variable "env" {
  type    = string
  default = "dev"
}

# Set to true in prod
variable "deletion_protection_enabled" {
  type    = bool
  default = false
}