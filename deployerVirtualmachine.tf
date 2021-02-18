resource "null_resource" "VMfileReader" {
  for_each = fileset("./virtualmachines", "*_vm.json")
}

locals {
  virtualMachines = [for key, _ in null_resource.VMfileReader : jsondecode(file("./virtualmachines/${key}"))]
}

data "azurerm_subnet" "main" {
  for_each             = { for i in local.virtualMachines : i.subnet.name => i.subnet... }
  name                 = each.key
  virtual_network_name = each.value[0].virtual_network_name
  resource_group_name  = each.value[0].resource_group_name
}

resource "azurerm_network_interface" "main" {
  for_each            = { for vm in local.virtualMachines : vm.name => vm }
  name                = "${each.key}-nic"
  location            = each.value.location
  resource_group_name = each.value.resource_group_name

  ip_configuration {
    name                          = "${each.key}-ipaddress"
    subnet_id                     = data.azurerm_subnet.main[each.value.subnet.name].id
    private_ip_address_allocation = "static"
    private_ip_address            = each.value.subnet.private_ip_address
  }
}


resource "azurerm_linux_virtual_machine" "main" {
  for_each            = { for vm in local.virtualMachines : vm.name => vm if vm.OperatingSystem == "Linux" }
  name                = each.key
  resource_group_name = each.value.resource_group_name
  location            = each.value.location
  size                = each.value.size
  admin_username      = "Juanjo"
  network_interface_ids = [
    azurerm_network_interface.main[each.key].id,
  ]
  admin_ssh_key {
    username   = "adminuser"
    public_key = file("~/.ssh/id_rsa.pub")
  }
  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }
  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }
}

resource "azurerm_windows_virtual_machine" "main" {
  for_each            = { for vm in local.virtualMachines : vm.name => vm if vm.OperatingSystem == "Windows" }
  name                = each.key
  resource_group_name = each.value.resource_group_name
  location            = each.value.location
  size                = each.value.size
  admin_username      = "Juanjo"
  admin_password      = "WhyWhyWhy!"
  network_interface_ids = [
    azurerm_network_interface.main[each.key].id,
  ]
  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }
  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2016-Datacenter"
    version   = "latest"
  }
}