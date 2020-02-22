# How to create oracle Autonomous Database using Terraform

## Generate ssh key pair

I am using Windows 10 and installed GIT Bash.

open Git Bash and run below command:

`ssh-keygen`

And accpet all defaults

## Create new OCI Compute instance from OCI Console
Need to provide the public ssh key(id_rsa.pub) while creating the instance.
Select root compartment from left before creating instance. And select root compartment for VCN also.
Once instance is created successfully, note down the public IP of the instance and login using ssh.

###Login to OCI compute instance

`ssh -i id_rsa opc@PUBLIC_IP_ADDRESS`

##Generate API Key

From the OCI compute box, create API key pair. And add public key using OCI console.
Refer : https://docs.cloud.oracle.com/iaas/Content/API/Concepts/apisigningkey.htm

`mkdir ~/api-keys`
`cd ~/api-keys`

`openssl genrsa -out ./oci_api_key.pem 2048`
`chmod 0700 ../api-keys/`
`chmod 0600 ./oci_api_key.pem`

Generate the public key:
`openssl rsa -pubout -in ./oci_api_key.pem -out ./oci_api_key_public.pem`

#You can get the key's fingerprint with the following OpenSSL command. 
`openssl rsa -pubout -outform DER -in ./oci_api_key.pem | openssl md5 -c`

#SAVE FINGERPRINT TO FILE
`openssl rsa -pubout -outform DER -in ./oci_api_key.pem | openssl md5 -c > ./oci_api_key_fingerprint`

#remove the first part - (stdin)=
copy the contents of oci_api_key_public.pem to the clipboard. `




###Add public key using OCI Console

Add the public key under Identity > User > API Key section.

There are two users created ootb. 
1) oracleidentitycloudservice/USER_EMAID_ID where provider is OracleIdentityCloudService 
2) USER_EMAID_ID

Add the key under user 2) > API Keys section

`cat oci_api_key_public.pem` 
And add the content of above file as API Key.

## Upload ssh keys from Windows box to OCI compute instance
Open Git Bash from Windows
cd .ssh

upload id_rsa and id_rsa.pub files using scp

`scp -i id_rsa id_rsa* opc@OCI_COMPUTE_INSTANCE_PUBLIC_IP:~/`

Above step will upload id_rsa and id_rsa.pub to oci compute host. Replace OCI_COMPUTE_INSTANCE_PUBLIC_IP with the public IP address of the oci compute instance.

## Install terraform and terraform oci provider

`sudo yum install -y terraform terraform-provider-oci`

## Clone atp-example github repo

`git clone https://github.com/rajivkuriakose/atp-example.git`


## Prepare env vars 

cd atp-example

Edit env-vars 

###Authentication details
#Update below variables with ocids for your trial account
export TF_VAR_tenancy_ocid="<renancy ocid here>"
export TF_VAR_user_ocid="<user ocid here>"
export TF_VAR_fingerprint="<fingerprint here>"
export TF_VAR_private_key_path="~/api-keys/oci_api_key.pem"

###Region
#change this if your account is in a different region
export TF_VAR_region=us-ashburn-1

###Compartment
#Here I am using the root compartment, thought this is not the recommended approach
export TF_VAR_compartment_ocid="<compartment ocid here>"

###API Keys - Public/private keys used on the instance
export TF_VAR_ssh_public_key=$(cat ~/ssh-keys/id_rsa.pub)
export TF_VAR_ssh_private_key=$(cat ~/ssh-keys/id_rsa)

Now source the env-vars

`source env-vars`

verify the env vars are set as expected.

`export | grep TF_VAR | less -SXE`

## Run Terraform

`terraform init`

This will create .terraform folder under current working directory. Also creates ~/.terraform.d folder.

`terraform plan`

`terraform apply`

This will take several minutes to complete. After that the command will print out the ATP service and ATP wallet details.


## Login to ATP instance service console

The service console URL is printed in the output. And the ATP instance password(generated by previous step) is also printed. You can change this password after logging in to service console.

username : admin
password : <use the password displayed in the terraform apply cmd output>
  
To view ATP instance details:

`terraform state list`
`terraform state show oci_database_autonomous_database.autonomous_database`



Finally to destroy the ATP instance
`terraform destroy`






