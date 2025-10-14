# hub-deployment
Example repo for provisioning and configuring an SLC Hub environment.

Overview
- Use the Terraform examples to create machines, networking and DNS.
- Use Ansible to install and configure the hub and workers on those machines.

Terraform
- Examples live under `terraform/`. Pick the provider/example you need, set variables, then run `terraform init`, `terraform plan`, `terraform apply`.

Ansible
- After Terraform creates machines, copy the generated `hosts` inventory into `ansible/`.
- Edit `ansible/vars/*` as needed (for example `vars/common.yaml`, `vars/license.yaml`).
- Run the provisioning from the `ansible/` directory (see `ansible/README.md` for details).

Permissions note
- Ensure the cloud account/credentials you use have permissions required to create and manage the resources you plan to use (EC2, S3, IAM, DNS). Coordinate with your cloud administrators to obtain an appropriate IAM role or group.

See also
- `terraform/` - terraform examples
- `ansible/README.md` - detailed Ansible usage and variables
