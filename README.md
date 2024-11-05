# Infrastructure Deployment with Terraform

This project sets up a basic infrastructure on AWS using Terraform. It provisions a VPC, an S3 bucket for static content, a load-balanced web application with an autoscaling group, and a CloudFront distribution to serve the content securely.

## Table of Contents
- [Overview](#overview)
- [Architecture](#architecture)
- [Resources](#resources)
- [Getting Started](#getting-started)
- [Usage](#usage)
- [Outputs](#outputs)
- [Clean Up](#clean-up)

## Overview
This project uses Terraform to automate the provisioning of cloud resources needed to run a highly available web application. The infrastructure includes:
- A Virtual Private Cloud (VPC) with public subnets.
- A Load Balancer (ELB) for distributing requests.
- An Auto Scaling Group (ASG) for ensuring the application is highly available.
- An S3 bucket to store and serve static content via CloudFront.

## Architecture
The deployed architecture consists of:
- **VPC and Subnets**: A VPC with 3 public subnets across availability zones for redundancy.
- **Load Balancer**: An application load balancer (ALB) to distribute incoming HTTP traffic to web servers.
- **Auto Scaling Group**: Automatically scales EC2 instances as needed to handle load.
- **S3 Bucket with CloudFront CDN**: S3 bucket configured to serve static content through CloudFront.

## Resources
Below is a summary of the main resources managed by this Terraform configuration:

### VPC Configuration
- **VPC (`aws_vpc.default_vpc`)**: Creates a new VPC for isolating resources.
- **Subnets (`aws_subnet.default_subnet`)**: Creates 3 public subnets.
- **Internet Gateway (`aws_internet_gateway.default_igw`)**: Allows internet access for resources.

### S3 and CloudFront
- **S3 Bucket (`aws_s3_bucket.static_content`)**: Stores static content.
- **CloudFront Distribution (`aws_cloudfront_distribution.cdn`)**: Delivers content from both the S3 bucket and load balancer.

### Load Balancer and Auto Scaling
- **Load Balancer (`aws_lb.web_app_lb`)**: Public load balancer to handle incoming web traffic.
- **Target Group (`aws_lb_target_group.web_app_tg`)**: Routes incoming requests to healthy instances.
- **Launch Template (`aws_launch_template.app_lt`)**: Configures EC2 instances.
- **Auto Scaling Group (`aws_autoscaling_group.web_app_asg`)**: Maintains the desired number of instances.

### Security Group and Network
- **Security Group (`aws_security_group.web_app_sg`)**: Controls inbound and outbound traffic for web servers.
- **Route Table (`aws_route_table.default_rt`)**: Manages routing for subnets in the VPC.

## Getting Started
To get started with this project, you will need:
1. **Terraform** installed. If you don't have it, you can download it from [https://www.terraform.io/downloads.html](https://www.terraform.io/downloads.html).
2. **AWS CLI** configured with your credentials and default region set to `eu-central-1`.

### Steps to Deploy
1. Clone this repository.
   ```sh
   git clone <repository-url>
   cd <repository-directory>
   ```
2. Initialize Terraform.
   ```sh
   terraform init
   ```
3. Review the plan to understand the changes Terraform will make.
   ```sh
   terraform plan
   ```
4. Apply the configuration to deploy the resources.
   ```sh
   terraform apply
   ```

## Usage
- **Access the Load Balancer URL**: Once the deployment is complete, you will receive the URL of the load balancer, which can be used to access the web application.
- **Static Content Delivery**: Static files stored in the S3 bucket will be served through the CloudFront CDN.

## Outputs
After running `terraform apply`, the following output is provided:

- **Load Balancer URL (`load_balancer_url`)**: The DNS name of the load balancer.
  ```sh
  output "load_balancer_url" {
    value = aws_lb.web_app_lb.dns_name
  }
  ```

## Clean Up
To avoid unnecessary costs, remember to destroy the infrastructure once you are done.
```sh
terraform destroy
```
This will delete all the resources created by the Terraform configuration.

## Notes
- The AWS region used in this setup is `eu-central-1`. If needed, modify the `provider.tf` file to change the region.
- The default instance type for the web application is `t2.micro`. You may adjust the instance type to suit your needs.
