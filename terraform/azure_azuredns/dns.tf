# This generates records in azure dns. Other DNS providers could be substituted.

resource "azurerm_dns_a_record" "lb" {
  name                = "hub.${var.prefix}"
  zone_name           = azurerm_dns_zone.zone.name
  resource_group_name = azurerm_resource_group.rg.name
  ttl                 = 300
  records             = [azurerm_public_ip.hublb-public-ip.ip_address]
}

resource "azurerm_dns_a_record" "hub" {
  name                = "hubvm.${var.prefix}"
  zone_name           = azurerm_dns_zone.zone.name
  resource_group_name = azurerm_resource_group.rg.name
  ttl                 = 300
  records             = [azurerm_linux_virtual_machine.hub.private_ip_address]
}

resource "azurerm_dns_a_record" "worker" {
  count = var.worker_vm_count

  name                = "worker${count.index}.${var.prefix}"
  zone_name           = azurerm_dns_zone.zone.name
  resource_group_name = azurerm_resource_group.rg.name
  ttl                 = 300
  records             = [azurerm_linux_virtual_machine.worker[count.index].private_ip_address]
}
