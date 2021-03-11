# Generali
variable "domain" {
    type = string 
}

variable "private_domain" {
    type = string
}

variable "owner" {
  type        = string
}

# VPC
variable "vpc_cidr" {
    description = "CIDR for the whole VPC"
    default = "10.0.0.0/24"
}

variable "private_subnet_cidr_a" {
    description = "CIDR Subnet privata zona A"
    default = "10.0.0.0/26"
}

variable "private_subnet_cidr_b" {
    description = "CIDR Subnet privata zona B"
    default = "10.0.0.64/26"
}

variable "public_subnet_cidr_a" {
    description = "CIDR Subnet pubblica zona A"
    default = "10.0.0.128/26"
}

variable "public_subnet_cidr_b" {
    description = "CIDR Subnet pubblica zona B"
    default = "10.0.0.192/26"
}

# EC2
variable "ec2_instance_type" {
  type = string
}

variable "ami_images_id" {
  type = string
}

# RDS
variable "db_host" {
type = string
}

variable "db_user" {
    type = string 
}

variable "db_pass" {
    type = string 
}

# Wordpress
variable "wp_url" {
  type    = string
}

variable "wp_title" {
  type    = string
}

variable "wp_user" {
  type    = string
}

variable "wp_pass" {
  type    = string
}

variable "wp_dbname" {
  type    = string
}



