# MetalLB

Load Balancer pour bare-metal. Attribue des IPs LAN aux services de type `LoadBalancer`.

- **Chart** : `metallb/metallb`
- **Namespace** : `metallb-system`
- **Mode** : Layer 2 (ARP)
- **Pool** : `192.168.1.60-192.168.1.70`

## Installation

### 1. Ajouter le repo Helm

```bash
helm repo add metallb https://metallb.github.io/metallb
helm repo update
```

### 2. Créer le namespace avec labels PodSecurity

MetalLB speaker nécessite host network + NET_RAW. Le namespace doit être en mode `privileged` **avant** l'installation :

```bash
kubectl create namespace metallb-system
kubectl label namespace metallb-system pod-security.kubernetes.io/enforce=privileged pod-security.kubernetes.io/audit=privileged pod-security.kubernetes.io/warn=privileged
```

### 3. Installer MetalLB

```bash
helm install metallb metallb/metallb \
  --namespace metallb-system \
  --wait --timeout 5m
```

### 4. Appliquer la config (pool + L2)

```bash
kubectl apply -f talos/metallb/pool.yaml
```

### 5. Vérifier

```bash
kubectl -n metallb-system get pods
kubectl get ipaddresspool -n metallb-system
```

## Mise à jour

```bash
helm repo update
helm upgrade metallb metallb/metallb \
  --namespace metallb-system \
  --wait
```

## Désinstallation

```bash
kubectl delete -f talos/metallb/pool.yaml
helm uninstall metallb -n metallb-system
kubectl delete namespace metallb-system
```
