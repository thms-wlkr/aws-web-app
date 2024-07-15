# AWS Three-Tier Web Application Deployment with Terraform

This project demonstrates the deployment of a three-tier web application using Terraform to provision and manage the infrastructure. The architecture comprises a presentation tier, an application tier, and a data tier, ensuring a scalable, secure, and highly available system.

## Pre-requisite:
- An S3 Bucket to store the Terraform state file.

## Providers Configuration
- **AWS Provider:** Configures AWS as the cloud provider with the necessary version and region settings.

## Network Configuration
- **VPC and Subnets:** Sets up a VPC (`aws_vpc.vpc`) with public and private subnets distributed across availability zones (`data.aws_availability_zones.available`). This ensures isolation and high availability for different application tiers.
- **Internet Gateway and NAT Gateways:** Configures an Internet Gateway (`aws_internet_gateway.internet_gw`) for public subnets and NAT Gateways (`aws_nat_gateway.nat_gateway_1`, `aws_nat_gateway.nat_gateway_2`) for private subnets to manage inbound and outbound traffic securely.
- **Route Tables:** Establishes route tables (`aws_route_table.public_route_table`, `aws_route_table.private_route_table`) to direct traffic within the VPC, including routes for Internet access and NAT Gateways.

## Security Configuration
- **Security Groups:** Defines security groups (`aws_security_group.public_sg`, `aws_security_group.backend_sg`) to control inbound and outbound traffic. Allows HTTP, HTTPS, and SSH access as per application requirements.

## Compute Resources
- **Frontend (EC2 Instances and Auto Scaling):** Deploys web servers using EC2 instances (`aws_instance.web_server`) and an Auto Scaling Group (`aws_autoscaling_group.web_asg`) to handle varying loads. Includes a load balancer (`aws_lb.app_lb`) for distributing traffic across instances.
- **Backend (EC2 Instances and Auto Scaling):** Sets up backend servers in private subnets using an Auto Scaling Group (`aws_autoscaling_group.backend_asg`) for processing application logic. Instances are launched from a launch template (`aws_launch_template.backend_template`) configured for backend operations.

## Database Configuration
- **RDS Instance:** Provisions a MySQL database (`aws_db_instance.rds_instance`) in a private subnet (`aws_db_subnet_group.db_subnet_group`) for storing persistent application data securely.

## Content Delivery and Security
- **CloudFront Distribution:** Configures a CloudFront distribution (`aws_cloudfront_distribution.cf_distribution`) for caching and delivering content globally, enhancing application performance.
- **WAF (Web Application Firewall):** Implements a WAF (`aws_wafv2_web_acl.web_acl`) to protect the CloudFront distribution from common web exploits, ensuring robust security measures.

## Key Features
- **Scalability:** Auto Scaling Groups dynamically adjust the number of instances based on traffic demands, ensuring the application can handle increased load effectively.
- **High Availability:** Resources are distributed across multiple availability zones (`data.aws_availability_zones.available`), ensuring uptime and reliability.
- **Security:** Security groups (`aws_security_group`) and WAF provide comprehensive security measures to protect both the infrastructure and application data.
- **Performance:** CloudFront accelerates content delivery by caching data at edge locations closer to users, enhancing overall application performance.

By leveraging Terraform's Infrastructure as Code (IaC) capabilities, the entire infrastructure setup is defined, provisioned, and managed programmatically. This approach ensures consistency, version control, and ease of maintenance throughout the deployment lifecycle.
