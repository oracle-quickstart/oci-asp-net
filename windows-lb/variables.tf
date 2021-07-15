## Copyright © 2021, Oracle and/or its affiliates. 
## All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl

# Authentcation variables to be commented when using ORM
variable "user_ocid" {}
variable "fingerprint" {}
variable "private_key_path" {}
variable "region" {}

variable "tenancy_ocid" {}
variable "compartment_ocid" {}

variable "availablity_domain_name" {
  default = ""
}

variable "deploy_db_tier" {
  default = true
}
variable "instance_password" {}

variable "release" {
  description = "Reference Architecture Release (OCI Architecture Center)"
  default     = "1.0"
}

variable "lb_shape" {
  default = "flexible"
}

variable "flex_lb_min_shape" {
  default = "10"
}

variable "flex_lb_max_shape" {
  default = "100"
}

variable "instance_shape" {
  default = "VM.Standard2.1"
}

variable "shape_flex_ocpus" {
  default = 1
}

variable "shape_flex_memory" {
  default = 10
}

variable "instance_name" {
  default = "TFWindows"
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

variable "vcn_cidr" {
  default = "10.1.0.0/16"
}

variable "subnet1_cidr" {
  default = "10.1.20.0/24"
}

variable "subnet2_cidr" {
  default = "10.1.21.0/24"
}

variable "mssql_primary_shape" {
  default = "VM.Standard2.2"
}

variable "mssql_standby_shape" {
  default = "VM.Standard2.2"
}

# Dictionary Locals
locals {
  compute_flexible_shapes = [
    "VM.Standard.E3.Flex",
    "VM.Standard.E4.Flex",
    "VM.Optimized3.Flex",
    "VM.Standard.A1.Flex"
  ]
}

# Checks if is using Flexible Compute Shapes
locals {
  is_flexible_node_shape = contains(local.compute_flexible_shapes, var.instance_shape)
  is_flexible_lb_shape   = var.lb_shape == "flexible" ? true : false
}
