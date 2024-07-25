provider "google" {
  credentials = file("/var/lib/jenkins/.ssh/service-account-gcp.json")
  project     = var.project_id
  region      = var.region
}

module "network" {
  source       = "./modules/network"
  network_name = "vpc-network"
}

module "firewall" {
  source        = "./modules/firewall"
  firewall_name = "allow-http"
  network_name  = module.network.network_name
}

module "instance" {
  source         = "./modules/instance"
  instance_name  = "instance"
  zone           = var.zone
  network_name   = module.network.network_name
  startup_script = file("${path.module}/scripts/startup.sh")
}

module "storage" {
  source      = "./modules/storage"
  bucket_name = "${var.project_id}-assets"
  location    = var.region
}
