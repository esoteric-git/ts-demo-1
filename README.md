# Tailscale Demo - Zero-Config VPN with AWS

This project demonstrates Tailscale's zero-config VPN capabilities by showing how to securely access a private AWS instance without complex networking configurations.

## Project Objective

Showcase Tailscale's ability to enable secure connectivity to a private, isolated instance within a VPC. The demo uses Tailscale to access a non-Tailscale device in AWS through a subnet router, with minimal AWS network configuration.

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

## Demo Flow

### 1. Initial Access
After deployment, you can SSH into vm-2 (private instance) through vm-1 (subnet router): 