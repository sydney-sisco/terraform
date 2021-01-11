variable "env_prefix" {
  description = "An optional prefix to apply to resources, allows for multiple deployments within the same AWS account to avoid naming conflicts."
  default = ""
}

variable "bucket_name" {
  description = "The name of the S3 bucket to create. S3 bucket names must be globally unique."
}

variable "instance_type" {
  description = "The type of instance to launch. Defaults to t3.medium"
  default = "t3.medium"
}

variable "ssh_key_name" {
  description = "The name of the SSH key pair to use for the EC2 instance"
}
