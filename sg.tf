resource "exoscale_security_group" "autoscaling" {
  name = "autoscaling"
}

resource "exoscale_security_group_rules" "autoscaling" {
  security_group_id = exoscale_security_group.autoscaling.id

  ingress {
    cidr_list = ["0.0.0.0/0"]
    ports = ["80", "3000", "8080", "9090"]
    protocol = "tcp"
    description = "External"
  }
  ingress {
    user_security_group_list = [exoscale_security_group.autoscaling.name]
    ports = ["1-65535"]
    protocol = "tcp"
    description = "Internal"
  }
}
