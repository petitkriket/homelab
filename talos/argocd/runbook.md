# ArgoCD

GitOps continuous delivery pour le cluster Talos.
Fait le choix de ArgoCD pour sa popularité. (FluxCD est une alternative mais sans UI et n'est pas utilisée dans l'entreprise)
[article dedié](https://institute.sfeir.com/fr/formation-kubernetes/deploiement-et-mise-en-production-kubernetes/argocd-vs-fluxcd-outil-gitops-kubernetes/
)
- **Chart** : `argo/argo-cd` v9.6.0 (app v3.4.4)
- **Namespace** : `argocd`
- **Accès UI** : NodePort HTTPS sur port `30443`
- **Référence** : [Guide d'installation - Stéphane Robert](https://blog.stephane-robert.info/docs/pipeline-cicd/argocd/installation/)

## Installation

### 1. Ajouter le repo Helm

```bash
helm repo add argo https://argoproj.github.io/argo-helm
helm repo update
```

### 2. Installer ArgoCD

```bash
cd ~/homelab
helm install argocd argo/argo-cd \
  --namespace argocd --create-namespace \
  --values talos/argocd/values.yaml \
  --wait --timeout 5m
```

### 3. Récupérer le mot de passe admin

```bash
kubectl -n argocd get secret argocd-initial-admin-secret \
  -o jsonpath="{.data.password}" | base64 -d
```

### 4. Accéder à l'UI

```bash
# Option A : NodePort (depuis le réseau local)
https://192.168.1.87:30443

# Option B : port-forward (depuis le Mac)
kubectl port-forward svc/argocd-server -n argocd 8080:443
# puis https://localhost:8080
```

Login : `admin` / mot de passe de l'étape 3.

## Mise à jour

```bash
helm repo update
helm upgrade argocd argo/argo-cd \
  --namespace argocd \
  --values talos/argocd/values.yaml \
  --wait
```

## Désinstallation

```bash
helm uninstall argocd -n argocd
kubectl delete namespace argocd
```
