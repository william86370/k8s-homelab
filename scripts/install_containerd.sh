#!/bin/bash

# Ensure the script is run as root
if [ "$EUID" -ne 0 ]; then
  echo "Please run as root (use sudo or log in as root)"
  exit 1
fi

# Variables
export CONTAINERD_VERSION="latest"
export NERDCTL_VERSION="latest"
export RUNC_VERSION="latest"
export CNI_VERSION="latest"
export CRICTL_VERSION="latest"

# Function to fetch the latest release version from GitHub
get_latest_release() {
  curl --silent "https://api.github.com/repos/$1/releases/latest" | # Get latest release from GitHub API
    grep '"tag_name":' |                                            # Get tag line
    sed -E 's/.*"([^"]+)".*/\1/'                                    # Extract version number
}

# Determine the versions to install
if [ "$CONTAINERD_VERSION" == "latest" ]; then
  CONTAINERD_VERSION=$(get_latest_release "containerd/containerd")
fi

if [ "$NERDCTL_VERSION" == "latest" ]; then
  NERDCTL_VERSION=$(get_latest_release "containerd/nerdctl")
fi

if [ "$RUNC_VERSION" == "latest" ]; then
  RUNC_VERSION=$(get_latest_release "opencontainers/runc")
fi

if [ "$CNI_VERSION" == "latest" ]; then
  CNI_VERSION=$(get_latest_release "containernetworking/plugins")
fi
if [ "$CRICTL_VERSION" == "latest" ]; then
  CRICTL_VERSION=$(get_latest_release "kubernetes-sigs/cri-tools")
fi

CONTAINERD_VERSION_STRIPPED=${CONTAINERD_VERSION#v}
NERDCTL_VERSION_STRIPPED=${NERDCTL_VERSION#v}


# Update the package list and install only the required dependencies
apt-get update
apt-get install -y \
    ca-certificates \
    curl

# Install runc
curl -L "https://github.com/opencontainers/runc/releases/download/${RUNC_VERSION}/runc.arm64" -o runc
install -m 755 runc /usr/local/sbin/runc
rm -f runc  # Cleanup the runc binary


# if containerd is installed stop it
if [ -f /usr/local/bin/containerd ]; then
  echo "Stopping containerd"
  systemctl stop containerd
fi

# Install containerd
curl -L "https://github.com/containerd/containerd/releases/download/${CONTAINERD_VERSION}/containerd-${CONTAINERD_VERSION_STRIPPED}-linux-arm64.tar.gz" -o containerd.tar.gz
tar -C /usr/local -xzf containerd.tar.gz
rm -f containerd.tar.gz  # Cleanup the containerd tarball

# Download and install the systemd service file for containerd
curl -L "https://raw.githubusercontent.com/containerd/containerd/main/containerd.service" -o containerd.service
mv containerd.service /etc/systemd/system/containerd.service

# Reload the systemd daemon to recognize the new service file
systemctl daemon-reload
# Enable containerd but do not start it yet
systemctl enable containerd

# Install nerdctl
curl -L "https://github.com/containerd/nerdctl/releases/download/${NERDCTL_VERSION}/nerdctl-${NERDCTL_VERSION_STRIPPED}-linux-arm64.tar.gz" -o nerdctl.tar.gz
tar -C /usr/local/bin -xzf nerdctl.tar.gz
rm -f nerdctl.tar.gz  # Cleanup the nerdctl tarball

# create the containerd configuration file
mkdir -p /etc/containerd
containerd config default | tee /etc/containerd/config.toml >/dev/null 2>&1
# Configure containerd to use systemd as the cgroup driver
sed -i 's/SystemdCgroup = false/SystemdCgroup = true/' /etc/containerd/config.toml

# Install CNI plugins
mkdir -p /opt/cni/bin
curl -L "https://github.com/containernetworking/plugins/releases/download/${CNI_VERSION}/cni-plugins-linux-arm64-${CNI_VERSION}.tgz" -o cni-plugins.tgz
tar -C /opt/cni/bin -xzf cni-plugins.tgz
rm -f cni-plugins.tgz  # Cleanup the CNI plugins tarball
# Ensure the CNI plugins are owned by root https://github.com/cilium/cilium/issues/23838 https://github.com/cilium/cilium/issues/23838#issuecomment-1434480322 
chown -R root:root /opt/cni/bin

# Download and install crictl
curl -L "https://github.com/kubernetes-sigs/cri-tools/releases/download/${CRICTL_VERSION}/crictl-${CRICTL_VERSION}-linux-arm64.tar.gz" -o crictl.tar.gz
tar -C /usr/local/bin -xzf crictl.tar.gz
rm -f crictl.tar.gz  # Cleanup the crictl tarball


# Now start containerd with the proper configuration
systemctl start containerd

echo "containerd, runc, nerdctl, and CNI plugins installation complete."
