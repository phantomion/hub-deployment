# Terraform - AWS + Route 53

Purpose
- Create the VMs, networking and Route 53 records required for an SLCHub deployment in AWS. This module expects a pre-existing base DNS zone in Route 53.

Quick flow
1. Authenticate to AWS with an account that has permissions to create EC2, IAM, S3 and Route 53 resources.
2. Review and set values in `variables.tf` (or a `*.tfvars` file).
3. Run: `terraform init`, `terraform plan` and `terraform apply`.
4. After a successful `terraform apply` copy the generated `hosts` file into the `ansible/` directory and run the Ansible provisioning (`ansible/all.sh`).

Notes
- Ensure the AWS credentials or role you use have sufficient permissions to create and manage EC2, IAM, S3 and Route53 resources required by this module.
- Coordinate with your cloud administrators to obtain or create an IAM role or group with permissions needed to create S3 buckets and any IAM users required by the deployment.
