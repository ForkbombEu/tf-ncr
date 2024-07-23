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

1. **Clone the repository**

   ```sh
   git clone https://github.com/ForkbombEu/tf-ncr.git
   cd tf-ncr
   
2. **Create ssh key to connect to the ec2 instance**
   ```sh
   ssh-keygen -t rsa -b 2048 -C "noOwnerName" -f ./testRsaKey
   chmod 700 ./testRsaKey

3. **Deploy infrastructure on aws**
   ```sh
   cd openTofuCode/
   tofu init
   tofu apply
   ```
   Notice: you can configure ami, bucket_name, public_key_path and user_data path modifying terraform.tfvars file. Otherwise default setting will be applied
   
## Functionalities
Ater some minutes, once infrustructure is fully deployed, you can:

1. **Connect via ssh as admin**
   
   Navigate to the folder tf-ncr/ and use ssh
    ```sh
    cd ..
    ssh -i ./testRsaKey admin@assignedIP
    ```

2. **Visualize the ncr service documentation web page via http**

   Write in your browser the url http://assignedIP:8080/docs or http://domainNaim:8080/

Note: you can find the assignedIP or the domainNaim to witch the IP is associated in your aws ec2 instances page or in output variables after "terraform apply" comand

## How to stop deployment
   ```sh
   cd openTofuCode/
   tofu destroy
   ```

Notice: Errors may occure if configuration is changed and applyed whitout before destroying. If problems occure try destroy before init and apply.
