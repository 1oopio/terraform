#/bin/bash

# get cluster name from user input 
read -p "Enter cluster name: " cluster_name

cfg=$(terraform output -json | jq -r --arg clusterName "$cluster_name" '.kubeconfigs.value[$clusterName]')

if [ -z "$cfg" ] || [ "$cfg" = null ]; then
    echo "Cluster $cluster_name not found!"
    exit 1
fi

echo -e "$cfg"
