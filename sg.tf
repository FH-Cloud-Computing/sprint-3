resource "exoscale_security_group" "autoscaling" {
  name = "autoscaling"
  description = "Managed by Terraform!"
}

resource "exoscale_security_group_rules" "autoscaling" {
  security_group_id = exoscale_security_group.autoscaling.id

  ingress {
    cidr_list = ["0.0.0.0/0"]
    ports = ["8080"]
    protocol = "tcp"
    description = "HTTP"
  }
}
