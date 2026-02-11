# Literaly adding this line with no purpose in order to test some Github functionalities.

# QEMU/Libvirt connection
variable "libvirt_provider_uri" {
  default = "qemu:///system"
}

# Number of master nodes in the cluster
variable "count_master" {
  default = 2
}

# Number of worker nodes in the cluster
variable "count_worker" {
  default = 2
}

# Number of loadbalancers in the cluster
variable "count_lb" {
  default = 1
}

######## VMs/Nodes configuration ########

# Image/volumes configuration
variable "base_volume_name" {
  default = "k8s-ubuntu-24-04-base.qcow2"
}

variable "cloud_image_location" {
  # This could be either local path or direct download URL
  default = "/home/Virtual_Machines/datastore-isos/noble-server-cloudimg-amd64.img"
}

variable "node_volume_name_base_master" {
  default = "k8s-ubuntu-master%02d-ubuntu-24-04.qcow2"
}

variable "node_volume_name_base_worker" {
  default = "k8s-ubuntu-worker%02d-ubuntu-24-04.qcow2"
}

variable "node_volume_name_base_lb" {
  default = "k8s-ubuntu-lb%02d-ubuntu-24-04.qcow2"
}

variable "node_volume_master_size" {
  default = 40
}

variable "node_volume_worker_size" {
  default = 40
}

variable "cloudinit_master_volume_name_base" {
  default = "k8s-ubuntu-master%02d-cloudinit.iso"
}

variable "cloudinit_worker_volume_name_base" {
  default = "k8s-ubuntu-worker%02d-cloudinit.iso"
}

variable "cloudinit_lb_volume_name_base" {
  default = "k8s-ubuntu-lb%02d-cloudinit.iso"
}

variable "volume_pool" {
  default = "OpenStack"
}

variable "volume_pool_path" {
  default = "/home/WDNVMe-500GB/OpenStack"
}

variable "volume_format" {
  default = "qcow2"
}
################################

# VM configuration
variable "hostname_master" {
  default = "k8s-ubuntu-master%02d"
}

variable "hostname_worker" {
  default = "k8s-ubuntu-worker%02d"
}

variable "hostname_lb" {
  default = "k8s-ubuntu-lb%02d"
}

variable "base_name_master" {
  default = "k8s-ubuntu-master%02d"
}

variable "base_name_worker" {
  default = "k8s-ubuntu-worker%02d"
}

variable "base_name_lb" {
  default = "k8s-ubuntu-lb%02d"
}

variable "memory_master" {
  default = 4 * 1024
}

variable "memory_worker" {
  default = 4 * 1024
}

variable "memory_lb" {
  default = 2 * 1024
}

variable "vcpus_master" {
  default = 2
}

variable "vcpus_worker" {
  default = 2
}

variable "vcpus_lb" {
  default = 1
}

variable "vm_machine_type" {
  default = "q35"
}

variable "vm_cpu_mode" {
  default = "host-passthrough"
}

variable "vm_console" {
  default = {
    type        = "pty"
    target_port = "0"
    target_type = "serial"
  }
}

variable "vm_graphics" {
  default = {
    type        = "vnc"
    listen_type = "address"
  }
}

######## VMs/Nodes configuration########

#### NETWORKING ######
# Network names
variable "networks" {
  default = {
    network1 = "K8s"
    network2 = "Public"
  }
}

# Base IP addresses
variable "iface_names" {
  default = {
    iface1 = "enp1s0"
    iface2 = "enp2s0"
  }
}

# Base IP addresses
variable "base_ips" {
  default = {
    iface1 = "10.244.0."
    iface2 = "10.8.60."
  }
}

# Gateway IP addresses
variable "gateway_ips" {
  default = {
    iface1 = ""
    iface2 = "10.8.60.1"
  }
}

variable "dns_servers" {
  default = "[9.9.9.9, 1.1.1.1]"
}

variable "ip_last_octave_base_master" {
  default = 11
}

variable "ip_last_octave_base_worker" {
  default = 21
}

variable "control_plane_port" {
  default = 6443
}
#### NETWORKING ######

variable "control_plane_deploy_path" {
  default = "/root/deployment"
}

variable "non_root_user" {
  default = "k8s"
}

variable "first_master_deploy_check_interval" {
  default = 5
}
