## Copyright © 2021, Oracle and/or its affiliates. 
## All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl

resource "oci_core_instance" "MSSQL_Primary" {
  count               = var.deploy_db_tier ? 1 : 0
  availability_domain = var.availablity_domain_name == "" ? data.oci_identity_availability_domains.ADs.availability_domains[0]["name"] : var.availablity_domain_name
  compartment_id      = var.compartment_ocid
  display_name        = "MSSQLPrimaryVM"
  fault_domain        = "FAULT-DOMAIN-1"
  shape               = var.mssql_primary_shape

  source_details {
    source_type = "image"
    source_id   = lookup(data.oci_core_app_catalog_listing_resource_version.App_Catalog_Listing_Resource_Version, "listing_resource_id")
  }

  # Refer cloud-init in https://docs.cloud.oracle.com/iaas/api/#/en/iaas/20160918/datatypes/LaunchInstanceDetails
  metadata = {
    # Base64 encoded YAML based user_data to be passed to cloud-init
    user_data = data.template_cloudinit_config.cloudinit_config.rendered
  }

  create_vnic_details {
    subnet_id        = oci_core_subnet.subnet2[count.index].id
    assign_public_ip = false
  }

  defined_tags = { "${oci_identity_tag_namespace.ArchitectureCenterTagNamespace.name}.${oci_identity_tag.ArchitectureCenterTag.name}" = var.release }
}

resource "oci_core_instance" "MSSQL_Standby" {
  count               = var.deploy_db_tier ? 1 : 0
  availability_domain = var.availablity_domain_name == "" ? data.oci_identity_availability_domains.ADs.availability_domains[0]["name"] : var.availablity_domain_name
  compartment_id      = var.compartment_ocid
  display_name        = "MSSQLStandbyVM"
  fault_domain        = "FAULT-DOMAIN-2"
  shape               = var.mssql_standby_shape

  source_details {
    source_type = "image"
    source_id   = lookup(data.oci_core_app_catalog_listing_resource_version.App_Catalog_Listing_Resource_Version, "listing_resource_id")
  }

  # Refer cloud-init in https://docs.cloud.oracle.com/iaas/api/#/en/iaas/20160918/datatypes/LaunchInstanceDetails
  metadata = {
    # Base64 encoded YAML based user_data to be passed to cloud-init
    user_data = data.template_cloudinit_config.cloudinit_config.rendered
  }

  create_vnic_details {
    subnet_id        = oci_core_subnet.subnet2[count.index].id
    assign_public_ip = false
  }

  defined_tags = { "${oci_identity_tag_namespace.ArchitectureCenterTagNamespace.name}.${oci_identity_tag.ArchitectureCenterTag.name}" = var.release }
}

