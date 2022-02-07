variable "azure_region" {
  default = "westeurope"
}

variable "cust" {
  default = "mja"
}

variable "app_name" {
  default = "tryout"
}

variable "environment" {
  default = "tst"
}

variable "address_space" {
  default = "66"
}

variable "default_tags" {
  default = {
    Environment = "test",
    Owner       = "Marco Janse",
    app         = "TryOut"
  }
}

variable "workspace_var" {
  default = 2
}