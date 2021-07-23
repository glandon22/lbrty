variable "aws_access_key" {
  description = "AWS access key"
  type        = string
  sensitive   = true
}

variable "aws_secret_key" {
  description = "AWS secret key"
  type        = string
  sensitive   = true
}

variable "aws_region" {
  description = "AWS region"
  type        = string
  sensitive   = true
}

variable "jenkins_pk_loc" {
  description = "Jenkins private key location"
  type = string
  sensitive = true
}

variable "lbrty_pk_loc" {
  description = "lbrty server private key location"
  type = string
  sensitive = true
}