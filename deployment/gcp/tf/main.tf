module "service_account" {
  source     = "terraform-google-modules/service-accounts/google"
  version    = "4.2.1"
  project_id = var.project_id
  prefix     = "sa-cloud-run"
  names      = ["pymovies"]
}

module "cloud_run" {
  source                = "GoogleCloudPlatform/cloud-run/google"
  version               = "0.9.1"
  service_name          = "pymovies"
  project_id            = var.project_id
  location              = "us-central1"
  image                 = var.image_id
  service_account_email = module.service_account.email
  members               = ["allUsers"]
}