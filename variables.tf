variable "application_name" {}
variable "region" {}
variable "vpc_cidr" {}
variable "pub_sub_cidr" {}
variable "pub_sub_cidr1" {}
variable "pri_sub_cidr" {}
variable "ami_id" {}
variable "instance_type" {}
variable "cluster_name" {}
variable "node_instance_type" {}

# Route 53 zone ID and domain names are now hardcoded in the main.tf file
# Removing these variables as they are no longer needed

# variable "route53_zone_id" {
#   description = "The Route 53 Hosted Zone ID to add the record to"
#   type        = string
# }

# variable "domain_name" {
#   description = "The domain name for the Route 53 record"
#   type        = string
# }