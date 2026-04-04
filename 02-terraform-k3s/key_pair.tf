resource "tls_private_key" "k3s" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "k3s" {
  key_name   = "${var.cluster_name}-key"
  public_key = tls_private_key.k3s.public_key_openssh
}

resource "local_sensitive_file" "private_key" {
  content         = tls_private_key.k3s.private_key_pem
  filename        = "${path.module}/${var.cluster_name}.pem"
  file_permission = "0600"
}
