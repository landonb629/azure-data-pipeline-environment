variable "name" {
  description = "This will be the name of your deployment, this includes vnet, databases, etc."
  type = string
  default = ""
}

variable "address_space" {
  description = "the address space that you want your vnet to be"
  type = string 
  default = "10.0.0.0/20"
}

variable "email" {
  description = "email address of the user who this development environment is for"
  type = string 
  default = ""
}
variable "source_ip_address" {
  description = "source IP address of the user who will be using the dev environment"
  type = string
  default = ""
}
variable "password" {
  description = "windows VM administrator password"
  type = string
  default = "P@55W0rD5@Res3Cure"
}