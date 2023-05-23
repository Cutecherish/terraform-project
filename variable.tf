variable "vpc-cidr" {
  default = "10.0.0.0/16"
  description = "VPC CIDR BLOCK"
  type = string
}

variable "public-subnet-1-cidr" {
  default = "10.0.0.0/24"
  description = "PUBLIC SUBNET 1 CIDR BLOCK"
  type = string
}
variable "public-subnet-2-cidr" {
  default = "10.0.1.0/24"
  description = "PUBLIC SUBNET 2 CIDR BLOCK"
  type = string
}
variable "private-subnet-1-cidr" {
  default = "10.0.2.0/24"
  description = "PRIVATE SUBNET 1 CIDR BLOCK"
  type = string
}
variable "private-subnet-2-cidr" {
  default = "10.0.3.0/24"
  description = "PRIVATE SUBNET 2 CIDR BLOCK"
  type = string
}
variable "private-subnet-3-cidr" {
  default = "10.0.4.0/24"
  description = "PRIVATE SUBNET 3 CIDR BLOCK"
  type = string
}
variable "private-subnet-4-cidr" {
  default = "10.0.5.0/24"
  description = "PRIVATE SUBNET 4 CIDR BLOCK"
  type = string
}
variable "ssh-location" {
  default = "0.0.0.0/0"
  description = "ip address that can ssh into the ec2 instance"
  type = string
}

# Route 53 variables
variable "domain_name" {
  type        = string
  description = "domain name"
  default     = "amanda-school.co.uk"
}

variable "record_name" {
  type        = string
  description = "sub domain name"
  default     = "www"
}
variable "ami" {
  type        = string
  description = "ami number"
  default     = "ami-03c7d01cf4dedc891"
}
variable "instance_type" {
  type        = string
  description = "instance type"
  default     = "t2.micro"
}