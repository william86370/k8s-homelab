#!/bin/bash

# File: disable_wlan0.sh
# Purpose: Disable the WiFi on wlan0 interface

# Ensure the script is run as root
if [ "$(id -u)" -ne 0 ]; then
   echo "This script must be run as root" 
   exit 1
fi

# Bring down the wlan0 interface
ip link set dev wlan0 down

# Optionally, you can disable wlan0 at boot by modifying the netplan config
cat <<EOT > /etc/netplan/01-netcfg.yaml
network:
  version: 2
  renderer: networkd
  ethernets:
    eth0:
      dhcp4: true
  wifis:
    wlan0:
      dhcp4: false
      renderer: networkd
      optional: true
EOT

# Apply the new netplan configuration
netplan apply

echo "wlan0 has been disabled."
