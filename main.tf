terraform {
  required_providers {
    libvirt = {
      source = "dmacvicar/libvirt"
    }
  }
}

provider "libvirt" {
  uri = var.libvirt_provider_uri
}

# Cloud-Init Config for each master node
resource "libvirt_cloudinit_disk" "cloudinit_master" {
  count = var.count_master
  name  = format(var.cloudinit_master_volume_name_base, count.index + 1)
  pool  = var.volume_pool

  user_data      = data.template_file.user_data_master[count.index].rendered
  network_config = data.template_file.network_config_master[count.index].rendered
}

# Cloud-Init Config for each worker node
resource "libvirt_cloudinit_disk" "cloudinit_worker" {
  count = var.count_worker
  name  = format(var.cloudinit_worker_volume_name_base, count.index + 1)
  pool  = var.volume_pool

  user_data      = data.template_file.user_data_worker[count.index].rendered
  network_config = data.template_file.network_config_worker[count.index].rendered
}

# Cloud-Init Config for loadbalancer
resource "libvirt_cloudinit_disk" "cloudinit_lb" {
  count = var.count_lb
  name  = format(var.cloudinit_lb_volume_name_base, count.index + 1)
  pool  = var.volume_pool

  user_data      = data.template_file.user_data_lb[count.index].rendered
  network_config = data.template_file.network_config_lb[count.index].rendered
}

# Template for master cloud-init user_data
data "template_file" "user_data_master" {
  count    = var.count_master
  template = file("${path.module}/cloud_init_master.cfg")

  vars = {
    hostname                           = format(var.hostname_master, count.index + 1)
    node_count                         = var.count_master
    hostname_first_master              = format(var.base_name_master, 1)
    hostname_all_masters               = join(",", [for i in range(var.count_master) : format(var.base_name_master, i + 1)])
    control_plane_endpoint             = format("%s%d:%d", var.base_ips["iface2"], var.ip_last_octave_base_master - 1, var.control_plane_port)
    pod_network_cidr                   = format("%s%d/16", var.base_ips["iface1"], 0)
    control_plane_deploy_path          = var.control_plane_deploy_path
    non_root_user                      = var.non_root_user
    ip_first_master                    = join("", [var.base_ips["iface2"], var.ip_last_octave_base_master])
    first_master_deploy_check_interval = var.first_master_deploy_check_interval
  }
}

# Template for worker cloud-init user_data
data "template_file" "user_data_worker" {
  count    = var.count_worker
  template = file("${path.module}/cloud_init_worker.cfg")

  vars = {
    hostname                           = format(var.hostname_worker, count.index + 1)
    node_count                         = var.count_worker
    control_plane_deploy_path          = var.control_plane_deploy_path
    non_root_user                      = var.non_root_user
    ip_first_master                    = join("", [var.base_ips["iface2"], var.ip_last_octave_base_master])
    first_master_deploy_check_interval = var.first_master_deploy_check_interval
    control_plane_endpoint             = format("%s%d:%d", var.base_ips["iface2"], var.ip_last_octave_base_master - 1, var.control_plane_port)

    #hostname_all_workers   = join(",", [for i in range(var.count_worker) : format(var.base_name_worker, i + 1)])
  }
}

# Template for loadbalancer cloud-init user_data
data "template_file" "user_data_lb" {
  count    = var.count_lb
  template = file("${path.module}/cloud_init_lb.cfg")

  vars = {
    hostname   = format(var.hostname_lb, count.index + 1)
    node_count = var.count_lb
  }
}

# Template for master network configuration
data "template_file" "network_config_master" {
  count    = var.count_master
  template = file("${path.module}/network_config_master.cfg")

  vars = {
    iface1_name = var.iface_names["iface1"]
    iface2_name = var.iface_names["iface2"]

    iface1_ip = format("%s%d/16", var.base_ips["iface1"], count.index + var.ip_last_octave_base_master)
    iface2_ip = format("%s%d/24", var.base_ips["iface2"], count.index + var.ip_last_octave_base_master)

    iface1_gateway_ip = var.gateway_ips["iface1"]
    iface2_gateway_ip = var.gateway_ips["iface2"]

    dns_servers_ip = var.dns_servers
  }
}

# Template for worker network configuration
data "template_file" "network_config_worker" {
  count    = var.count_worker
  template = file("${path.module}/network_config_worker.cfg")

  vars = {
    iface1_name = var.iface_names["iface1"]
    iface2_name = var.iface_names["iface2"]

    iface1_ip = format("%s%d/16", var.base_ips["iface1"], count.index + var.ip_last_octave_base_worker)
    iface2_ip = format("%s%d/24", var.base_ips["iface2"], count.index + var.ip_last_octave_base_worker)

    iface1_gateway_ip = var.gateway_ips["iface1"]
    iface2_gateway_ip = var.gateway_ips["iface2"]

    dns_servers_ip = var.dns_servers
  }
}

# Template for loadbalancer network configuration
data "template_file" "network_config_lb" {
  count    = var.count_lb
  template = file("${path.module}/network_config_lb.cfg")

}

# Download Cloud Image (shared volume template)
resource "libvirt_volume" "vm_base_image" {
  name   = var.base_volume_name
  pool   = var.volume_pool
  source = var.cloud_image_location
  format = var.volume_format
}

# Create separate OS volume for each master node
resource "libvirt_volume" "node_volume_master" {
  count  = var.count_master
  name   = format(var.node_volume_name_base_master, count.index + 1)
  pool   = var.volume_pool
  source = "${var.volume_pool_path}/${libvirt_volume.vm_base_image.name}"
  format = var.volume_format
}

# Create separate OS volume for each worker node
resource "libvirt_volume" "node_volume_worker" {
  count  = var.count_worker
  name   = format(var.node_volume_name_base_worker, count.index + 1)
  pool   = var.volume_pool
  source = "${var.volume_pool_path}/${libvirt_volume.vm_base_image.name}"
  format = var.volume_format
}

# Create separate OS volume for each worker node
resource "libvirt_volume" "node_volume_lb" {
  count  = var.count_lb
  name   = format(var.node_volume_name_base_lb, count.index + 1)
  pool   = var.volume_pool
  source = "${var.volume_pool_path}/${libvirt_volume.vm_base_image.name}"
  format = var.volume_format
}

# Resize master VM volumes after creation
resource "null_resource" "resize_volume_master" {
  count = var.count_master

  triggers = {
    volume = libvirt_volume.node_volume_master[count.index].id
  }

  provisioner "local-exec" {
    command = <<EOT
      qemu-img resize ${var.volume_pool_path}/${libvirt_volume.node_volume_master[count.index].name} ${var.node_volume_master_size}G
    EOT
  }
}

# Resize worker VM volumes after creation
resource "null_resource" "resize_volume_worker" {
  count = var.count_master

  triggers = {
    volume = libvirt_volume.node_volume_worker[count.index].id
  }

  provisioner "local-exec" {
    command = <<EOT
      qemu-img resize ${var.volume_pool_path}/${libvirt_volume.node_volume_worker[count.index].name} ${var.node_volume_worker_size}G
    EOT
  }
}

# Create master VM instances
resource "libvirt_domain" "node_master" {
  count   = var.count_master
  name    = format(var.base_name_master, count.index + 1)
  memory  = var.memory_master
  vcpu    = var.vcpus_master
  machine = var.vm_machine_type

  cpu {
    mode = var.vm_cpu_mode
  }

  # Attach a separate OS volume for each node based on base image
  disk {
    volume_id = libvirt_volume.node_volume_master[count.index].id
  }

  xml {
    xslt = file("cdrom-model.xsl")
  }

  # Cloud-Init Configuration
  cloudinit = libvirt_cloudinit_disk.cloudinit_master[count.index].id

  # Network Interfaces
  network_interface {
    network_name = var.networks["network1"]
    addresses    = [format("%s%d", var.base_ips["iface1"], count.index + var.ip_last_octave_base_master)]
  }

  network_interface {
    network_name = var.networks["network2"]
    addresses    = [format("%s%d", var.base_ips["iface2"], count.index + var.ip_last_octave_base_master)]
  }

  console {
    type        = var.vm_console["type"]
    target_port = var.vm_console["target_port"]
    target_type = var.vm_console["target_type"]
  }

  graphics {
    type        = var.vm_graphics["type"]
    listen_type = var.vm_graphics["listen_type"]
  }
}

# Create worker VM instances
resource "libvirt_domain" "node_worker" {
  count   = var.count_worker
  name    = format(var.base_name_worker, count.index + 1)
  memory  = var.memory_worker
  vcpu    = var.vcpus_worker
  machine = var.vm_machine_type

  cpu {
    mode = var.vm_cpu_mode
  }

  # Attach a separate OS volume for each node based on base image
  disk {
    volume_id = libvirt_volume.node_volume_worker[count.index].id
  }

  xml {
    xslt = file("cdrom-model.xsl")
  }

  # Cloud-Init Configuration
  cloudinit = libvirt_cloudinit_disk.cloudinit_worker[count.index].id

  # Network Interfaces
  network_interface {
    network_name = var.networks["network1"]
    addresses    = [format("%s%d", var.base_ips["iface1"], count.index + var.ip_last_octave_base_worker)]
  }

  network_interface {
    network_name = var.networks["network2"]
    addresses    = [format("%s%d", var.base_ips["iface2"], count.index + var.ip_last_octave_base_worker)]
  }

  console {
    type        = var.vm_console["type"]
    target_port = var.vm_console["target_port"]
    target_type = var.vm_console["target_type"]
  }

  graphics {
    type        = var.vm_graphics["type"]
    listen_type = var.vm_graphics["listen_type"]
  }
}

# Create loadbalancer VM instances
resource "libvirt_domain" "node_lb" {
  count   = var.count_lb
  name    = format(var.base_name_lb, count.index + 1)
  memory  = var.memory_lb
  vcpu    = var.vcpus_lb
  machine = var.vm_machine_type

  cpu {
    mode = var.vm_cpu_mode
  }

  # Attach a separate OS volume for each node based on base image
  disk {
    volume_id = libvirt_volume.node_volume_lb[count.index].id
  }

  xml {
    xslt = file("cdrom-model.xsl")
  }

  # Cloud-Init Configuration
  cloudinit = libvirt_cloudinit_disk.cloudinit_lb[count.index].id

  # Network Interfaces
  network_interface {
    network_name = var.networks["network2"]
    addresses    = ["10.8.60.10"]
  }

  console {
    type        = var.vm_console["type"]
    target_port = var.vm_console["target_port"]
    target_type = var.vm_console["target_type"]
  }

  graphics {
    type        = var.vm_graphics["type"]
    listen_type = var.vm_graphics["listen_type"]
  }
}

# Delete base volume once everything is done
resource "null_resource" "cleanup_base_volume" {
  depends_on = [libvirt_domain.node_master, libvirt_domain.node_worker, libvirt_domain.node_lb]

  provisioner "local-exec" {
    command = "sudo virsh vol-delete --pool ${var.volume_pool} ${var.base_volume_name}"
  }
}
