# Authentication
provider "azurerm" {
  features {}
#  subscription_id = var.tf_var_arm_subscription_id
#  client_id       = var.tf_var_arm_client_id
#  client_secret   = var.tf_var_arm_client_secret
#  tenant_id       = var.tf_var_arm_tenant_id
}

# Variable declaration
variable "tf_var_arm_subscription_id" {
  default = "1dd4f0e3-d426-4411-9cf0-b270551d923e"
  description = "enter subscription id"
}


variable "resourceGroupName" {
  type        = string
  default     = "rg-demo002"
  description = "Resource Group for this deployment."
}

variable "location" {
  type        = string
  default     = "westeurope"
  description = "Enter the location for all resources."
}

variable "adminUsername" {
  type        = string
  description = "User name for the Virtual Machine"
}

variable "vmName" {
  type        = string
  description = "Name for the Virtual Machine"
}

variable "adminPasswordOrKey" {
  type        = string
  description = "SSH Key or password for the Virtual Machine. SSH key is recommended."
}

variable "authenticationType" {
  type        = string
  default     = "sshPublicKey"
  description = "Type of authentication to be used on the Virtual Machine. SSH key is recommended but if you want to use password authentication use 'password'"
  validation {
    condition     = var.authenticationType == "sshPublicKey" || var.authenticationType == "password"
    error_message = "Authentication type hould be either \"ssh\" or \"password\"."
  }
}
