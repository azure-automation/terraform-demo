
resource "azurerm_virtual_network" "main" {
  name                = "workshop-network"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.workshopgroup.location
  resource_group_name = azurerm_resource_group.workshopgroup.name
}

resource "azurerm_subnet" "internal" {
  name                 = "internal"
  resource_group_name  = azurerm_resource_group.workshopgroup.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_public_ip" "terraform-pip" {
  name                = "terraform-pip--${lower(random_id.uid.hex)}"
  resource_group_name = azurerm_resource_group.workshopgroup.name
  location            = azurerm_resource_group.workshopgroup.location
  allocation_method   = "Dynamic"
}

resource "azurerm_network_interface" "main" {
  name                = "workshop-nic"
  location            = azurerm_resource_group.workshopgroup.location
  resource_group_name = azurerm_resource_group.workshopgroup.name
  ip_configuration {
    name                          = "workshopconfiguration"
    subnet_id                     = azurerm_subnet.internal.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.terraform-pip.id
  }
}

resource "azurerm_virtual_machine" "terraformvm" {
  name                  = "instance-1"
  location              = "West Europe"
  resource_group_name   = azurerm_resource_group.workshopgroup.name
  network_interface_ids = [azurerm_network_interface.main.id]
  vm_size               = "Standard_D1_v2"
  storage_os_disk {
    name              = "OsDisk"
    caching           = "None"
    create_option     = "FromImage"
    managed_disk_type = "StandardSSD_LRS"
  }
  delete_os_disk_on_termination = true
  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }
  os_profile {
    computer_name  = "workshop-vm"
    admin_username = "az-user"
  }
  os_profile_linux_config {
    disable_password_authentication = true
    ssh_keys {
      path     = "/home/az-user/.ssh/authorized_keys"
      key_data = tls_private_key.workshop-key.public_key_openssh
    }
  }
}
