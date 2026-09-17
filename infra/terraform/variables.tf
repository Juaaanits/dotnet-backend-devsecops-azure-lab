variable "project_name" {
  type        = string
  description = "Lowercase project prefix used in Azure resource names."
  default     = "sakennylab"
}

variable "environment" {
  type        = string
  description = "Environment suffix."
  default     = "dev"
}

variable "location" {
  type        = string
  description = "Azure region."
  default     = "southeastasia"
}

variable "sql_admin_login" {
  type        = string
  description = "Azure SQL administrator login."
  default     = "sakennyadmin"
}

variable "sql_admin_password" {
  type        = string
  description = "Azure SQL administrator password. Supply through TF_VAR_sql_admin_password."
  sensitive   = true
}

variable "jwt_key" {
  type        = string
  description = "JWT signing key. Supply through TF_VAR_jwt_key."
  sensitive   = true
}

variable "bootstrap_admin_username" {
  type        = string
  description = "Username for the initial application administrator."
  default     = "qa-admin"
}

variable "bootstrap_admin_email" {
  type        = string
  description = "Email for the initial application administrator."
  default     = "qa-admin@example.test"
}

variable "bootstrap_admin_password" {
  type        = string
  description = "Initial administrator password. Supply through TF_VAR_bootstrap_admin_password."
  sensitive   = true
}

variable "tags" {
  type = map(string)
  default = {
    project    = "sakenny-qa-devsecops-lab"
    managed_by = "terraform"
  }
}
