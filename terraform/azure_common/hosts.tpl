[all:vars]
cloud_provider = azure
ingress_url = ${ingress_url}
shared_store_endpoint = ${shared_store_endpoint}
db_host = ${db_host}
db_name = ${db_name}
db_user = ${db_user}
db_password = ${db_password}
db_ssl_mode = require
azure_storage_endpoint = ${azure_storage_endpoint}
azure_storage_account_name = ${azure_storage_account_name}
azure_storage_access_key = ${azure_storage_access_key}
azure_storage_container_name = ${azure_storage_container_name}
azure_storage_region = ${azure_storage_region}
azure_storage_insecure = false

[hub]
${hub_ip} ansible_user=${username} private_name=${hub_private_name} private_ip=${hub_private_ip}

[workers]
%{ for worker in workers ~}
${worker.public_ip} ansible_user=${username} private_name=${worker.private_name}
%{endfor ~}
