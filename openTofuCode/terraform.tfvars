ami = "ami-0314c062c813a4aa0"				# this is the base image (Linux something), that will be used to deploy the EC2
bucket_name = "example-bucket-ujjdxq3oo9z"	# debug: this should be generated randomly every 'tofu apply'
public_key_path= "./../myED25519Key.pub"	# the pubkey used to access via SSH
user_data= "./../user-data.sh"				# the provisioning of the EC2 and NCR 
