// Copyright (c) 2017, 2021, Oracle and/or its affiliates. All rights reserved.
// Licensed under the Mozilla Public License v2.0


####################################
# Execute Windows Commands Remotely
####################################
/*
  This resource depends on instance creation and volume attachment. After both of them are ready, will perform scripts execution on remote instances.
  This block will help upload the scripts to remote instances and execute them.

  Troubleshooting tips:

  To check if winrm is listening:
  curl --header "Content-Type: application/soap+xml;charset=UTF-8" --header "WSMANIDENTIFY: unauthenticated" --insecure https://<ip-address>:5986/wsman --data '&lt;s:Envelope xmlns:s="http://www.w3.org/2003/05/soap-envelope" xmlns:wsmid="http://schemas.dmtf.org/wbem/wsman/identity/1/wsmanidentity.xsd"&gt;&lt;s:Header/&gt;&lt;s:Body&gt;&lt;wsmid:Identify/&gt;&lt;/s:Body&gt;&lt;/s:Envelope&gt;'

  To check winrm with authentication:
  curl --header "Content-Type: application/soap+xml;charset=UTF-8" --insecure https://<ip-address>:5986/wsman --basic  -u opc:password --data '&lt;s:Envelope xmlns:s="http://www.w3.org/2003/05/soap-envelope" xmlns:wsmid="http://schemas.dmtf.org/wbem/wsman/identity/1/wsmanidentity.xsd"&gt;&lt;s:Header/&gt;&lt;s:Body&gt;&lt;wsmid:Identify/&gt;&lt;/s:Body&gt;&lt;/s:Envelope&gt;'

  Using winrm-cli from https://github.com/masterzen/winrm-cli that uses same underlying library that Terraform uses: https://github.com/masterzen/winrm
  ./winrm -hostname <ip-address> -username "opc" -password "password" -https -insecure "ipconfig /all"

  The winrm Go library uses BasicAuth, please refer to the cloudinit.yml to configure winrm with that option otherwise you may get a http response error

  Because runcmd and script are not yet supported via #cloud-config in the above images, one can use #ps1_sysnative to change password and configure winrm with a https listener

  When using your own images:
  You may alternatively prepare your images by configuring winrm using the same commands as listed in cloudinit.yml

  winrm quickconfig
  Enable-PSRemoting

  winrm set winrm/config/client/auth '@{Basic="true"}'
  winrm set winrm/config/service/auth '@{Basic="true"}'
  winrm set winrm/config/service '@{AllowUnencrypted="true"}'
  winrm set winrm/config/winrs '@{MaxMemoryPerShellMB="300"}'
  winrm set winrm/config '@{MaxTimeoutms="1800000"}'

  netsh advfirewall firewall add rule name="WinRM HTTP" protocol=TCP dir=in profile=any localport=5985 remoteip=any localip=any action=allow
  netsh advfirewall firewall add rule name="WinRM HTTPS" protocol=TCP dir=in profile=any localport=5986 remoteip=any localip=any action=allow

  net stop winrm
  sc.exe config winrm start=auto
  net start winrm
*/

# If your image does not have winrm enabled, please follow steps above to configure it
# The remote_exec-windows resource will only execute if this is set to true
variable "is_winrm_configured_for_image" {
  default = "true"
}

# Use the https 5986 port for winrm by default
# If that fails with a http response error: 401 - invalid content type, the SSL may not be configured correctly
# In that case you can switch to http 5985 by setting this to false, and configuring winrm to AllowUnencrypted traffic
variable "is_winrm_configured_for_ssl" {
  default = "true"
}

### Initialize instance1
resource "null_resource" "wait_for_cloudinit1" {
  count         = var.is_winrm_configured_for_image == "true" ? 1 : 0
  depends_on = [
    oci_core_instance.instance1
  ]


  # WinRM configuration through cloudinit may not have completed and password may not have changed yet, so sleep before doing remote-exec
  # WinRM configuration through cloudinit may not have completed and password may not have changed yet, so sleep before doing remote-exec
  provisioner "local-exec" {
    command = "sleep 60"
  }
}

resource "null_resource" "remote-exec-windows1_1" {
  # Although we wait on the wait_for_cloudinit resource, the configuration may not be complete, if this step fails please retry
  depends_on = [
    oci_core_instance.instance1,
    null_resource.wait_for_cloudinit1,
  ]

  # WinRM connections via Terraform are going to fail if it is not configured correctly as mentioned in comment section above
  count = var.is_winrm_configured_for_image == "true" ? 1 : 0

  provisioner "file" {
    connection {
      type     = "winrm"
      agent    = false
      timeout  = "1m"
      host     = oci_core_instance.instance1.public_ip
      user     = data.oci_core_instance_credentials.instance_credentials1.username
      password = var.instance_password
      port     = var.is_winrm_configured_for_ssl == "true" ? 5986 : 5985
      https    = var.is_winrm_configured_for_ssl
      insecure = "true" #self-signed certificate
    }

    source      = "userdata/App.zip"
    destination = "C:/Temp"
  }

  provisioner "file" {
    connection {
      type     = "winrm"
      agent    = false
      timeout  = "30m"
      host     = oci_core_instance.instance1.public_ip
      user     = data.oci_core_instance_credentials.instance_credentials2.username
      password = var.instance_password
      port     = var.is_winrm_configured_for_ssl == "true" ? 5986 : 5985
      https    = var.is_winrm_configured_for_ssl
      insecure = "true" #self-signed certificate
    }

    source      = "userdata/deployapp.ps1"
    destination = "c:/deployapp.ps1"
  }
}

resource "null_resource" "remote-exec-windows1_2" {
  # Although we wait on the wait_for_cloudinit resource, the configuration may not be complete, if this step fails please retry
  depends_on = [
    null_resource.remote-exec-windows1_1,
  ]
  provisioner "remote-exec" {
    connection {
      type     = "winrm"
      agent    = false
      timeout  = "30m"
      host     = oci_core_instance.instance1.public_ip
      user     = data.oci_core_instance_credentials.instance_credentials1.username
      password = var.instance_password
      port     = var.is_winrm_configured_for_ssl == "true" ? 5986 : 5985
      https    = var.is_winrm_configured_for_ssl
      insecure = "true" #self-signed certificate
    }

    inline = [
      "powershell.exe -file c:/deployapp.ps1",
    ]
  }
}

### Initialize instance2
resource "null_resource" "wait_for_cloudinit2" {
  depends_on = [
    oci_core_instance.instance2,
  ]

  count = var.is_winrm_configured_for_image == "true" ? 1 : 0

  # WinRM configuration through cloudinit may not have completed and password may not have changed yet, so sleep before doing remote-exec
  # WinRM configuration through cloudinit may not have completed and password may not have changed yet, so sleep before doing remote-exec
  provisioner "local-exec" {
    command = "sleep 60"
  }
}

resource "null_resource" "remote-exec-windows2_1" {
  # Although we wait on the wait_for_cloudinit resource, the configuration may not be complete, if this step fails please retry
  depends_on = [
    oci_core_instance.instance2,
    null_resource.wait_for_cloudinit2,
  ]

  # WinRM connections via Terraform are going to fail if it is not configured correctly as mentioned in comment section above
  count = var.is_winrm_configured_for_image == "true" ? 1 : 0

  provisioner "file" {
    connection {
      type     = "winrm"
      agent    = false
      timeout  = "30m"
      host     = oci_core_instance.instance2.public_ip
      user     = data.oci_core_instance_credentials.instance_credentials2.username
      password = var.instance_password
      port     = var.is_winrm_configured_for_ssl == "true" ? 5986 : 5985
      https    = var.is_winrm_configured_for_ssl
      insecure = "true" #self-signed certificate
    }

    source      = "userdata/App.zip"
    destination = "C:/Temp"
  }

  provisioner "file" {
    connection {
      type     = "winrm"
      agent    = false
      timeout  = "30m"
      host     = oci_core_instance.instance2.public_ip
      user     = data.oci_core_instance_credentials.instance_credentials2.username
      password = var.instance_password
      port     = var.is_winrm_configured_for_ssl == "true" ? 5986 : 5985
      https    = var.is_winrm_configured_for_ssl
      insecure = "true" #self-signed certificate
    }

    source      = "userdata/deployapp.ps1"
    destination = "c:/deployapp.ps1"
  }
}

resource "null_resource" "remote-exec-windows2_2" {
  # Although we wait on the wait_for_cloudinit resource, the configuration may not be complete, if this step fails please retry
  depends_on = [
    null_resource.remote-exec-windows2_1,
  ]
  provisioner "remote-exec" {
    connection {
      type     = "winrm"
      agent    = false
      timeout  = "30m"
      host     = oci_core_instance.instance2.public_ip
      user     = data.oci_core_instance_credentials.instance_credentials2.username
      password = var.instance_password
      port     = var.is_winrm_configured_for_ssl == "true" ? 5986 : 5985
      https    = var.is_winrm_configured_for_ssl
      insecure = "true" #self-signed certificate
    }

    inline = [
      "powershell.exe -file c:/deployapp.ps1",
    ]
  }
}

