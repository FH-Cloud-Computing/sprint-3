resource "exoscale_instance_pool" "autoscaling" {
  name = "autoscaling"
  service_offering = "micro"
  size = 2
  disk_size = 10
  template_id = data.exoscale_compute_template.ubuntu.id
  zone = var.exoscale_zone
  key_pair = "janoszen-desktop"
  security_group_ids = [exoscale_security_group.autoscaling.id]

  user_data = <<EOF
#!/bin/bash

set -e

curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

# Run the load generator
docker run -d \
  --restart=always \
  -p 8080:8080 \
  janoszen/http-load-generator:1.0.1

# Run the node exporter
docker run -d \
  --restart=always \
  --net="host" \
  --pid="host" \
  -v "/:/host:ro,rslave" \
  quay.io/prometheus/node-exporter \
  --path.rootfs=/host
EOF

  lifecycle {
    ignore_changes = [
      size
    ]
  }
}