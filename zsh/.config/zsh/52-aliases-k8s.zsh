# ~/.config/zsh/52-aliases-k8s.zsh
# Kubernetes aliases (only if kubectl is installed)

if command -v kubectl &>/dev/null; then
  alias k="kubectl"
  alias kgp="kubectl get pods"
  alias kgs="kubectl get svc"
  alias kga="kubectl get all"
  alias kd="kubectl describe"
  alias klogs="kubectl logs -f"
  alias kexec="kubectl exec -it"
fi
