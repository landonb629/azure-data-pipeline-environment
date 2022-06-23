variable "name" {
  description = "This will be the name of your deployment, this includes vnet, databases, etc."
  type = string
  default = "hybrid-data-pipeline-environment"
}

variable "address_space" {
  description = "the address space that you want your vnet to be"
  type = string 
  default = "10.0.0.0/20"
}