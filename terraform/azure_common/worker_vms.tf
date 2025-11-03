resource "azurerm_network_security_group" "worker" {
  name                = "${var.prefix}-worker"
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
    source_address_prefixes      = split(",", var.setup_from_address_range)
    destination_address_prefix   = "*"
  }

  security_rule {
    name                         = "nomadrpc"
    description                  = "Nomad RPC"
    priority                     = 210
    direction                    = "Inbound"
    access                       = "Allow"
    protocol                     = "Tcp"
    source_port_range            = "*"
    destination_port_range       = "4647"
    source_address_prefixes      = azurerm_virtual_network.vn.address_space
    destination_address_prefix   = "*"
  }

  security_rule {
    name                         = "worker"
    description                  = "Worker on demand"
    priority                     = 220
    direction                    = "Inbound"
    access                       = "Allow"
    protocol                     = "Tcp"
    source_port_range            = "*"
    destination_port_range       = "20000-32000"
    source_address_prefixes      = azurerm_virtual_network.vn.address_space
    destination_address_prefix   = "*"
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
    destination_address_prefix   = "*"
  }
}

# Create public IP
resource "azurerm_public_ip" "worker-public-ip" {
  count = var.worker_vm_count

  name                = "${var.prefix}-worker-${count.index}-public-ip"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
  tags                = var.tags
}

# Create network interface
resource "azurerm_network_interface" "worker-nic" {
  count = var.worker_vm_count

  name                = "${var.prefix}-worker-${count.index}-nic"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  tags                = var.tags

  ip_configuration {
    name                          = "${var.prefix}-worker-${count.index}-nic-conf"
    subnet_id                     = azurerm_subnet.vms.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.worker-public-ip[count.index].id
  }
}

resource "azurerm_network_interface_security_group_association" "worker-nsg" {
  count = var.worker_vm_count

  network_interface_id          = azurerm_network_interface.worker-nic[count.index].id
  network_security_group_id = azurerm_network_security_group.worker.id
}

# Create Hub VM
resource "azurerm_linux_virtual_machine" "worker" {
  count = var.worker_vm_count

  name                  = "${var.prefix}-worker-${count.index}"
  location              = azurerm_resource_group.rg.location
  resource_group_name   = azurerm_resource_group.rg.name
  network_interface_ids = [azurerm_network_interface.worker-nic[count.index].id]
  size                  = "${var.workervmsize}"
  tags                  = var.tags

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

  computer_name  = "${var.prefix}-worker-${count.index}"
  admin_username = var.ssh_user_name

  admin_ssh_key {
    username   = var.ssh_user_name
    public_key = azurerm_ssh_public_key.common-auth.public_key
  }
}

