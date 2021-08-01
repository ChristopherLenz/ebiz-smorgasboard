variable "prefix" {
  description = "The prefix for the resources created in the specified Azure Resource Group"
  type        = string
}

variable "agents_size" {
  default     = "Standard_D2s_v3"
  description = "The default virtual machine size for the Kubernetes agents"
  type        = string
}

variable "agents_count" {
  description = "The number of Agents that should exist in the Agent Pool"
  type        = number
  default     = 2
}

variable "os_disk_size_gb" {
  description = "Disk size of nodes in GBs."
  type        = number
  default     = 50
}

variable "kubernetes_version" {
  default     = "1.19.9"
  description = "The version of Kubernetes that should be used for this cluster. You will be able to upgrade this version after creating the cluster."
  type        = string
}

variable "availability_zones" {
  type        = list(string)
  description = "A list of Availability Zones across which the Node Pool should be spread. Changing this forces a new resource to be created."
  default     = ["1", "2", "3"]
}

variable "enable_http_application_routing" {
  description = "Enable HTTP Application Routing Addon (forces recreation)."
  type        = bool
  default     = false
}
