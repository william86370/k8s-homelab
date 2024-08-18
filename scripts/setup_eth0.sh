# Raspberry pi scripts to configure eth0 to use DHCP
# Ensure the script is run as root
if [ "$(id -u)" -ne 0 ]; then
   echo "This script must be run as root" 
   exit 1
fi

# Bring down the eth0 interface
ip link set dev eth0 down

# Configure eth0 to use DHCP
cat <<EOT > /etc/netplan/11-eth0.yaml
network:
  version: 2
  renderer: networkd
  ethernets:
    eth0:
      dhcp4: true
EOT

# Apply the new netplan configuration
netplan apply

echo "eth0 is now configured to use DHCP."