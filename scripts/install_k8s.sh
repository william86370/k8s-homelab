
#!/bin/bash


# Variables
export K8S_VERSION="v1.31"

# Update the apt package index and install packages needed for apt to use a repository over HTTPS
apt-get update
apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg


curl -fsSL https://pkgs.k8s.io/core:/stable:/${K8S_VERSION}/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
sudo chmod 644 /etc/apt/keyrings/kubernetes-apt-keyring.gpg # allow unprivileged APT programs to read this keyring

# This overwrites any existing configuration in /etc/apt/sources.list.d/kubernetes.list
echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/${K8S_VERSION}/deb/ /" | sudo tee /etc/apt/sources.list.d/kubernetes.list
sudo chmod 644 /etc/apt/sources.list.d/kubernetes.list   # helps tools such as command-not-found to work correctly

# Update apt package index with the new repository and install kubelet, kubeadm, and kubectl
apt-get update
apt-get install -y kubelet kubeadm kubectl

# Prevent these packages from being automatically updated
apt-mark hold kubelet kubeadm kubectl

sudo systemctl enable --now kubelet

echo "kubeadm, kubectl, and kubelet installation complete."