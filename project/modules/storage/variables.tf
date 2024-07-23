variable "bucket_name" {
  description = "The name of the storage bucket"
}

variable "location" {
  description = "The location of the storage bucket"
}

variable "force_destroy" {
  description = "Force destroy the bucket on deletion"
  default     = true
}
