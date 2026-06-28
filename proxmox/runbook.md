# Proxmox VE

Hyperviseur sur Dell Optiplex 5050 (32 GB RAM, 512 GB SSD).

## Installation

1. Flasher ISO Proxmox VE sur clé USB (Balena Etcher / Rufus)
2. Booter sur clé → installer → choisir disque SSD
3. Configurer IP statique, hostname `pve`, DNS
4. Accès UI : `https://192.168.1.63:8006`

## Post-install

```bash
# Désactiver repo entreprise (pas de licence)
???

# Ajuster la locale (ex: fr_FR.UTF-8)
???
```

## Upload ISO Talos

Noeud `pve` → storage `local` → ISO Images → Download from URL → coller URL ISO (voir `talos/infrastructure.md`).

## Créer les VMs

```bash
# ssh root@192.168.1.63

# Depuis le shell Proxmox
bash create-vms.sh
qm start 100
qm start 101
```

Script crée : CP (VM 100, 2 vCPU, 4 GB, 30 GB) + Worker (VM 101, 4 vCPU, 8 GB, 60 GB). Voir `talos/infrastructure.md` pour specs détaillées.

## Mise à jour Proxmox

```bash
apt update && apt full-upgrade -y
# Reboot si nouveau kernel
```

## Commandes utiles

```bash
qm list                  # Lister VMs
qm start/stop/reset <id> # Contrôler VM
qm config <id>           # Voir config VM
pvesh get /nodes          # Infos noeud
```

## Scripts

- Community Scripts : https://community-scripts.org/scripts?filter=popular