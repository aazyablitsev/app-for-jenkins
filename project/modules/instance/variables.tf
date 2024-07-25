variable "instance_name" {
  description = "The name of the instance"
}

variable "machine_type" {
  description = "The machine type of the instance"
  default     = "e2-micro"
}

variable "zone" {
  description = "The zone to deploy the instance"
}

variable "image" {
  description = "The image to use for the instance"
  default     = "ubuntu-os-cloud/ubuntu-2004-lts"
}

variable "network_name" {
  description = "The VPC network to attach the instance"
}

variable "startup_script" {
  description = "The startup script for the instance"
  default     = ""
}
