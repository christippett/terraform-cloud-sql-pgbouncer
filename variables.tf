variable "project" {
  description = "The ID of the project where PgBouncer will be created."
  type        = string
}

variable "name" {
  description = "The name of the PgBouncer instance."
  type        = string
}

variable "zone" {
  description = "The zone where PgBouncer will be created."
  type        = string
}

/* PgBouncer Configuration -------------------------------------------------- */

variable "database_host" {
  description = "The host address of the Cloud SQL instance to connect to."
  type        = string
}

variable "port" {
  description = "The port used by PgBouncer to listen on."
  type        = number
}

variable "users" {
  description = "The list of users to be created in PgBouncer's userlist.txt. Passwords can be provided as plain-text or md5 hashes."
  type        = list(string)
}

variable "auth_user" {
  description = "Any user not specified in `users` will be queried through the `auth_query` query from `pg_shadow` in the database, using `auth_user`. The user for `auth_user` must be included in `users`."
  type        = string
  default     = null
}

variable "auth_query" {
  description = "Query to load user’s password from database."
  type        = string
  default     = null
}

variable "pool_mode" {
  description = "Specifies when a server connection can be reused by other clients. Possible values are `session`, `transaction` or `statement`."
  type        = string
  default     = "transaction"
}

variable "default_pool_size" {
  description = "Maximum number of server connections to allow per user/database pair."
  type        = number
  default     = 20
}

variable "max_client_connections" {
  description = "Maximum number of client connections allowed."
  type        = number
  default     = 100
}

variable "max_db_connections" {
  description = "The maximum number of server connections per database (regardless of user). 0 is unlimited."
  type        = number
  default     = 0
}

variable "pgbouncer_custom_config" {
  description = "Custom PgBouncer configuration values to be appended to `pgbouncer.ini`."
  type        = string
  default     = ""
}

variable "pgbouncer_image_tag" {
  description = "The tag to use for the base PgBouncer `edoburu/pgbouncer` Docker image used by this module."
  default     = "latest"
}

/* Instance Configuration --------------------------------------------------- */

variable "subnetwork" {
  description = "The name or self-link of the subnet where PgBouncer will be created. Either network or subnetwork must be provided."
  type        = string
  default     = null
}

variable "public_ip_address" {
  description = "The public IP address to assign to the PgBouncer instance. If not given, one will be generated. Note: setting this value will limit the instance count to 1."
  type        = string
  default     = null
}

variable "machine_type" {
  description = "The machine type of PgBouncer instances."
  type        = string
  default     = "f1-micro"
}

variable "boot_image" {
  description = "The boot image used by PgBouncer instances. Defaults to the latest LTS Container Optimized OS version. Must be an image compatible with cloud-init (https://cloud-init.io)."
  type        = string
  default     = "cos-cloud/cos-89-lts"
}

variable "tags" {
  description = "A list of tags to assign to PgBouncer instances."
  type        = list(string)
  default     = []
}

variable "service_account_email" {
  description = "The service account e-mail address. If not given, the default Google Compute Engine service account is used."
  default     = null
}

variable "service_account_scopes" {
  description = "A list of service scopes to apply to the PgBouncer instance. Default is the full `cloud-platform` access scope."
  default     = null
}

variable "disable_public_ip" {
  description = "Flag to disable the PgBouncer instance from being assigned an external, public IP"
  default     = false
}

variable "disable_service_account" {
  description = "Flag to disable attaching a service account to the PgBouncer instance."
  default     = false
}

/* Misc --------------------------------------------------------------------- */

variable "module_depends_on" {
  description = "List of modules or resources this module depends on."
  type        = list(any)
  default     = []
}

variable "network_ip" {
  description = "Private IP Address of the VM"
  type        = string
  default     = null
}
