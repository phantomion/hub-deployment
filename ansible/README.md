# Ansible
This folder contains Ansible playbooks to provision a hub and any number of workers.

Key points
- Workers must not be run on the hub node.
- Provide a `hosts` file (inventory) and update variables in `vars/` as needed.
- Ensure you have SSH access to target hosts (pre-shared private key or another mechanism).

Flow
1. Prepare infrastructure (for example with `terraform/aws_route53`).
2. After Terraform completes copy the generated `hosts` file into this directory.
3. Review and set values in `vars/*` (for example `vars/common.yaml`, `vars/ldap.yaml`, `vars/license.yaml`).
4. Update `vars/license.yaml` with a valid `auth_code` before running: generate it at https://admin.altairone.com/updateprofile in the "Authorized Machines" tab and place the code as `license.auth_code`.
5. Run `./all.sh` to provision.

## Hosts example (AWS)

```
[all:vars]
cloud_provider = aws
ingress_url = https://hub.test.wpscloud.co.uk
shared_store_endpoint = 172.17.2.31:/
db_host = test-hub-db.calypti53pcp.eu-west-2.rds.amazonaws.com
db_name = testhub
db_user = hubdb
db_password = shadjg7ad89hjklasdfgbhjkl
s3_endpoint = s3.amazonaws.com
s3_access_key_id = AKIAVSPH6RVLN6J
s3_secret_access_key = RpbPHWt5ucT7PexRy+/X4F5A/Ykf
s3_bucket = test-hubdata
s3_region = eu-west-2

[hub]
1.2.3.4 ansible_user=abc private_name=hubvm.test.wpscloud.co.uk

[workers]
2.3.4.5 ansible_user=abc private_name=worker0.test.wpscloud.co.uk
2.3.4.6 ansible_user=abc private_name=worker1.test.wpscloud.co.uk
```

## Hosts example (Azure)

```
[all:vars]
cloud_provider = azure
ingress_url = https://hub.test.wpscloud.co.uk
shared_store_endpoint = hub-test-store.file.core.windows.net:/hub-test-store/hub-test-shared-store
db_name = testhub
db_user = hubdb
db_password = sh2djg7ad89hjklasdfgbhjkl
azure_storage_endpoint = https://hub-test.blob.core.windows.net/
azure_storage_account_name = hub-test
azure_storage_access_key = Sx5p8D1iOVcMrhPGCV3iZZI2pB6Or6aSx5p8D1iOVcMrhPGCV3iZZI2pB6Or6a==
azure_storage_container = test-hubdata
azure_storage_region = westeurope

[hub]
1.2.3.4 ansible_user=abc private_name=hubvm.test.wpscloud.co.uk

[workers]
2.3.4.5 ansible_user=abc private_name=worker0.test.wpscloud.co.uk
2.3.4.6 ansible_user=abc private_name=worker1.test.wpscloud.co.uk
```

## Variables

You must set all appropriate variables in vars/common.yaml, either in that file or in hosts as shown above.

vars/ldap.yaml should be setup if you'd like ldap integration.

vars/license.yaml you must set the license type either a1 (for altair units) or
alm (for license manager). See vars/license.yaml for more details.







