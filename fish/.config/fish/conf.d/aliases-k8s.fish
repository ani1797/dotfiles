# ~/.config/fish/conf.d/aliases-k8s.fish
# Kubernetes aliases (only if kubectl is installed)

if type -q kubectl
    alias k='kubectl'
    alias kgp='kubectl get pods'
    alias kgs='kubectl get svc'
    alias kga='kubectl get all'
    alias kd='kubectl describe'
    alias klogs='kubectl logs -f'
    alias kexec='kubectl exec -it'

    # Completions
    kubectl completion fish | source
end
