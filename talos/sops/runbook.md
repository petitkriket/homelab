# SOPS + age

Chiffrement des secrets Kubernetes pour les commiter dans Git en toute sécurité.

- **Outils** : `sops`, `age`
- **Référence** : https://github.com/getsops/sops

## Installation

### macOS

```bash
brew install sops age
```

## Configuration

### Générer une clé age

```bash
mkdir -p ~/.config/sops/age
age-keygen -o ~/.config/sops/age/keys.txt
```

Noter la clé publique affichée (commence par `age1...`).

### 2. Créer `.sops.yaml` à la racine du repo

```yaml
creation_rules:
  - path_regex: \.enc\.yaml$
    age: "<CLÉ_PUBLIQUE_AGE>"
```

Remplacer `<CLÉ_PUBLIQUE_AGE>` par la clé publique générée.

## Utilisation

### Créer un secret

Écrire le secret en clair, puis chiffrer :

```bash
sops --encrypt secret.yaml > secret.enc.yaml
rm secret.yaml
```

### Éditer un secret

```bash
sops secret.enc.yaml
# Ouvre $EDITOR avec le contenu déchiffré
# Re-chiffre automatiquement à la sauvegarde
```

### Lire un secret

```bash
sops --decrypt secret.enc.yaml
```

### Appliquer un secret chiffré au cluster

```bash
sops --decrypt secret.enc.yaml | kubectl apply -f -
```

## Convention de nommage

- Fichiers chiffrés : `*.enc.yaml`
- Fichiers en clair : jamais commités (ajoutés au `.gitignore`)

## Rotation de clé

```bash
# Mettre à jour la clé dans .sops.yaml, puis :
sops updatekeys secret.enc.yaml
```
