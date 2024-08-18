curl -s https://fluxcd.io/install.sh | sudo FLUX_VERSION=2.0.0 bash
# Install Flux
flux install --components="source-controller,kustomize-controller,helm-controller" --export > install/flux/flux-system.yaml