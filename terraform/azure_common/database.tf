resource "azurerm_private_dns_zone" "hubdb-dns-zone" {
  name                = "${var.prefix}-hub-db-private.postgres.database.azure.com"
  resource_group_name = azurerm_resource_group.rg.name
  tags                = var.tags
}

resource "azurerm_private_dns_zone_virtual_network_link" "hubdb-dns-zone-vn-link" {
  name                  = "hubdb-dns-zone-vn-link"
  private_dns_zone_name = azurerm_private_dns_zone.hubdb-dns-zone.name
  virtual_network_id    = azurerm_virtual_network.vn.id
  resource_group_name   = azurerm_resource_group.rg.name
  tags                  = var.tags
}

resource "azurerm_postgresql_flexible_server" "hubdb" {
  name                   = "${var.prefix}-hub-db"
  resource_group_name    = azurerm_resource_group.rg.name
  location               = azurerm_resource_group.rg.location
  version                = "14"
  delegated_subnet_id    = azurerm_subnet.hubdb.id
  private_dns_zone_id    = azurerm_private_dns_zone.hubdb-dns-zone.id
  administrator_login    = "${var.dbusername}"
  administrator_password = "${var.dbpassword}"
  zone                   = "2"
  tags                   = var.tags
  public_network_access_enabled = false

  storage_mb = 32768

  # high_availability {
  #   mode = "ZoneRedundant"
  # }

  # lifecycle {
  #   ignore_changes = [
  #     high_availability.0.standby_availability_zone
  #   ]
  # }

  sku_name   = "${var.dbsku}"
  depends_on = [azurerm_private_dns_zone_virtual_network_link.hubdb-dns-zone-vn-link]

}

# resource "azurerm_postgresql_flexible_server_firewall_rule" "hubdb-firewall-hub-vm" {
#   name             = "hub-vm-fw"
#   server_id        = azurerm_postgresql_flexible_server.hubdb.id
#   start_ip_address = "#{azurerm_linux_virtual_machine.private_ip_address}"
#   end_ip_address   = "#{azurerm_linux_virtual_machine.private_ip_address}"
# }

resource "azurerm_postgresql_flexible_server_database" "db" {
  name      = "${var.prefix}hub"
  server_id = azurerm_postgresql_flexible_server.hubdb.id
  collation = "en_US.utf8"
  charset   = "utf8"
}
