# CloudNativePG

Opérateur Kubernetes pour gérer des clusters PostgreSQL (provisioning, failover, backups).

- **Chart** : `cloudnative-pg/cloudnative-pg`
- **Namespace** : `cnpg-system`
- **Référence** : https://cloudnative-pg.io/docs/1.29/installation_upgrade

## Installation

```bash
helm repo add cloudnative-pg https://cloudnative-pg.github.io/charts
helm repo update
helm install cnpg cloudnative-pg/cloudnative-pg \
  --namespace cnpg-system --create-namespace \
  --wait --timeout 5m
```

```bash
kubectl -n cnpg-system get pods
kubectl get crd clusters.postgresql.cnpg.io
```

## Pourquoi un cluster partagé

Un cluster par DB offre une isolation totale (crash, backup, resources) mais coûte 2 pods × N databases. En homelab avec peu d'apps et des ressources limitées, un cluster partagé suffit. Le risque (crash PG = toutes les apps down) est acceptable ici.

## Créer le cluster

```bash
kubectl apply -f talos/cnpg/pg-cluster.yaml
```

CNPG crée automatiquement les secrets `homelab-pg-superuser` et `homelab-pg-app` au bootstrap. Vérifier :

```bash
kubectl get secrets -n cnpg-system | grep homelab-pg
```

## Services réseau

CNPG expose trois services :

| Service | Usage |
|---|---|
| `homelab-pg-rw.cnpg-system.svc:5432` | Primary, lecture-écriture |
| `homelab-pg-ro.cnpg-system.svc:5432` | Réplicas read-only |
| `homelab-pg-r.cnpg-system.svc:5432` | N'importe quelle instance |

Les apps utilisent `homelab-pg-rw` pour les écritures.

## Ajouter une app

Les databases ne sont pas déclarées dans le manifest — elles sont créées à la demande pour éviter de tout refaire au bootstrap si on ajoute une app plus tard.

```bash
kubectl exec -it homelab-pg-1 -n cnpg-system -- psql -U postgres
```

```sql
CREATE DATABASE <nom_db>;
CREATE USER <nom_user> WITH PASSWORD '<mot_de_passe>';
GRANT ALL PRIVILEGES ON DATABASE <nom_db> TO <nom_user>;
```

Stocker les credentials dans un secret SOPS (voir `talos/sops/runbook.md`) :

```bash
sops talos/cnpg/<app>-pg-secret.enc.yaml
sops --decrypt talos/cnpg/<app>-pg-secret.enc.yaml | kubectl apply -f -
```

## Mise à jour

```bash
helm repo update
helm upgrade cnpg cloudnative-pg/cloudnative-pg \
  --namespace cnpg-system \
  --wait
```

## Désinstallation

```bash
helm uninstall cnpg -n cnpg-system
kubectl delete namespace cnpg-system
```
