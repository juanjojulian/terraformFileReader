resource "null_resource" "subnetfileReader" {
  for_each = fileset("./subnets", "*_subnet.json")
}

locals {
  subnets = [for key, _ in null_resource.subnetfileReader : jsondecode(file("./subnets/${key}"))]
}

resource "azurerm_subnet" "example" {
  for_each             = { for i in local.subnets : i.name => i }
  name                 = each.value.name
  resource_group_name  = each.value.resource_group_name
  virtual_network_name = each.value.virtual_network_name
  address_prefixes     = each.value.address_prefixes
}