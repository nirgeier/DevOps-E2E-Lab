# Terraform for local Kubernetes (using kind)
resource "null_resource" "kind_cluster" {
  provisioner "local-exec" {
    command = "kind create cluster --name devops-demo"
  }
}
