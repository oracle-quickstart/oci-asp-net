
# Authentcation variables to be commented when using ORM
variable "user_ocid" {}
variable "fingerprint" {}
variable "private_key_path" {}
variable "region" {}

variable "tenancy_ocid" {}
variable "compartment_ocid" {}


variable "load_balancer_shape_details_maximum_bandwidth_in_mbps" {
  default = 100
}

variable "load_balancer_shape_details_minimum_bandwidth_in_mbps" {
  default = 10
}

variable "instance_shape" {
  default = "VM.Standard2.1"
}

variable "instance_name" {
  default = "TFWindows"
}

variable "availability_domain" {
  default = 1
}

variable "num_nodes" {
  default = 2
}

variable "instance_ocpus" {
  default = 1
}

variable "instance_password" {

}

variable "userdata" {
  default = "userdata"
}

variable "cloudinit_ps1" {
  default = "cloudinit.ps1"
}

variable "cloudinit_config" {
  default = "cloudinit.yml"
}

variable "index_html" {
  default = "index.html"
}

variable "image_os" {
  default = "Windows"
}
variable "image_os_version" {
  default = "Server 2012 R2 Standard"
}

variable "subnet_cidr" {
  type    = list(string)
  default = ["10.1.20.0/24", "10.1.21.0/24"]
}

locals {
  compute_flexible_shapes = [
    "VM.Standard.E3.Flex",
    "VM.Standard.E4.Flex"
  ]
  compute_shape_flexible_descriptions = [
    "Cores for Standard.E3.Flex and BM.Standard.E3.128 Instances",
    "Cores for Standard.E4.Flex and BM.Standard.E4.128 Instances"
  ]
  compute_shape_flexible_vs_descriptions = zipmap(local.compute_flexible_shapes, local.compute_shape_flexible_descriptions)
  compute_shape_description              = lookup(local.compute_shape_flexible_vs_descriptions, local.instance_shape, local.instance_shape)
}
