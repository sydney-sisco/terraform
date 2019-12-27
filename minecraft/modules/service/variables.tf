variable "bucket_name" {
  description = "The name of the S3 bucket to create. S3 bucket names must be globally unique."
}

variable "ssh_key_name" {
  description = "The name of the SSH key pair to use for the EC2 instance"
}
