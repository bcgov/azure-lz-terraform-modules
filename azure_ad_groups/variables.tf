variable "environment" {
  type        = string
  description = "Environment name (e.g., Forge, Prod)"
}

variable "license_plate" {
  type        = string
  description = "License plate identifier for the project"
}

variable "project_name" {
  type        = string
  description = "Name of the project"
}

variable "scope" {
  type        = string
  description = "The scope at which the role assignments should be created"
}

variable "admin_email" {
  type        = string
  description = "Email of the admin user who will be an owner of all groups"
}

variable "owners" {
  type        = list(string)
  description = "List of email addresses for users who should be in the Owners group"
}

variable "contributors" {
  type        = list(string)
  default     = []
  description = "List of email addresses for users who should be in the Contributors group"
}

variable "readers" {
  type        = list(string)
  default     = []
  description = "List of email addresses for users who should be in the Readers group"
} 
