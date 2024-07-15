variable "ami" {
    description= "Amazon machine image to use for ec2 instance"
    type= string
    default= "ami-0314c062c813a4aa0" #debian
}

variable "instance_type" {
    description = "ec2 instance type"
    type = string
    default = "t2.micro"
}

variable "region" {
    description= "Server region"
    type = string
    default = "eu-west-3"
}

variable "bucket_name"{
    type = string
    default = "example-bucket-fjjdxq3o90p"
}
