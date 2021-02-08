
/* Instances */

resource "oci_core_instance" "instance1" {
  availability_domain = data.oci_identity_availability_domain.ad1.name
  compartment_id      = var.compartment_ocid
  display_name        = "be-instance1"
  shape               = var.instance_shape

  # Refer cloud-init in https://docs.cloud.oracle.com/iaas/api/#/en/iaas/20160918/datatypes/LaunchInstanceDetails
  metadata = {
    # Base64 encoded YAML based user_data to be passed to cloud-init
    user_data = data.template_cloudinit_config.cloudinit_config.rendered
  }

  create_vnic_details {
    subnet_id      = oci_core_subnet.subnet1.id
    hostname_label = "be-instance1"
  }

  source_details {
    source_type = "image"
    source_id   = data.oci_core_images.this.images[0].id # var.instance_image_ocid[var.region]
  }
}

resource "oci_core_instance" "instance2" {
  availability_domain = data.oci_identity_availability_domain.ad2.name
  compartment_id      = var.compartment_ocid
  display_name        = "be-instance2"
  shape               = var.instance_shape

  # Refer cloud-init in https://docs.cloud.oracle.com/iaas/api/#/en/iaas/20160918/datatypes/LaunchInstanceDetails
  metadata = {
    # Base64 encoded YAML based user_data to be passed to cloud-init
    user_data = data.template_cloudinit_config.cloudinit_config.rendered
  }

  create_vnic_details {
    subnet_id      = oci_core_subnet.subnet2.id
    hostname_label = "be-instance2"
  }

  source_details {
    source_type = "image"
    source_id   = data.oci_core_images.this.images[0].id # var.instance_image_ocid[var.region]
  }
}
