# Infrastructure Homelab

## Machine physique

- **Hôte** : Dell Optiplex 5050 — 32 GB RAM, 512 GB SSD
- **Hyperviseur** : Proxmox VE
- **OS cluster** : Talos Linux v1.13.4 (API-only, pas de SSH — tout passe par `talosctl`)

## Plan d'adressage

Subnet : `192.168.1.0/24` — gateway `192.168.1.1`

| Rôle | IP | Note |
|---|---|---|
| **VIP control-plane** | `192.168.1.50` | endpoint stable, ne bouge jamais |
| CP-01 | `192.168.1.86` | IP statique (fixée dans cp-patch.yaml) |
| Worker-01 (machine 1) | `192.168.1.87` | |
| Worker-02 (machine 1) | `192.168.1.88` | |
| Worker-03 (machine 2, futur) | `192.168.1.89` | |
| Worker-04 (machine 2, futur) | `192.168.1.90` | |
| Pool MetalLB | `.60`–`.70` | IPs LoadBalancer, hors plage DHCP |

**CIDR cluster** (défauts Talos) : pods `10.244.0.0/16`, services `10.96.0.0/12`.

> Côté box : exclure `.50`, `.86–.90` et `.60–.70` de la plage DHCP.

## Specs VM

| VM | vCPU | RAM | Disque |
|---|---|---|---|
| talos-cp-01 | 2 | 4 GB | 30 GB |
| talos-worker-XX | 4 | 8 GB | 60 GB |

## Config VM Proxmox (commune)

- **BIOS** : OVMF (UEFI), décocher "Pre-Enroll keys" (pas de SecureBoot)
- **Machine** : q35
- **Qemu Agent** : coché
- **SCSI Controller** : VirtIO SCSI single
- **Disque** : Bus SCSI, storage `local-lvm`
- **CPU Type** : host
- **Memory** : Ballooning décoché
- **Network** : bridge `vmbr0`, model VirtIO

## Image Talos

- **Source** : factory.talos.dev
- **Platform** : Nocloud / amd64
- **Version** : v1.13.4
- **Extensions** :
  - `qemu-guest-agent` (intégration Proxmox)
  - `iscsi-tools` (pour Longhorn)
  - `util-linux-tools` (pour Longhorn)
- **Schematic ID** : `88d1f7a5c4f1d3aba7df787c448c1d3d008ed29cfb34af53fa0df4336a56040b`
- **ISO URL** : `https://factory.talos.dev/image/88d1f7a5c4f1d3aba7df787c448c1d3d008ed29cfb34af53fa0df4336a56040b/v1.13.4/nocloud-amd64.iso`

## Gestion des secrets

- **`secrets.yaml`** = seul fichier secret, source de vérité. Sauvegardé dans coffre (1Password, Bitwarden...).
- `controlplane.yaml` / `worker.yaml` / `talosconfig` / `kubeconfig` = générés à la volée, jamais persistés dans le repo.
- Tout est regénérable avec `secrets.yaml` + patches.
