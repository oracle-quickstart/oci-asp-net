# NOTE - tenancy_id is not defined here.  it is defined in each environment file.
# This is specifically done since there are variables tied to the actual tenancy in the environment files.
# If you need to update a stack, this file must be for a user in the tenancy listed in the environment file.

### Authentication details
tenancy_ocid =  "ocid1.tenancy.oc1..aaaaaaaawgbzspd6cjovpmic7dahwbalg4opcbixgguo6z2s7t335m6lalbq" 
user_ocid = "ocid1.user.oc1..aaaaaaaakbm65mctre4i4wom6sam6z4amtjc5vin3iqsa4z3bzpdvoaieioq" 
fingerprint = "04:25:17:8c:0c:e7:f0:9b:c6:14:c2:15:06:e7:66:c1"
private_key_path = "/home/runner/.oci/key.pem"

### Region
region = "us-phoenix-1"

### Compartment
compartment_ocid = "ocid1.compartment.oc1..aaaaaaaagxh5kocy6g6of5znwe35ckxn6ddkdqwoif7qjcx3igm2fareke2q"
