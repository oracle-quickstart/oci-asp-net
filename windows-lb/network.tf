## Copyright © 2021, Oracle and/or its affiliates. 
## All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl

/* Network */
resource "oci_core_vcn" "vcn1" {
  cidr_block     = var.vcn_cidr
  compartment_id = var.compartment_ocid
  display_name   = "vcn1"
  dns_label      = "vcn1"
  defined_tags   = { "${oci_identity_tag_namespace.ArchitectureCenterTagNamespace.name}.${oci_identity_tag.ArchitectureCenterTag.name}" = var.release }
}

resource "oci_core_subnet" "subnet1" {
  cidr_block        = var.subnet1_cidr
  display_name      = "subnet1"
  dns_label         = "subnet1"
  security_list_ids = [oci_core_security_list.securitylist1.id]
  compartment_id    = var.compartment_ocid
  vcn_id            = oci_core_vcn.vcn1.id
  route_table_id    = oci_core_route_table.routetable1.id
  dhcp_options_id   = oci_core_vcn.vcn1.default_dhcp_options_id

  provisioner "local-exec" {
    command = "sleep 5"
  }
  defined_tags = { "${oci_identity_tag_namespace.ArchitectureCenterTagNamespace.name}.${oci_identity_tag.ArchitectureCenterTag.name}" = var.release }
}

resource "oci_core_subnet" "subnet2" {
  count                      = var.deploy_db_tier ? 1 : 0
  cidr_block                 = var.subnet2_cidr
  display_name               = "subnet2"
  dns_label                  = "subnet2"
  security_list_ids          = [oci_core_security_list.securitylist1.id]
  compartment_id             = var.compartment_ocid
  vcn_id                     = oci_core_vcn.vcn1.id
  route_table_id             = oci_core_route_table.routetable2.id
  dhcp_options_id            = oci_core_vcn.vcn1.default_dhcp_options_id
  prohibit_public_ip_on_vnic = true

  provisioner "local-exec" {
    command = "sleep 5"
  }
  defined_tags = { "${oci_identity_tag_namespace.ArchitectureCenterTagNamespace.name}.${oci_identity_tag.ArchitectureCenterTag.name}" = var.release }
}


resource "oci_core_internet_gateway" "internetgateway1" {
  compartment_id = var.compartment_ocid
  display_name   = "internetgateway1"
  vcn_id         = oci_core_vcn.vcn1.id
  defined_tags   = { "${oci_identity_tag_namespace.ArchitectureCenterTagNamespace.name}.${oci_identity_tag.ArchitectureCenterTag.name}" = var.release }
}

resource "oci_core_route_table" "routetable1" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.vcn1.id
  display_name   = "routetable1"

  route_rules {
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_internet_gateway.internetgateway1.id
  }
  defined_tags = { "${oci_identity_tag_namespace.ArchitectureCenterTagNamespace.name}.${oci_identity_tag.ArchitectureCenterTag.name}" = var.release }
}

resource "oci_core_nat_gateway" "natgateway1" {
  compartment_id = var.compartment_ocid
  display_name   = "natgateway1"
  vcn_id         = oci_core_vcn.vcn1.id
  defined_tags   = { "${oci_identity_tag_namespace.ArchitectureCenterTagNamespace.name}.${oci_identity_tag.ArchitectureCenterTag.name}" = var.release }
}

resource "oci_core_route_table" "routetable2" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.vcn1.id
  display_name   = "routetable2"

  route_rules {
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_nat_gateway.natgateway1.id
  }
  defined_tags = { "${oci_identity_tag_namespace.ArchitectureCenterTagNamespace.name}.${oci_identity_tag.ArchitectureCenterTag.name}" = var.release }
}

resource "oci_core_public_ip" "test_reserved_ip" {
  compartment_id = var.compartment_ocid
  lifetime       = "RESERVED"

  lifecycle {
    ignore_changes = [private_ip_id]
  }
  defined_tags = { "${oci_identity_tag_namespace.ArchitectureCenterTagNamespace.name}.${oci_identity_tag.ArchitectureCenterTag.name}" = var.release }
}

resource "oci_core_security_list" "securitylist1" {
  display_name   = "WindowsTestSecurityList"
  compartment_id = oci_core_vcn.vcn1.compartment_id
  vcn_id         = oci_core_vcn.vcn1.id

  ingress_security_rules {
    protocol = "6"
    source   = "0.0.0.0/0"

    tcp_options {
      min = 80
      max = 80
    }
  }

  ingress_security_rules {
    protocol = "6"
    source   = "0.0.0.0/0"

    tcp_options {
      min = 443
      max = 443
    }
  }

  # allow inbound remote desktop traffic
  ingress_security_rules {
    protocol  = "6" # tcp
    source    = "0.0.0.0/0"
    stateless = false

    tcp_options {
      # These values correspond to the destination port range.
      min = 3389
      max = 3389
    }
  }

  # allow inbound winrm traffic
  ingress_security_rules {
    protocol  = "6" # tcp
    source    = "0.0.0.0/0"
    stateless = false

    tcp_options {
      # These values correspond to the destination port range.
      min = 5985
      max = 5986
    }
  }

  egress_security_rules {
    protocol    = "all"
    destination = "0.0.0.0/0"
  }
  defined_tags = { "${oci_identity_tag_namespace.ArchitectureCenterTagNamespace.name}.${oci_identity_tag.ArchitectureCenterTag.name}" = var.release }
}
