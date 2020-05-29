variable "credentials" {
  type        = string
  description = "Path para el archivo de credenciales (.json)."
}

variable "project_id" {
  type        = string
  description = "El project ID donde se instalara el cluster."
}

variable "region" {
  type        = string
  description = "Region para el cluster."
}

variable "zones" {
  type        = list(string)
  description = "Listado de zonas para el cluster."
}

variable "machine_type" {
  type        = string
  description = "Tipo de maquina segun compute engines."
}

variable "service_account" {
  type        = string
  description = "Service account para la ejecucion de las tareas."
}

variable "service_name" {
  type        = string
  description = "Nombre del recurso service para la aplicación"
}
