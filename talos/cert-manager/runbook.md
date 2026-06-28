# cert-manager

Gestion automatique des certificats TLS (Let's Encrypt, self-signed, etc.).

- **Chart** : `jetstack/cert-manager` v1.20.3
- **Namespace** : `cert-manager`
- **Référence** : https://cert-manager.io/docs/installation/helm/

## Installation

### 1. Ajouter le repo Helm

```bash
helm repo add jetstack https://charts.jetstack.io --force-update
helm repo update
```

### 2. Installer cert-manager

```bash
helm install cert-manager jetstack/cert-manager \
  --namespace cert-manager --create-namespace \
  --version v1.20.3 \
  --set crds.enabled=true \
  --wait --timeout 5m
```

### 3. Appliquer le ClusterIssuer

### Auto signé

[référence](https://cert-manager.io/docs/configuration/selfsigned/#deployment)

```bash
kubectl apply -f talos/cert-manager/selfsigned-cluster-issuer.yaml
```

#### Let's Encrypt

- Pour utiliser Let's Encrypt, il faut créer un ClusterIssuer avec les informations de votre domaine et votre email.

Pas de domaine, on verra plus tard.

- https://traefik.io/blog/secure-web-applications-with-traefik-proxy-cert-manager-and-lets-encrypt
- https://doc.traefik.io/traefik/v3.4/user-guides/cert-manager/
- https://blog.zwindler.fr/2018/03/27/generez-automatiquement-vos-certificats-lets-encrypt-dans-kubernetes/

### 4. Vérifier

```bash
kubectl -n cert-manager get pods
kubectl get clusterissuer
```

## Mise à jour

```bash
helm repo update
helm upgrade cert-manager jetstack/cert-manager \
  --namespace cert-manager \
  --set crds.enabled=true \
  --wait
```

## Désinstallation

```bash
helm uninstall cert-manager -n cert-manager
kubectl delete namespace cert-manager
```

Les CRDs sont conservées par défaut pour éviter la perte de données. Pour les supprimer :

```bash
kubectl delete crd certificates.cert-manager.io certificaterequests.cert-manager.io clusterissuers.cert-manager.io issuers.cert-manager.io orders.acme.cert-manager.io challenges.acme.cert-manager.io
```
