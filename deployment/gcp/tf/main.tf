module "service_account" {
  source     = "terraform-google-modules/service-accounts/google"
  version    = "4.2.1"
  project_id = var.project_id
  prefix     = "sa-cloud-run"
  names      = ["simple"]
}

module "cloud_run" {
  source                = "GoogleCloudPlatform/cloud-run/google"
  version               = "0.9.1"
  service_name          = "ci-cloud-run"
  project_id            = var.project_id
  location              = "us-central1"
  image                 = "gcr.io/golang-389808/pymovies"
  service_account_email = module.service_account.email
  members               = ["allUsers"]
}