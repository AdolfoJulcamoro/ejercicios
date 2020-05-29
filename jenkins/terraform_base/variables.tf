variable "credentials" {
  type        = string
  description = "Ubicación del archivo de credenciales (json)."
}

variable "project_id" {
  type        = string
  description = "El project ID donde se instalará el cluster."
}

variable "region" {
  type        = string
  description = "The región para el cluster."
}

variable "zones" {
  type        = list(string)
  description = "Las zonas para el cluster."
}

variable "service_account" {
  type        = string
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

