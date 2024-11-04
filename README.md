# Django Developer Demo - Zero-Config VPN with IaC in AWS

This project demonstrates:
- Infrastructure as Code using Terraform to rapidly deploy
- A Django application with multiple EC2 instances within a VPC in AWS
- Enable seamless developer access to the application using Tailscale's zero-config VPN (tailnet), subnet router, and SSH

## Project Objective

Showcase Terraform's ability to rapidly deploy AWS infrastructure and Tailscale's ability to enable secure connectivity to a private, isolated instance within a VPC. The demo uses Tailscale to access a non-Tailscale device in AWS through a subnet router, with minimal AWS network configuration.

## Prerequisites

### Required Software
- Terraform installed on your laptop
- Tailscale client installed and connected to your Tailnet
- Git for cloning this repository

### Required Accounts
- AWS Account with permissions to create:
  - VPC and associated networking resources
  - EC2 instances
  - Security Groups
- Tailscale Account

## Quick Start

1. **Clone the Repository**
   ```bash
   git clone <repository-url>
   cd ts-demo-1
   ```

2. **Create Environment File**
   
   Create a `.env` file in the project root with your credentials:
   ```bash
   AWS_ACCESS_KEY_ID="your-aws-access-key"
   AWS_SECRET_ACCESS_KEY="your-aws-secret-key"
   TF_VAR_tailscale_auth_key="tskey-auth-xxxxx"
   ```

3. **Load Environment Variables**
   ```bash
   source .env
   ```

4. **Deploy Infrastructure**
   ```bash
   terraform init
   terraform apply
   ```

## Flow

### 1. Access
- After deployment, you can ping vm-2 (private instance) even though its completely isolated within the VPC, the ping is routed through vm-1 (subnet router)
- You can SSH directly into vm-1 without ssh keys (tailscale ssh)
- You can access the Django app directly through the tailnet even though the VPC allows no inbound traffic to the instances