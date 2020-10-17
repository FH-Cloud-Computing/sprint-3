resource "exoscale_security_group" "autoscaling" {
  name = "autoscaling"
  description = "Managed by Terraform!"
}

resource "exoscale_security_group_rules" "autoscaling" {
  security_group_id = exoscale_security_group.autoscaling.id

  # Allow HTTP and Prometheus ingress
  ingress {
    cidr_list = ["0.0.0.0/0"]
    ports = ["3000", "8080", "9090"]
    protocol = "tcp"
    description = "External"
  }
  # Allow traffic within the security group
  ingress {
    user_security_group_list = [exoscale_security_group.autoscaling.name]
    ports = ["1-65535"]
    protocol = "tcp"
    description = "Internal"
  }
}
