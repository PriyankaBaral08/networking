provider "azurerm" {
  features {}
  subscription_id = "f9b3e2dd-1ccb-4e99-b9ef-42caeffe9bd9"
}

variable "ssh_public_key" {
  description = "Public SSH key for authentication"
  type        = string
}

resource "azurerm_resource_group" "flask-rg" {
  name     = "flask-app-rg"
  location = "East US"
}

resource "azurerm_virtual_network" "v_net" {
  name                = "flask-app-vnet"
  location            = azurerm_resource_group.flask-rg.location
  resource_group_name = azurerm_resource_group.flask-rg.name
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "subnet" {
  name                 = "flask-app-subnet"
  resource_group_name  = azurerm_resource_group.flask-rg.name
  virtual_network_name = azurerm_virtual_network.v_net.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_network_security_group" "nsg" {
  name                = "flask-app-nsg"
  location            = azurerm_resource_group.flask-rg.location
  resource_group_name = azurerm_resource_group.flask-rg.name

  security_rule {
    name                       = "allow_ssh"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "allow_http"
    priority                   = 1002
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "5000"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  # Allow HTTPS
  security_rule {
    name                       = "HTTPS"
    priority                   = 1003
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  # Allow Flask app port
  security_rule {
    name                       = "Flask"
    priority                   = 1004
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "5000"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

# Associate NSG with Subnet
resource "azurerm_subnet_network_security_group_association" "nsg_subnet" {
  subnet_id                 = azurerm_subnet.subnet.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}

resource "azurerm_public_ip" "publicip" {
  name                = "flask-app-public-ip"
  location            = azurerm_resource_group.flask-rg.location
  resource_group_name = azurerm_resource_group.flask-rg.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "nic" {
  name                = "flask-app-nic"
  location            = azurerm_resource_group.flask-rg.location
  resource_group_name = azurerm_resource_group.flask-rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.publicip.id
  }
}

# Connect the security group to the network interface
resource "azurerm_network_interface_security_group_association" "nic_nsg_association" {
  network_interface_id      = azurerm_network_interface.nic.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}

resource "azurerm_linux_virtual_machine" "vm" {
  name                = "flask-app-vm"
  resource_group_name = azurerm_resource_group.flask-rg.name
  location            = azurerm_resource_group.flask-rg.location
  size                = "Standard_B1s"
  admin_username      = "adminuser"

  network_interface_ids = [azurerm_network_interface.nic.id]

  admin_ssh_key {
    username   = "adminuser"
    public_key = var.ssh_public_key
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }
}
