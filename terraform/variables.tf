variable "application_name" {
  description = "Short workload name used in resource names."
  type        = string
  default     = "cloudapp"
}

variable "environment" {
  description = "Deployment environment."
  type        = string

  validation {
    condition     = contains(["dev", "test", "prod"], var.environment)
    error_message = "environment must be dev, test, or prod."
  }
}

variable "location" {
  description = "Azure region for all resources."
  type        = string
  default     = "eastus"
}

variable "unique_suffix" {
  description = "Lowercase alphanumeric suffix (3-8 chars) for globally unique names."
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9]{3,8}$", var.unique_suffix))
    error_message = "unique_suffix must contain 3-8 lowercase letters or digits."
  }
}

variable "tags" {
  description = "Additional tags merged with standard workload tags."
  type        = map(string)
  default     = {}
}
