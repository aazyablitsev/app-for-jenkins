resource "google_storage_bucket" "static_assets" {
  name          = var.bucket_name
  location      = var.location
  force_destroy = var.force_destroy
}
