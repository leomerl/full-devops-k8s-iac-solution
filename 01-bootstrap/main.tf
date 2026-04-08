
module "state_bucket" {
  source            = "../modules/state-bucket"
  state_bucket_name = "${var.project_name}-test-bucket"
}