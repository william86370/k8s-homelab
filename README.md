# k8s-homelab


flux get all -A --status-selector ready=true



```bash 
ns() {
    if [ -z "$1" ]; then
        echo "Usage: ns <namespace>"
        return 1
    fi
    kubectl config set-context --current --namespace="$1"
}
_ns_autocomplete() {
    local cur prev words cword
    _init_completion || return

    if [[ ${cword} -eq 1 ]]; then
        COMPREPLY=( $(kubectl get namespaces -o jsonpath='{.items[*].metadata.name}' 2>/dev/null | tr ' ' '\n' | grep "^${cur}") )
    fi
}
complete -F _ns_autocomplete ns
```