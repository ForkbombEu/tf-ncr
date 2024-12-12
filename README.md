# Open Tofu AWS ncr Example

This repository provides a real-world example of using Open Tofu to deploy a basic infrastructure setup on AWS, including an EC2 instance running an ncr service and an S3 bucket.

## Prerequisites

- [Open Tofu](https://opentofu.org/docs) installed
- [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html) installed
- AWS CLI configured with your credentials (see section below)
- A VPC ID where the security group will be created
- An AMI ID for the EC2 instance
- ncr service binary uploaded to an S3 bucket
- ZenCode smart contracts to be stored in an S3 bucket (ask andrea)

### User and group setup
From Console Home: 
search "IAM" (IAM -Manage access to AWS resources ) 
- Create a user 
- Create a user group and assign the user the permissions: 
  *  IAMFullAccess 
  *  AmazonEC2FullAccess 
  *  AmazonS3FullAccess 
  *  AmazonEC2ContainerRegistryPowerUser 
  *  EC2ContainerRegistryFullAccess

- Add the user to the user group (make sure it's added)
- In the user page, click "Create access key" and then "Command Line Interface (CLI)"
- Download .csv

### Configure the AWS CLI

https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-configure.html

Configure the AWS CLI (points 3 to 8), using the config file by running:

`aws configure` 

The command writes the files:  _~/.aws/credentials_  and  _~/.aws/config_

## Getting Started

1. **Clone this repository**

   ```sh
   git clone https://github.com/ForkbombEu/tf-ncr.git
   cd tf-ncr
   ```


1. **Intro and setup (optional)**

   - You can configure ami, bucket_name, public_key_path and user_data path modifying the *terraform.tfvars* file, otherwise default setting will be applied.
   - The port 52760 is used in [pipe-tf-ncr](https://github.com/ForkbombEu/pipe-tf-ncr/) (ancillary to [DIDroom_microservices](https://github.com/ForkbombEu/DIDroom_microservices) and can otherwise be closed in *main.tf*



1. **Create ssh key to connect to the ec2 instance**
   ```sh
   ssh-keygen -t ed25519 -C "myEDDSAkeyForAWS" -f ./myED25519Key
   chmod 700 ./myED25519Key
   ```

1. **Deploy onto AWS EC2**
   ```sh
   cd openTofuCode/
   tofu init
   tofu apply # use 'tofu apply -var="create_key_pair=false"' to not add ssh key
   ```
   

1. **Deploy onto AWS EC2 excluding SSH pubkey (EC2 -> AMI)**
   Use this commands if you want to create an AMI, to be used by 3rd parties, from the EC2: the EC2 instance must be created without embedding a pubkey for SSH access. The SSH network won't be affected.
    
   ```sh
   cd openTofuCode/
   tofu apply -var="create_key_pair=false" 
   ```
   Notice: when using this line, a pubkey to login via SSH must be configured using the AWS dashboard. 
   
## Functionalities
Ater some minutes, once infrustructure is fully deployed, the previous script **should return the IP and URL** of the AWS ec2 instance you just created, then you can:

1. **Connect via ssh as admin**
   
   Navigate to the folder tf-ncr/ and use ssh (note: *assignedIP* can be the IP or the URL of the AWS ec2 instance produced by OpenTofu)
    ```sh
    cd ..
    ssh -i ./myED25519Key admin@assignedIP
    ```

1. **Visualize the ncr service documentation web page via http**

   Write in your browser the url http://assignedIP:8080/docs or http://domainName:8080/docs

Note: you can find the assignedIP or the domainName to witch the IP is associated in your AWS ec2 instances page or in output variables after "terraform apply" comand

## How to stop deployment
   ```sh
   cd openTofuCode/
   tofu destroy
   ```

Notice: Errors may occure if configuration is changed and applyed whitout before destroying. If problems occure try destroy before init and apply.
