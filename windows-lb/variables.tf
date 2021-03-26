
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
  default = 3
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