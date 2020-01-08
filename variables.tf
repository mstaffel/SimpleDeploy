variable "aws_region" {
  description = "AWS region to launch servers."
  default     = "us-east-1"
}

variable "aws_secret_key" {
  description = "AWS secret key, ~40 characters"
}

variable "aws_access_key" {
  description = "AWS access key, ~20 characters"
}

variable "private_key_path" {
  description = "Desired private key file (A .pem file on your local machine)"
}

variable "key_name" {
  description = "Desired name of AWS key pair"
  default     = "bytecubed"
}
