variable "firewall_name" {
  description = "The name of the firewall rule"
}

variable "network_name" {
  description = "The VPC network to apply the firewall rule"
}

variable "ports" {
  description = "List of allowed ports"
  type        = list(string)
  default     = ["80", "443"]
}

variable "source_ranges" {
  description = "The source ranges to allow"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}
