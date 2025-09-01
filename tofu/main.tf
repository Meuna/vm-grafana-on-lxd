terraform {
  required_providers {
    lxd = {
      source  = "terraform-lxd/lxd"
      version = "2.5.0"
    }
  }
}

provider "lxd" {
}

variable "ssh_pub_path" {
  type    = string
  default = "~/.ssh/id_rsa.pub"
}

resource "lxd_project" "vmgraf" {
  name        = "vm-grafana"
  description = "VictoriaMetrics and Grafana PoC"
  config = {
    "features.storage.volumes" = true
    "features.images"          = false
    "features.networks"        = false
    "features.profiles"        = true
    "features.storage.buckets" = true
  }
}

resource "lxd_network" "vmgraf" {
  name = "vm-grafana"

  config = {
    "ipv4.nat"     = "true"
    "ipv6.address" = "none"
    "dns.domain"   = "vmgraf.local"
  }
}

resource "lxd_storage_pool" "vmgraf" {
  project = lxd_project.vmgraf.name
  name    = "vm-grafana"
  driver  = "dir"
}

resource "lxd_profile" "vmgraf" {
  project = lxd_project.vmgraf.name
  name    = "vm-grafana"

  device {
    name = "eth0"
    type = "nic"

    properties = {
      nictype = "bridged"
      parent  = lxd_network.vmgraf.name
    }
  }

  device {
    type = "disk"
    name = "root"

    properties = {
      pool = lxd_storage_pool.vmgraf.name
      path = "/"
    }
  }

  config = {
    "cloud-init.user-data" : templatefile("cloud-init.yaml.tftpl", { ssh_pub = file(var.ssh_pub_path) })
  }
}

resource "lxd_instance" "krb5" {
  project  = lxd_project.vmgraf.name
  name     = "vm"
  image    = "ubuntu:24.04"
  type     = "virtual-machine"
  profiles = [lxd_profile.vmgraf.name]
}

resource "lxd_instance" "nfs" {
  project  = lxd_project.vmgraf.name
  name     = "grafana"
  image    = "ubuntu:24.04"
  type     = "virtual-machine"
  profiles = [lxd_profile.vmgraf.name]
}

resource "lxd_instance" "client" {
  project  = lxd_project.vmgraf.name
  name     = "scrapped"
  image    = "ubuntu:24.04"
  type     = "virtual-machine"
  profiles = [lxd_profile.vmgraf.name]
}
