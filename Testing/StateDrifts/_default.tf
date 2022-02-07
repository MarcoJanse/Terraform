terraform {

  required_version = "= 0.14.11"
  # Initial version to test config drift with on 07/02/2022: 0.14.11

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=2.28.0"
    }
  }
}