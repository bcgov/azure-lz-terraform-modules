variable "key_vault_id" {
  description = "(Required) Specifies the id of the Key Vault resource."
  type        = string
}

variable "object_id" {
  description = "(Required) The object ID of a user, service principal or security group in the Azure Active Directory tenant for the vault."
  type        = string
}

variable "application_id" {
  description = "(Optional) The object ID of an Application in Azure Active Directory."
  type        = string
  default     = null
}

variable "certificate_permissions" {
  description = "(Optional) List of certificate permissions."
  type        = list(string)
  default     = []

  validation {
    condition = alltrue([
      for permission in var.certificate_permissions : contains(["Backup", "Create", "Delete", "DeleteIssuers", "Get", "GetIssuers", "Import", "List", "ListIssuers", "ManageContacts", "ManageIssuers", "Purge", "Recover", "Restore", "SetIssuers", "Update"], permission)
    ])
    error_message = "certificate_permissions must be one or more from the following: Backup, Create, Delete, DeleteIssuers, Get, GetIssuers, Import, List, ListIssuers, ManageContacts, ManageIssuers, Purge, Recover, Restore, SetIssuers and Update."
  }
}

variable "key_permissions" {
  description = "(Optional) List of key permissions."
  type        = list(string)
  default     = []

  validation {
    condition = alltrue([
      for permission in var.key_permissions : contains(["Backup", "Create", "Decrypt", "Delete", "Encrypt", "Get", "Import", "List", "Purge", "Recover", "Restore", "Sign", "UnwrapKey", "Update", "Verify", "WrapKey", "Release", "Rotate", "GetRotationPolicy", "SetRotationPolicy"], permission)
    ])
    error_message = "key_permissions must be one or more from the following: Backup, Create, Decrypt, Delete, Encrypt, Get, Import, List, Purge, Recover, Restore, Sign, UnwrapKey, Update, Verify, WrapKey, Release, Rotate, GetRotationPolicy and SetRotationPolicy."
  }
}

variable "secret_permissions" {
  description = "(Optional) List of secret permissions."
  type        = list(string)
  default     = []

  validation {
    condition = alltrue([
      for permission in var.secret_permissions : contains(["Backup", "Delete", "Get", "List", "Purge", "Recover", "Restore", "Set"], permission)
    ])
    error_message = "secret_permissions must be one or more from the following: Backup, Delete, Get, List, Purge, Recover, Restore and Set."
  }
}

variable "storage_permissions" {
  description = "(Optional) List of storage permissions."
  type        = list(string)
  default     = []

  validation {
    condition = alltrue([
      for permission in var.storage_permissions : contains(["Backup", "Delete", "Deletesas", "Get", "Getsas", "List", "Listsas", "Purge", "Recover", "Regeneratekey", "Restore", "Set", "Setsas", "Update"], permission)
    ])
    error_message = "storage_permissions must be one or more from the following: Backup, Delete, Deletesas, Get, Getsas, List, Listsas, Purge, Recover, Regeneratekey, Restore, Set, Setsas and Update."
  }
}
