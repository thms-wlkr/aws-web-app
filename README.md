# AWS Three-Tier Web Application Deployment with Terraform

This project demonstrates the deployment of a three-tier web application using Terraform to provision and manage the infrastructure. The architecture comprises a presentation tier, an application tier, and a data tier, ensuring a scalable, secure, and highly available system.

## Providers Configuration
- **AWS Provider:** Configures AWS as the cloud provider with the necessary version and region settings.

## Network Configuration
- **VPC and Subnets:** Creates a VPC with public and private subnets distributed across availability zones, ensuring isolation and high availability.
- **Internet Gateway and NAT Gateways:** Configures an Internet Gateway for public subnets and NAT Gateways for private subnets to manage inbound and outbound traffic.
- **Route Tables:** Sets up route tables for directing traffic within the VPC, including routes for Internet and NAT Gateways.

## Security Configuration
- **Security Groups:** Defines security groups for controlling inbound and outbound traffic, allowing HTTP, HTTPS, and SSH access to the web servers and backend communication.

## Compute Resources
- **Frontend (EC2 Instances and Auto Scaling):** Deploys web servers using EC2 instances and an Auto Scaling Group to handle varying loads. Includes a load balancer for distributing traffic across instances.
- **Backend (EC2 Instances and Auto Scaling):** Sets up backend servers in private subnets with their own Auto Scaling Group for processing application logic.

## Database Configuration
- **RDS Instance:** Provisions a MySQL database in the private subnet for storing persistent application data.

## Content Delivery and Security
- **CloudFront Distribution:** Configures a CloudFront distribution for caching and delivering content globally with improved performance.
- **WAF (Web Application Firewall):** Implements a WAF to protect the CloudFront distribution from common web exploits.

## Key Features
- **Scalability:** Auto Scaling Groups ensure the application can handle increased traffic by dynamically adjusting the number of instances.
- **High Availability:** Resources are distributed across multiple availability zones, ensuring uptime and reliability.
- **Security:** Security groups, IAM roles, and WAF provide robust security measures to protect the infrastructure and application.
- **Performance:** CloudFront enhances performance by caching content at edge locations closer to users.

By leveraging Terraform's Infrastructure as Code (IaC) capabilities, the entire setup is defined, provisioned, and managed programmatically, ensuring consistency, version control, and ease of maintenance.
