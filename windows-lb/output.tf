# Outputs

output "username1" {
  value = [data.oci_core_instance_credentials.instance_credentials1.username]
}

output "username2" {
  value = [data.oci_core_instance_credentials.instance_credentials2.username]
}

output "instance_public_ip1" {
  value = [oci_core_instance.instance1.public_ip]
}

output "instance_public_ip2" {
  value = [oci_core_instance.instance2.public_ip]
}

output "lb_public_ip" {
  value = "http://${oci_load_balancer.lb1.ip_address_details[0].ip_address}"
}

