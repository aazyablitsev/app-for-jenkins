terraform {
  backend "gcs" {
    bucket = "aazyablicev-terraform-state"
    prefix = "terraform/state"
  }
}
