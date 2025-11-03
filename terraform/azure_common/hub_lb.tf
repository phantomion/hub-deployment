resource "azurerm_network_security_group" "hublb" {
  name                = "${var.prefix}-hublb"
  location            = "${azurerm_resource_group.rg.location}"
  resource_group_name = "${azurerm_resource_group.rg.name}"
  tags                = var.tags

  security_rule {
    name                         = "https"
    description                  = "HTTPS from anywhere"
    priority                     = 200
    direction                    = "Inbound"
    access                       = "Allow"
    protocol                     = "Tcp"
    source_port_range            = "*"
    destination_port_range       = "443"
    source_address_prefix        = "*"
    destination_address_prefix   = "*"
  }

  /* security_rule {
    name                                       = "BlockRemoteAccess"
    description                                = ""
    priority                                   = 300
    direction                                  = "Inbound"
    access                                     = "Deny"
    protocol                                   = "Tcp"
    source_port_range                          = "*"
    destination_port_ranges                    = ["22","3389"]
    destination_address_prefix                 = "*"
    source_address_prefix                      = "*"
  } */

  security_rule {
    name                         = "outbound"
    description                  = "Allow all outbound"
    priority                     = 100
    direction                    = "Outbound"
    access                       = "Allow"
    protocol                     = "Tcp"
    source_port_range            = "*"
    destination_port_range       = "*"
    source_address_prefix        = "*"
    destination_address_prefix   = "*"
  }
}

resource "azurerm_public_ip" "hublb-public-ip" {
  name                = "${var.prefix}-hublb-public-ip"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = var.tags
}

resource "azurerm_application_gateway" "hublb" {
  name                = "${var.prefix}-hub-alb"
  location            = "${azurerm_resource_group.rg.location}"
  resource_group_name = "${azurerm_resource_group.rg.name}"
  tags                = var.tags

  ssl_policy {
    policy_type = "Predefined"
    policy_name = "AppGwSslPolicy20220101"
  }

  sku {
    name = "Standard_v2"
    tier = "Standard_v2"
    capacity = 2
  }

  global {
    # We need to disable response buffering to enable SSE:
    request_buffering_enabled = false
    response_buffering_enabled = false
  }

  gateway_ip_configuration {
    name = "${var.prefix}-hublb-ip-conf"
    subnet_id = azurerm_subnet.lb.id
  }

  frontend_port {
    name = "${var.prefix}-hublb-fe-port"
    # port = 443
    port = 80
  }

  frontend_ip_configuration {
    name                 = "${var.prefix}-hublb-fe-ip-conf"
    public_ip_address_id = azurerm_public_ip.hublb-public-ip.id
  }

  backend_address_pool {
    name = "${var.prefix}-hublb-be-address-pool"
    ip_addresses = azurerm_linux_virtual_machine.hub.private_ip_addresses
  }

  backend_http_settings {
    name                  = "${var.prefix}-hublb-be-http-settings"
    cookie_based_affinity = "Disabled"
    path                  = "/"
    port                  = 9090
    protocol              = "Http"
    request_timeout       = 60
  }

  /* ssl_certificate {
    name     = "${var.prefix}-hublb-ssl-cert"
    data     = acme_certificate.hub.certificate_p12
    password = "${var.acme_cert_password}"
  } */

  http_listener {
    name                           = "${var.prefix}-hublb-listener"
    frontend_ip_configuration_name = "${var.prefix}-hublb-fe-ip-conf"
    frontend_port_name             = "${var.prefix}-hublb-fe-port"
    # ssl_certificate_name           = "${var.prefix}-hublb-ssl-cert"
    # protocol                       = "Https"
    protocol                       = "Http"
  }

  request_routing_rule {
    name                       = "${var.prefix}-hublb-request-routing-rule"
    priority                   = 100
    rule_type                  = "Basic"
    http_listener_name         = "${var.prefix}-hublb-listener"
    backend_address_pool_name  = "${var.prefix}-hublb-be-address-pool"
    backend_http_settings_name = "${var.prefix}-hublb-be-http-settings"
  }
}

