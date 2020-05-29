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

variable "machine_type" {
  type        = string
  description = "Type of the node compute engines."
}

variable "service_account" {
  type        = string
  description = "The service account to run nodes as if not overridden in `node_pools`. The create_service_account variable default value (true) will cause a cluster-specific service account to be created."
}

#variable "initial_node_count" {
#  type        = number
#  description = "The number of nodes to create in this cluster's default node pool."
#}

variable "service_name" {
  type        = string
  description = "Nombre del recurso service para la aplicación"
}
