variable "exoscale_key" {
  type = string
  description = "Exoscale API key"
}
variable "exoscale_secret" {
  type = string
  description = "Exoscale API secret"
}
variable "exoscale_zone" {
  type = string
  description = "Exoscale zone"
  default = "at-vie-1"
}
variable "admin_ip" {
  type = string
  description = "IP for SSH access"
  default = ""
}
variable "sshkey" {
  type = string
  description = "SSH key in OpenSSH format"
  default = ""
}