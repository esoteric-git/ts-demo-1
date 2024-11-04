# Demo - Django Developer with Zero-Config VPN Access to AWS

## Project Objective
### Demonstrate The Following Developer Use Case:

- Infrastructure as Code using Terraform to rapidly deploy a Django application with multiple EC2 instances within a new VPC in AWS. 

- Automated Tailscale configuration to enable seamless developer access to the application despite restrictive VPC settings by using 3 Tailscale features:
  - Tailnet (zero-config VPN for remote access)
  - Subnet router (routes traffic between non-tailscale devices in the VPC and the tailnet)
  - SSH (easy SSH access without managing keys)


## Project Architecture
![Project Architecture](./images/architecture.png)

### AWS VPC Security

- The VPC demonstrates common security constraints developers encounter in enterprise AWS environments:
  - Private subnets with no direct internet access
  - Restricted or no inbound traffic allowed to application servers
  - Need to access development/test environments through bastion hosts or VPNs

- The private subnet has no direct internet connectivity (no NAT gateway) and can only communicate externally through the subnet router (vm1)

- The public subnet has no inbound traffic allowed and unrestricted outbound traffic through the Internet Gateway, so it can reach the Tailscale network

### Django Application

- A Django application is included in this demo to demonstrate a real-world use case where a developer could easily setup remote access to write code and test applications running in a typical VPC setup without the usual hassles.

- Terraform is showcased as a way to automate the entire deployment and startup of the demo Django application located at: https://github.com/esoteric-git/django-app.git by cloning it into the EC2 instance and running the commands to install dependencies, seed the database, and run the application.

- The Django application is configured to run on port 8000 and will be accessible through the tailnet name (http://ts-demo-django:8000)

## Prerequisites

### Required Software On Your Local Machine

- Terraform installed 
- Tailscale client installed and connected to your Tailnet
- Git for cloning this repository

### Required Accounts

- AWS Account with permissions to create:
  - VPC and associated networking resources
  - EC2 instances
  - Security Groups

- Tailscale Account

## Setup Project And Deploy Infrastructure

1. **Clone the Repository**
   ```bash
   git clone https://github.com/esoteric-git/ts-demo-1.git
   cd ts-demo-1
   ```

2. **Create Environment File**
   
   Copy the `.env.example` file to `.env` and populate with your credentials:
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

## Developer Workflow

### Confirming Terraform Deployment

- Note the outputs from the terraform deployment in the terminal:
  - vm1_public_ip
  - vm2_private_ip
  - django_vm_public_ip

- Confirm the VPC, Subnet, and EC2 instances were created in the AWS Console

- Confirm vm1 and django-vm are visible in Tailscale > Machines

- Click on vm1 and confirm the subnet router is enabled

### Testing Remote Access From Local Machine

- After confirming the deployment, you can ping vm-2's private IP (instance in the private subnet) despite vm-2 having no direct internet connectivity. The ping is routed through vm-1 which is acting as a Tailscale subnet router.

- You can SSH into vm-1 and the django instance with no need for traditional SSH keys or open ports because Tailscale SSH is enabled on the instances.

- You can browse directly to the Django app using its tailnet name (http://ts-demo-django:8000) despite the VPC security groups having no inbound rules, because its on the same tailnet.

- If you disconnect your local Tailscale client, you will not be able to access any of the AWS instances, thus demonstrating the reliance on the remote access functionality.
