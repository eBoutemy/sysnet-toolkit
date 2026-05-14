# 🛠️ SysNet Toolkit

> Toolkit d'administration système et réseaux — Scripts Bash pour audit réseau, monitoring, gestion utilisateurs et sécurité serveur.

![Bash](https://img.shields.io/badge/language-Bash-green?style=flat-square)
![License](https://img.shields.io/badge/license-MIT-blue?style=flat-square)
![Platform](https://img.shields.io/badge/platform-Linux-lightgrey?style=flat-square)

---

## 📁 Structure du projet

```
sysnet-toolkit/
├── audit/
│   ├── network_audit.sh       # Audit complet du réseau local
│   └── port_scanner.sh        # Scanner de ports TCP
├── monitoring/
│   ├── system_monitor.sh      # Monitoring CPU, RAM, disque
│   └── service_watchdog.sh    # Surveillance et redémarrage de services
├── users/
│   ├── user_manager.sh        # Gestion des utilisateurs Linux
│   └── audit_users.sh         # Audit des comptes utilisateurs
├── security/
│   ├── firewall_check.sh      # Vérification des règles iptables/ufw
│   └── ssh_hardening.sh       # Durcissement de la configuration SSH
└── README.md
```

---

## 🚀 Installation

```bash
git clone https://github.com/eBoutemy/sysnet-toolkit.git
cd sysnet-toolkit
chmod +x **/*.sh
```

---

## 📌 Modules

### 🔍 Audit Réseau (`audit/`)
- **network_audit.sh** : Scan du réseau local, détection des hôtes actifs, affichage des adresses IP/MAC.
- **port_scanner.sh** : Scanner de ports TCP sur une IP cible, avec rapport des ports ouverts.

### 📊 Monitoring (`monitoring/`)
- **system_monitor.sh** : Affichage en temps réel de l'utilisation CPU, RAM, swap et espace disque.
- **service_watchdog.sh** : Surveillance de services critiques (nginx, ssh, mysql...) avec redémarrage automatique.

### 👥 Gestion Utilisateurs (`users/`)
- **user_manager.sh** : Création, suppression, modification et listage des utilisateurs Linux.
- **audit_users.sh** : Audit des comptes (comptes sans mot de passe, comptes inactifs, sudoers...).

### 🔐 Sécurité (`security/`)
- **firewall_check.sh** : Vérification et rapport des règles de pare-feu actives (iptables / ufw).
- **ssh_hardening.sh** : Analyse et recommandations de durcissement SSH (désactiver root login, changer le port, etc.).

---

## ⚙️ Prérequis

- Linux (Debian/Ubuntu recommandé)
- Bash 4.x+
- `nmap` (pour les scripts d'audit réseau)
- Droits `sudo` pour certains scripts

---

## 📄 Licence

MIT License — Voir [LICENSE](LICENSE)

---

## 👤 Auteur

**Enzo Boutemy** — BTS SIO Réseaux
🔗 [github.com/eBoutemy](https://github.com/eBoutemy)
