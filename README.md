# 3-Tier Infrastructure with Terraform

This repository contains Terraform code to deploy a 3-tier web application infrastructure on AWS. The infrastructure consists of three tiers: Presentation, Application, and Database, each hosted in separate subnets within a Virtual Private Cloud (VPC).

## Features

- **Modular Structure**: The project is organized into separate modules for each tier (Presentation, Application, and Database) to promote reusability and maintainability.

- **Auto Scaling**: Application and Presentation tiers are configured with Auto Scaling Groups to dynamically adjust the number of instances based on demand.

- **Load Balancing**: The Presentation tier uses an Application Load Balancer (ALB) to distribute traffic across instances.

- **Database**: The Database tier is provisioned using Amazon RDS for PostgreSQL, with customizable engine version, storage, backup retention, and more.

- **Security Groups and Network ACLs**: Granular security controls are implemented using security groups and network ACLs to restrict inbound and outbound traffic.

- **Variable Configuration**: Centralized variables configuration allows easy customization of different aspects of the infrastructure.

- **Monitoring and Scaling**: CloudWatch alarms and scaling policies ensure efficient resource utilization based on CPU utilization.

- **Outputs for Visibility**: The `outputs.tf` files define informative outputs that provide visibility into the deployed infrastructure.

## Prerequisites

- [Terraform](https://www.terraform.io/downloads.html) (>= 0.12)
- AWS Account and IAM User with necessary permissions

## Usage

1. Clone this repository to your local machine.
2. Navigate to the root directory of the project.
3. Customize deployment settings by creating a `terraform.tfvars` file and overriding variables as needed.
4. Initialize Terraform by running:
```bash
    terraform init
```
5. Preview the planned changes:
```bash
    terraform plan
```
6. Deploy the infrastructure:
```bash
    terraform apply
```

## Contributions and Feedback
Contributions and feedback are welcome! If you find issues or ways to improve this project, feel free to open an issue or a pull request.

## License
This project is licensed under the MIT License.