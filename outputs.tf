# First master node hostname
output "hostname_first_master" {
  value = libvirt_domain.node_master[0].name
}

# All master nodes hostnames
output "hostname_all_masters" {
  value = [for master in libvirt_domain.node_master : master.name]
}

# All worker node hostnames
output "hostname_all_workers" {
  value = [for worker in libvirt_domain.node_worker : worker.name]
}
