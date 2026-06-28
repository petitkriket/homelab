# Traefik

Ingress controller — point d'entrée central pour tout le trafic (LAN + tunnel).

- **Chart** : `traefik/traefik`
- **Namespace** : `traefik`
- **Service** : LoadBalancer (IP attribuée par MetalLB)

## Installation

### 1. Ajouter le repo Helm

```bash
helm repo add traefik https://traefik.github.io/charts
helm repo update
```

### 2. Installer les CRDs Gateway API (prérequis)

L'installation de Traefik nécessite les CRDs Gateway API et ne passe pas sans.
https://gateway-api.sigs.k8s.io/guides/getting-started/introduction/#install-standard-channel
```bash
kubectl apply --server-side -f https://github.com/kubernetes-sigs/gateway-api/releases/download/v1.5.0/standard-install.yaml
```

### 3. Installer Traefik

Les values sont tirées de cette documentation : https://doc.traefik.io/traefik/getting-started/kubernetes/

```bash
helm install traefik traefik/traefik \
  --namespace traefik --create-namespace \
  --values talos/traefik/values.yaml \
  --wait --timeout 5m
```

### 4. Vérifier

```bash
kubectl -n traefik get pods
kubectl -n traefik get svc traefik
```

Le service doit avoir une `EXTERNAL-IP` dans la plage MetalLB (`192.168.1.60-70`).

### 5. Accéder au dashboard

```bash
kubectl port-forward -n traefik deployment/traefik 9000:8080
# puis http://localhost:9000/dashboard/
```

## Mise à jour

```bash
helm repo update
helm upgrade traefik traefik/traefik \
  --namespace traefik \
  --values talos/traefik/values.yaml \
  --wait
```

## Désinstallation

```bash
helm uninstall traefik -n traefik
kubectl delete namespace traefik
```
