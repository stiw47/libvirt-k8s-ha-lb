#!/bin/bash

hostname_first_master="${hostname_first_master}"
hostname_all_masters="${hostname_all_masters}"
hostname=$(hostname)
control_plane_endpoint="${control_plane_endpoint}"
pod_network_cidr="${pod_network_cidr}"
deploy_path="${control_plane_deploy_path}"
non_root_user="${non_root_user}"

if [ "$hostname" == "$hostname_first_master" ]; then
    mkdir "$deploy_path"
    kubeadm init --control-plane-endpoint="$control_plane_endpoint" --pod-network-cidr="$pod_network_cidr" --upload-certs > "$deploy_path/deployment_output.log"
    sudo -u "$non_root_user" mkdir -p $HOME/.kube
    cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
    chown $(non_root_user):$(id -g "$non_root_user") "$(sudo -u $non_root_user echo $HOME)/.kube/config"

#elif echo "$masters" | grep -wq "$hostname"; then
#    echo "This is another master node. Running other-masters setup..."
#    # Run remaining master-specific commands here
#elif echo "$workers" | grep -wq "$hostname"; then
#    echo "This is a worker node. Running worker setup..."
#    # Run worker-specific commands here
else
    echo "Unknown role for this node."
fi
