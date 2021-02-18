# terraformFileReader
Terraform code to read multiple files from a directory and deploys resources based on the data.



**- deployerSubnet.tf**

Easy example, reads files that match "*_subnet.json" inside ./subnets directory and deploys a subnet per file with provided data.

**- deployerVirtualmachine.tf**