# Outputs

output "username1" {
  value = [data.oci_core_instance_credentials.instance_credentials1.username]
}

output "password1" {
  value = [data.oci_core_instance_credentials.instance_credentials1.password]
}

output "username2" {
  value = [data.oci_core_instance_credentials.instance_credentials2.username]
}

output "password2" {
  value = [data.oci_core_instance_credentials.instance_credentials2.password]
}

output "instance_public_ip1" {
  value = [oci_core_instance.instance1.public_ip]
}

output "instance_public_ip2" {
  value = [oci_core_instance.instance2.public_ip]
}

output "instance_private_ip1" {
  value = [oci_core_instance.instance1.private_ip]
}

output "instance_private_ip2" {
  value = [oci_core_instance.instance2.private_ip]
}

output "lb_public_ip" {
  value = [oci_load_balancer.lb1.ip_address_details]
}

