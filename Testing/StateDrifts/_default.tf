terraform {

  required_version = "= 1.1.2"
  # Initial version to test config drift with on 07/02/2022: 0.14.11

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=2.96.0"
    }
  }
}