VM_NAME="hw-rpm"
yc compute instance create \
  --name $VM_NAME \
  --hostname $VM_NAME \
  --zone ru-central1-b \
  --network-interface subnet-name=default-ru-central1-b,nat-ip-version=ipv4 \
  --create-boot-disk image-folder-id=standard-images,image-family=almalinux-9 \
  --memory 2G \
  --cores 2 \
  --core-fraction 5 \
  --preemptible \
  --ssh-key ~/.ssh/id_rsa.pub
EXTERNAL_IP=$(yc compute instance get $VM_NAME --format json | jq -r '.network_interfaces[].primary_v4_address.one_to_one_nat.address')
echo "VM external IP: $EXTERNAL_IP"
yq -i ".webservers.hosts.hw-rpm.ansible_host = \"$EXTERNAL_IP\"" rpm-create/inventory/hosts