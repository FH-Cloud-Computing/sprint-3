resource "exoscale_compute" "monitoring" {
  disk_size = 10
  display_name = "monitoring"
  template_id = data.exoscale_compute_template.ubuntu.id
  size = "Small"
  zone = var.exoscale_zone
  security_group_ids = [exoscale_security_group.autoscaling.id]
  key_pair = ""

  user_data = templatefile("monitoring-userdata.sh.tpl", {
    exoscale_key=var.exoscale_key
    exoscale_secret=var.exoscale_secret
    exoscale_zone_id=var.exoscale_zone_id
    instance_pool_id=exoscale_instance_pool.autoscaling.id
    grafana_dashboard=file("grafana-dashboard.json")
    grafana_notifier=file("grafana-notifier.yaml")
  })
}