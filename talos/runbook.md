# Runbook Homelab

Procédures de (re)construction du cluster. Chaque section = une opération autonome.

## Prérequis Mac

```bash
brew install siderolabs/tap/talosctl kubectl
```

## 1. Upload ISO dans Proxmox

Noeud `pve` → storage `local` → ISO Images → Download from URL → coller URL ISO (voir infrastructure.md) → Download.

## 2. Créer une VM Talos

UI Proxmox → Create VM. Specs et config : voir infrastructure.md.

**Boot order (1er boot)** : Options → Boot Order → ide2 (ISO) en premier.

Démarrer → console affiche Talos en mode maintenance + IP DHCP.

## 3. Générer secrets (une seule fois par cluster)

```bash
cd ~/homelab
talosctl gen secrets -o secrets.yaml
```

Sauvegarder `secrets.yaml` dans coffre. Seul fichier à protéger.

## 4. Installer un control-plane

```bash
talosctl gen config homelab https://192.168.1.50:6443 --with-secrets secrets.yaml --output-dir /tmp/talos-config

talosctl apply-config --insecure -n <IP_DHCP_DU_NOEUD> --file /tmp/talos-config/controlplane.yaml --config-patch @talos/cp-patch.yaml
```

**Immédiatement** : changer boot order → scsi0 (disque) en premier.

Configurer talosctl + bootstrap :

```bash
cp /tmp/talos-config/talosconfig . && export TALOSCONFIG=$PWD/talosconfig
talosctl config endpoint 192.168.1.86 && talosctl config node 192.168.1.86
talosctl bootstrap
```

Récupérer kubeconfig :

```bash
talosctl kubeconfig . && export KUBECONFIG=$PWD/kubeconfig
kubectl get nodes
```

> `talosctl kubeconfig .` (avec `.`) écrit en local — n'écrase pas `~/.kube/config`.
> Isolation : `export KUBECONFIG=~/homelab/kubeconfig` pour homelab, `unset KUBECONFIG` pour revenir au pro.

Cleanup :

```bash
rm -rf /tmp/talos-config
```

Validation :

```bash
talosctl health -n 192.168.1.86 --wait-timeout 3m
```

## 5. Ajouter un worker

Créer VM dans Proxmox (specs worker dans infrastructure.md). Boot sur ISO → mode maintenance → noter IP DHCP.

Créer `talos/worker-XX-patch.yaml` (remplacer XX par IP voulue : .87, .88, .89, .90) :

```yaml
machine:
  install:
    disk: /dev/sda
  network:
    nameservers:
      - 192.168.1.1
      - 1.1.1.1
    interfaces:
      - deviceSelector:
          physical: true
        dhcp: false
        addresses:
          - 192.168.1.XX/24    # .87, .88, .89, .90
        routes:
          - network: 0.0.0.0/0
            gateway: 192.168.1.1
```


```bash
cd ~/homelab

talosctl gen config homelab https://192.168.1.50:6443 --with-secrets secrets.yaml --output-dir /tmp/talos-config

talosctl apply-config --insecure -n <IP_DHCP_DU_WORKER> --file /tmp/talos-config/worker.yaml --config-patch @talos/worker-XX-patch.yaml

rm -rf /tmp/talos-config
```

Changer boot order → scsi0 en premier. Vérifier :

```bash
KUBECONFIG=~/homelab/kubeconfig kubectl get nodes
```

## 6. Monitoring avec k9s

```bash
KUBECONFIG=~/homelab/kubeconfig k9s
```

## 7. Rebuild from scratch

Si tout est perdu sauf `secrets.yaml` + patches :

```bash
# Recréer VMs dans Proxmox (voir infrastructure.md)
# Puis reprendre depuis §4 (CP) puis §5 (workers)
```

## 8. Régénérer talosconfig / kubeconfig

```bash
# talosconfig (besoin de secrets.yaml)
talosctl gen config homelab https://192.168.1.50:6443 --with-secrets secrets.yaml --output-dir /tmp/talos-config && cp /tmp/talos-config/talosconfig . && rm -rf /tmp/talos-config

# kubeconfig (besoin du cluster vivant)
talosctl kubeconfig .
```
