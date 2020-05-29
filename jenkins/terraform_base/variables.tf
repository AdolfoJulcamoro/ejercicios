variable "credentials" {
  type        = string
  description = "Location of the credentials keyfile."
}

variable "project_id" {
  type        = string
  description = "The project ID to host the cluster in."
}

variable "region" {
  type        = string
  description = "The region to host the cluster in."
}

variable "zones" {
  type        = list(string)
  description = "The zones to host the cluster in."
}

variable "service_account" {
  type        = string
  description = "The service account to run nodes as if not overridden in `node_pools`. The create_service_account variable default value (true) will cause a cluster-specific service account to be created."
}

variable "vm_name" {
  type        = string
  description = "Nombre de la máquina virtual"
}

variable "machine_type" {
  type        = string
  description = "Tipo para la VM"
}

variable "ssh_username" {
  type = string
}

variable "ssh_pub_key_path" {
  type = string
}

