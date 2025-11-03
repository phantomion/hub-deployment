resource "azurerm_network_security_group" "ldap" {
  count               = var.create_ldap_example_vm ? 1 : 0

  name                = "${var.prefix}-ldap"
  location            = "${azurerm_resource_group.rg.location}"
  resource_group_name = "${azurerm_resource_group.rg.name}"
  tags                = var.tags

  # SSH access for setup
  security_rule {
    name                         = "ssh"
    description                  = "SSH from host"
    priority                     = 200
    direction                    = "Inbound"
    access                       = "Allow"
    protocol                     = "Tcp"
    source_port_range            = "*"
    destination_port_range       = "22"
    source_address_prefix        = ""
    source_address_prefixes      = split(",", var.setup_from_address_range)
    destination_address_prefix   = "*"
    destination_address_prefixes = []
  }

  security_rule {
    name                         = "ldap"
    description                  = "LDAP"
    priority                     = 700
    direction                    = "Inbound"
    access                       = "Allow"
    protocol                     = "Tcp"
    source_port_range            = "*"
    destination_port_range       = "3268"
    source_address_prefix        = ""
    source_address_prefixes      = azurerm_virtual_network.vn.address_space
    destination_address_prefix   = "*"
    destination_address_prefixes = []
  }

  # outbound internet access
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
    source_address_prefixes      = []
    destination_address_prefix   = "*"
    destination_address_prefixes = []
  }
}

# Create public IP
resource "azurerm_public_ip" "ldap-public-ip" {
  count               = var.create_ldap_example_vm ? 1 : 0

  name                = "${var.prefix}-ldap-public-ip"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

# Create network interface
resource "azurerm_network_interface" "ldap-nic" {
  count                     = var.create_ldap_example_vm ? 1 : 0

  name                      = "${var.prefix}-ldap-nic"
  location                  = azurerm_resource_group.rg.location
  resource_group_name       = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "${var.prefix}-ldap-nic-conf"
    subnet_id                     = azurerm_subnet.vms.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.ldap-public-ip.id
  }
}

resource "azurerm_network_interface_security_group_association" "ldap-nsg" {
  count                     = var.create_ldap_example_vm ? 1 : 0

  network_interface_id      = azurerm_network_interface.ldap-nic.id
  network_security_group_id = azurerm_network_security_group.ldap.id
}

# Create Hub VM
resource "azurerm_linux_virtual_machine" "ldap" {
  count                 = var.create_ldap_example_vm ? 1 : 0

  name                  = "${var.prefix}-ldap"
  location              = azurerm_resource_group.rg.location
  resource_group_name   = azurerm_resource_group.rg.name
  network_interface_ids = [azurerm_network_interface.ldap-nic.id]
  size                  = "Standard_B1ms"

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
  }

  source_image_reference {
    publisher = "resf"
    offer     = "rockylinux-x86_64"
    sku       = "8-lvm"
    version   = "latest"
  }

  plan {
    name = "8-lvm"
    product = "rockylinux-x86_64"
    publisher = "resf"
  }

  computer_name  = "${var.prefix}-ldap"
  admin_username = var.ssh_user_name

  admin_ssh_key {
    username   = var.ssh_user_name
    public_key = azurerm_ssh_public_key.common-auth.public_key
  }
}

