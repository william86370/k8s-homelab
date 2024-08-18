# script for autocomplete
#

sudo apt-get install bash-completion -y
source /usr/share/bash-completion/bash_completion

echo 'source <(kubectl completion bash)' >>~/.bashrc

echo 'alias k=kubectl' >>~/.bashrc
echo 'complete -o default -F __start_kubectl k' >>~/.bashrc
source ~/.bashrc


# flux autocomplete
echo 'source <(flux completion bash)' >>~/.bashrc
source ~/.bashrc