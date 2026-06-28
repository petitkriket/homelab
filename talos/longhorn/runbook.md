# Longhorn

Stockage distribué — fournit des PersistentVolumes pour les workloads stateful (PostgreSQL, Keycloak, etc.).

- **Chart** : `longhorn/longhorn`
- **Namespace** : `longhorn-system`
- **Référence** : https://longhorn.io/docs/1.12.0/deploy/install/install-with-helm/

## Prérequis Talos

Les extensions `iscsi-tools` et `util-linux-tools` doivent être incluses dans l'image Talos (déjà fait, voir `talos/infrastructure.md`).

## Installation

### 1. Ajouter le repo Helm

```bash
helm repo add longhorn https://charts.longhorn.io
helm repo update
```

### 2. Installer Longhorn

```bash
helm install longhorn longhorn/longhorn \
  --namespace longhorn-system --create-namespace \
  --version 1.12.0 \
  --wait --timeout 5m
```

### 3. Vérifier

```bash
kubectl -n longhorn-system get pods
kubectl get storageclass
```

La StorageClass `longhorn` doit apparaître.

### 4. Accéder à l'UI

```bash
kubectl port-forward -n longhorn-system svc/longhorn-frontend 8080:80
# puis http://localhost:8080
```

## Mise à jour

```bash
helm repo update
helm upgrade longhorn longhorn/longhorn \
  --namespace longhorn-system \
  --wait
```

## Désinstallation

```bash
helm uninstall longhorn -n longhorn-system
kubectl delete namespace longhorn-system
```
