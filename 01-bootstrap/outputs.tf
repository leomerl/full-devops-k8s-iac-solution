resource "local_file" "backend_bucket" {
  content  = "${var.project_name}-test-bucket"
  filename = "../backend_bucket.txt"
}

output "state_bucket_name" {
  value = module.state_bucket.bucket_id
  
}
