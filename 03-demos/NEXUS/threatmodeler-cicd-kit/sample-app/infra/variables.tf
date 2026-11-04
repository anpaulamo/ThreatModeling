variable "region" {
  type    = string
  default = "us-east-1"
}

variable "environment" {
  type    = string
  default = "demo"
}

variable "vpc_cidr" {
  type    = string
  default = "10.40.0.0/16"
}

variable "app_image" {
  description = "Container image for the LedgerLite API"
  type        = string
  default     = "public.ecr.aws/example/ledgerlite-api:latest"
}

variable "acm_certificate_arn" {
  description = "ACM certificate for the public HTTPS listener"
  type        = string
  default     = "arn:aws:acm:us-east-1:111111111111:certificate/00000000-0000-0000-0000-000000000000"
}
