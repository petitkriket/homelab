# Headlamp

Dashboard Kubernetes léger — interface web pour visualiser et gérer le cluster.

- **Chart** : `headlamp/headlamp`
- **Namespace** : `headlamp`
- **Accès** : port-forward
- **Référence** : https://headlamp.dev/docs/latest/installation/in-cluster/

## Installation

### 1. Ajouter le repo Helm

```bash
helm repo add headlamp https://kubernetes-sigs.github.io/headlamp/
helm repo update
```

### 2. Installer Headlamp

```bash
helm install headlamp headlamp/headlamp \
  --namespace headlamp --create-namespace \
  --wait --timeout 5m
```

### 3. Vérifier

```bash
kubectl -n headlamp get pods
```

### 4. Créer un ServiceAccount admin

Le ServiceAccount et le ClusterRoleBinding doivent être créés **avant** d'accéder à l'UI :

```bash
kubectl create serviceaccount headlamp-admin -n headlamp
kubectl create clusterrolebinding headlamp-admin \
  --clusterrole=cluster-admin \
  --serviceaccount=headlamp:headlamp-admin
```

### 5. Générer un token d'accès

```bash
kubectl create token headlamp-admin -n headlamp
```

Copier le token affiché.

### 6. Accéder à l'UI

```bash
kubectl port-forward -n headlamp svc/headlamp 8080:80
# puis http://localhost:8080
```

Coller le token dans l'interface Headlamp pour se connecter.

## Mise à jour

```bash
helm repo update
helm upgrade headlamp headlamp/headlamp \
  --namespace headlamp \
  --wait
```

## Désinstallation

```bash
helm uninstall headlamp -n headlamp
kubectl delete clusterrolebinding headlamp-admin
kubectl delete namespace headlamp
```
