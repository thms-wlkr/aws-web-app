# AWS Three-Tier Web Application Deployment with Terraform

This project showcases the deployment of a three-tier web application using Terraform for infrastructure provisioning and management. The architecture consists of distinct tiers—presentation, application, and data—designed for scalability, security, and high availability.

## Providers Configuration
- **AWS Provider:** Configures AWS as the cloud provider with specified version and region settings.

## Network Configuration
- **VPC and Subnets:** Creates a Virtual Private Cloud (VPC) with public and private subnets distributed across multiple availability zones for isolation and high availability.
- **Internet Gateway and NAT Gateways:** Sets up an Internet Gateway for public subnets and NAT Gateways for private subnets, managing inbound and outbound traffic efficiently.
- **Route Tables:** Defines route tables to direct internal traffic within the VPC, including routes for Internet and NAT Gateways.

## Security Configuration
- **Security Groups:** Implements security groups to control inbound and outbound traffic, permitting HTTP, HTTPS, and SSH access to web servers and enabling secure backend communication.

## Compute Resources
- **Frontend (EC2 Instances and Auto Scaling):** Deploys web servers using EC2 instances and Auto Scaling Groups to handle variable workloads. Includes a load balancer for efficient traffic distribution.
- **Backend (EC2 Instances and Auto Scaling):** Sets up backend servers in private subnets with dedicated Auto Scaling Groups for processing application logic securely.

## Database Configuration
- **RDS Instance:** Provisions a MySQL database instance in the private subnet for storing persistent application data securely.

## Content Delivery and Security
- **CloudFront Distribution:** Configures a CloudFront distribution to cache and deliver content globally, improving performance by reducing latency.
- **WAF (Web Application Firewall):** Implements a Web Application Firewall (WAF) to protect the CloudFront distribution from common web exploits.

## Key Features
- **Scalability:** Auto Scaling Groups dynamically adjust the number of instances based on traffic demands, ensuring optimal performance under varying loads.
- **High Availability:** Resources are distributed across multiple availability zones, ensuring uptime and reliability of the application.
- **Security:** Security groups, IAM roles, and WAF provide robust security measures to safeguard both infrastructure and application data.
- **Performance:** CloudFront enhances application performance by caching content at edge locations closer to users, reducing latency and improving user experience.

By leveraging Terraform's Infrastructure as Code (IaC) capabilities, this project achieves consistent, version-controlled infrastructure deployment and maintenance, enhancing operational efficiency and scalability.
