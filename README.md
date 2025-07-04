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


1. **Deploy onto AWS EC2 without SSH access (EC2 -> AMI)**
   Use this commands if you want to create an AMI, to be used by 3rd parties, from the EC2: the EC2 instance must be created without embedding a pubkey for SSH access. The SSH network won't be affected.
   
   ```sh
   make deploy SSH=n NewPKey=n # ContractsURL=https://github../tf-pqcrypto-scripts
   ```
   

1. **Deploy onto AWS EC2 with SSH access**
   
   ```sh
   make deploy SSH=y NewPKey=y
   ```

   If you already have a public key or you created one (via `ssh-keygen -t ed25519 -C "myEDDSAkeyForAWS" -f ./myED25519Key && chmod 700 ./myED25519Key`) then you can place it in the makefile folder and use
   
   ```sh
   make deploy SSH=y NewPKey=n
   ```

   The default deployed services are https://github.com/ForkbombEu/tf-pqcrypto-scripts if you want to change it use the parameter `ContractsURL` and specify a different github with contracts:

   ```sh
   make deploy SSH=y NewPKey=n ContractsURL=someGithubUrlWithAZenroomContratsFolder 
   ```

   
## Functionalities
After some minutes, once infrastructure is fully deployed, the previous script **should return the IP and DNS** of the AWS ec2 instance you just created, then you can:

1. **Connect via ssh as admin**
   
   Navigate to the folder tf-ncr/ and use ssh (note: *assignedIP* can be the IP or the URL of the AWS ec2 instance produced by OpenTofu)
    ```sh
    ssh -i ./myED25519Key admin@assignedIP # or admin@assignedDNS
    ```

1. **Visualize the ncr service documentation web page via http**

   Write in your browser the url http://assignedIP:8080/docs or http://domainName:8080/docs

Note: you can find the assignedIP or the domainName to witch the IP is associated in your AWS ec2 instances page or in output variables after "terraform apply" command

## How to stop deployment
   ```sh
   make destroy
   ```

Notice: Errors may occur if configuration is changed and applied without before destroying. If problems occur try destroy before deploying again.

## Getting Started (Google Cloud Platform)

1. **Clone this repository**

   ```sh
   git clone https://github.com/ForkbombEu/tf-ncr.git
   cd tf-ncr
   ```

2. **Checkout into gcp branch**

   ```sh
   git checkout gcp
   ```

3. **Move into openTofuCodeGCP directory**

   ```sh
   cd openTofuCodeGCP
   ```

4. **Obtain GCP credentials and store them into a .json file**

5. **Obtain Gandi token and store it into terraform.tfvars**

   ```sh
   gandi_token = "your_gandi_token"
   ```

6. **Make changes accordingly to variables.tf file**

   ```sh
   variable "credentials_file" {
      default = "/absolute/path/to/your/credentials/file.json"
   }

   variable "ssh_user" {
      description = "Username for SSH access"
      type        = string
      default     = "your-local-username"
   }

   variable "ssh_pub_key_path" {
      description = "Path to your local public SSH key"
      type        = string
      default     = "~/.ssh/id_rsa.pub" # default path
   }
   ```

7. **Run tofu**

   ```sh
   tofu init
   tofu plan
   tofu apply
   ```