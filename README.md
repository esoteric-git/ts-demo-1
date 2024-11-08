# Secure AWS Development Environment: Terraform + Tailscale Demo

[![Terraform](https://img.shields.io/badge/terraform-%235835CC.svg?style=for-the-badge&logo=terraform&logoColor=white)](https://www.terraform.io)
[![AWS](https://img.shields.io/badge/AWS-%23FF9900.svg?style=for-the-badge&logo=amazon-aws&logoColor=white)](https://aws.amazon.com)
[![Tailscale](https://img.shields.io/badge/tailscale-%23245DC1.svg?style=for-the-badge&logo=tailscale&logoColor=white)](https://tailscale.com)
[![Django](https://img.shields.io/badge/django-%23092E20.svg?style=for-the-badge&logo=django&logoColor=white)](https://www.djangoproject.com)

Demonstrate secure, frictionless deployment and access to AWS resources using Infrastructure as Code and a modern zero-configuration VPN.

---

## ⚡ QuickStart

```bash
# Prerequisites: AWS credentials, Tailscale account, and Terraform installed
git clone https://github.com/esoteric-git/ts-demo-1.git && cd ts-demo-1

# Create auth key at https://login.tailscale.com/admin/settings/keys
echo 'export TF_VAR_tailscale_auth_key="tskey-auth-xxxxx"' > .env
echo 'export AWS_ACCESS_KEY_ID="your-aws-access-key"' >> .env
echo 'export AWS_SECRET_ACCESS_KEY="your-aws-secret-key"' >> .env
source .env

# Deploy
terraform init && terraform apply -auto-approve

# Access (after Tailscale machines show connected and subnet is enabled)
ssh ec2-user@ts-demo-vm1 # Public subnet router
curl http://ts-demo-django:8000 # Public Django app
ping $(terraform output -raw vm2_private_ip) # Isolated VM in private subnet
```

For detailed setup and configuration, see [Setup Guide](#%EF%B8%8F-setup-guide).

---

## 🎯 Project Objective

This project showcases two powerful tools that streamline cloud development and access:

1. **Infrastructure as Code with Terraform**
   - Rapidly deploy AWS infrastructure
   - Automate creation of VPCs, subnets, and security groups
   - Provision and configure multiple EC2 instances

2. **Automated Setup of Secure Remote Access with Tailscale**
   - Zero-configuration VPN (Tailnet) for secure remote access
   - Subnet routing to connect isolated VPC resources to your Tailnet
   - Keyless SSH access to instances

The combination demonstrates how developers can quickly deploy cloud infrastructure and securely access it without complex VPN setups or SSH key management.

---

## 🏗️ Architecture
<p align="center">
  <img src="./images/architecture.png" width="90%" alt="Project Architecture">
</p>

---

## 🔍 Project Components

<details open>
<summary>Infrastructure Overview</summary>

- Tailnet
- VPC with public subnet (10.0.1.0/24) and private subnet (10.0.2.0/24)
- EC2 instances:
  - vm1: Public subnet, Tailscale subnet router
  - django: Public subnet, Tailscale client
  - vm2: Private subnet, accessed via subnet router
</details>

<details open>
<summary>Security Configuration</summary>

- The VPC demonstrates common security constraints developers encounter in enterprise AWS environments:
  - Private subnets with no direct internet access
  - Restricted or no inbound traffic allowed to application servers
  - Need to access development/test environments through bastion hosts or VPNs

- The private subnet 10.0.2.0/24 has no direct internet connectivity (no NAT gateway) and can only communicate externally through the subnet router (vm1)

- The public subnet 10.0.1.0/24 has no inbound traffic allowed and unrestricted outbound traffic through the Internet Gateway, so it can reach the Tailscale network
</details>

<details open>
<summary>Application Details</summary>

- A Django Web Application is included in this demo to demonstrate a real-world use case where a developer could easily setup remote access to write code and test applications running in a typical VPC setup without the usual hassles.

- Terraform is showcased as a way to automate the entire deployment and startup of the demo Django application located at: https://github.com/esoteric-git/django-app-ts.git by cloning it into the EC2 instance and running the commands to install dependencies, seed the database, and run the application.

- The Django application is configured to run on port 8000 and will be accessible through the tailnet name (http://ts-demo-django:8000)
</details>

---

## ⚙️ Setup Guide

### Prerequisites

- Terraform installed 
- Tailscale client installed and connected to your Tailnet
- Git for cloning this repository

- AWS Account with permissions to create:
  - VPC and associated networking resources
  - EC2 instances
  - Security Groups

- Tailscale Account

### Deployment Steps

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

---

## 👩‍💻 Developer Workflow

### Confirming Terraform Deployment

- Note the outputs from the terraform deployment in the terminal:
  - vm1_public_ip
  - vm2_private_ip
  - django_vm_public_ip

- Confirm the VPC, Subnet, and EC2 instances were created in the AWS Console

- In Tailscale > Machines
  - Confirm vm1 and the django vm are connected
  - Click on vm1 and confirm the subnet router is enabled
  - If subnet not enabled, click "review" and click the checkbox and save

    <img src="./images/review-subnet.png" width="200" alt="Review Subnet">

### Testing Remote Access From Local Machine

- After confirming the deployment, you can ping vm2's private IP (instance in the private subnet) despite vm2 having no direct internet connectivity. The ping is routed through vm1 which is acting as a Tailscale subnet router. Note that you can't ping vm2 by name because its not on the Tailnet.

    ```bash
    ping $(terraform output -raw vm2_private_ip)
    ```

- You can SSH into vm1 and the django instances by name or IP address with no need for traditional SSH keys or open ports because Tailscale SSH is enabled on the instances.

    ```bash
    ssh ec2-user@ts-demo-vm1
    ssh ec2-user@ts-demo-django
    ```

- You can browse directly to the Django app using its tailnet name (http://ts-demo-django:8000) despite the VPC security groups having no inbound rules, because its on the same tailnet.

    ```bash
    curl http://ts-demo-django:8000 
    ```

- If you disconnect your local Tailscale client, you will not be able to access any of the AWS instances, thus demonstrating the reliance on the remote access functionality.



## ✅ Automated Tests to Validate Deployment

Alternatively, if you have python installed you can run the included integration tests to verify that all components are working correctly:

```bash
# Install test dependencies
pip install requests

# Run the tests
python test_deployment.py
```

The tests verify:
- SSH access to VM1 and Django VM
- Ping connectivity to the private VM2
- Django app accessibility

If the tests are successful your terminal should look like this:

```bash
test_01_vm1_ssh_access (__main__.DeploymentTest.test_01_vm1_ssh_access)
Test SSH access to VM1 ... ok
test_02_django_ssh_access (__main__.DeploymentTest.test_02_django_ssh_access)
Test SSH access to Django VM ... ok
test_03_private_vm_ping (__main__.DeploymentTest.test_03_private_vm_ping)
Test ping to private VM2 through subnet router ... ok
test_04_django_app_access (__main__.DeploymentTest.test_04_django_app_access)
Test access to Django application ... ok

----------------------------------------------------------------------
Ran 4 tests in 5.042s

OK
```

## 🧹 Project Cleanup

To clean up the demo infrastructure:
- Run `terraform destroy` to delete all resources we created on AWS. 
- Review the resources listed and confirm they are correct.
- Type `yes` to delete the resources.
- If you are done testing Tailscale you may disconnect your local Tailscale client.

## 🎉 Thank You!

Thanks for reviewing this demo project! I hope it clearly demonstrated the power of Terraform to automate the deployment of AWS resources and Tailscale to provide secure, automated remote access to those resources. 

If you have any questions or feedback, please don't hesitate to reach out.


## 📚 Documentation Links
- [Terraform Documentation](https://developer.hashicorp.com/terraform/docs)
- [Tailscale Documentation](https://tailscale.com/kb/)
- [Django Documentation](https://docs.djangoproject.com/en/stable/)

---

## 📝 License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

---



Visitor Count: 1730961641
