resource "azurerm_storage_account" "shared-store" {
  name                       = "${replace(var.prefix, "/[^a-zA-Z0-9]/", "")}shared"
  location                   = azurerm_resource_group.rg.location
  resource_group_name        = azurerm_resource_group.rg.name
  account_tier               = "Premium"
  account_replication_type   = "LRS"
  account_kind               = "FileStorage"
  # is_hns_enabled            = true
  # nfsv3_enabled             = true
  https_traffic_only_enabled = false
  tags                       = var.tags

  share_properties {
    retention_policy {
      days = 7
    }
  }

  lifecycle {
    ignore_changes = [
      share_properties.0.smb,
      tags
    ]
  }
}

resource "azurerm_storage_account_network_rules" "shared-store" {
  storage_account_id = azurerm_storage_account.shared-store.id

  default_action             = "Deny"
  bypass                     = ["None"]
  ip_rules                   = split(",", var.setup_from_address_range)
  virtual_network_subnet_ids = [azurerm_subnet.vms.id]
}

resource "azurerm_storage_share" "shared-store" {
  name                 = "${var.prefix}-shared-store"
  storage_account_name = azurerm_storage_account.shared-store.name
  quota                = 100 # Max size in GBs
  access_tier          = "Premium"
  enabled_protocol     = "NFS"

  acl {
    id = "MTIzNDU2Nzg5MDEyMzQ1Njc4OTAxMjM0NTY3ODkwMTI"

    access_policy {
      permissions = "rwdl"
      # start       = "2023-08-01T00:00:00.0000000Z"
      # expiry      = "2023-08-01T23:59:59.0000000Z"
    }
  }
}

