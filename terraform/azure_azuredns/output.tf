output "hub_ip_address" {
  value = "${azurerm_public_ip.hub-public-ip.ip_address}"
}

output "worker_ip_address" {
  value = "${azurerm_public_ip.worker-public-ip.*.ip_address}"
}

resource "local_file" "ansible_hosts" {
  content = templatefile("hosts.tpl", {
	hub_ip = azurerm_public_ip.hub-public-ip.ip_address
	hub_private_name = azurerm_dns_a_record.hub.name
  hub_private_ip = azurerm_network_interface.hub-nic.private_ip_address
	ingress_url = "https://${acme_certificate.hub.common_name}"
	shared_store_endpoint = "${azurerm_storage_share.shared-store.storage_account_name}.file.core.windows.net:/${azurerm_storage_share.shared-store.storage_account_name}/${azurerm_storage_share.shared-store.name}"
	workers = [
	  for i,v in azurerm_linux_virtual_machine.worker:
	  {
		"public_ip" = azurerm_public_ip.worker-public-ip[i].ip_address
		"private_name" = azurerm_dns_a_record.worker[i].name
	  }
	]
	# workers = azurerm_linux_virtual_machine.worker
	username = "${var.ssh_user_name}"
	db_host = azurerm_postgresql_flexible_server.hubdb.fqdn
	db_name = azurerm_postgresql_flexible_server_database.db.name
	db_user = "${var.dbusername}"
	db_password = "${var.dbpassword}"
	azure_storage_endpoint = azurerm_storage_account.hubdata.primary_blob_endpoint
	azure_storage_account_name = azurerm_storage_account.hubdata.name
	azure_storage_access_key = azurerm_storage_account.hubdata.primary_access_key
	azure_storage_container_name = azurerm_storage_container.hubdata.name
	azure_storage_region = "${var.region}"
  })
  filename = "hosts"
  file_permission = 0600
}
