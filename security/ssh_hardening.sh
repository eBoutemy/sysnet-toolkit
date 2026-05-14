#!/bin/bash
# ============================================================
# ssh_hardening.sh — Analyse et durcissement SSH
# Auteur : Enzo Boutemy
# Usage : sudo ./ssh_hardening.sh
# ============================================================

SSH_CONFIG="/etc/ssh/sshd_config"
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

check_root() {
    [[ $EUID -ne 0 ]] && echo -e "${RED}[ERREUR]${NC} Droits root requis." && exit 1
}

check_param() {
    local param=$1
    local recommended=$2
    local current
    current=$(grep -iE "^${param}" "$SSH_CONFIG" | awk '{print $2}' | head -1)
    current=${current:-"non défini"}
    if [[ "$current" == "$recommended" ]]; then
        echo -e "  ${GREEN}[OK]${NC}      $param = $current"
    else
        echo -e "  ${RED}[ALERTE]${NC}  $param = $current (recommandé : ${YELLOW}$recommended${NC})"
    fi
}

analyze_ssh_config() {
    echo -e "\n${YELLOW}[ANALYSE]${NC} Configuration SSH ($SSH_CONFIG) :"
    echo "  ------------------------------------------------"
    check_param "PermitRootLogin" "no"
    check_param "PasswordAuthentication" "no"
    check_param "X11Forwarding" "no"
    check_param "MaxAuthTries" "3"
    check_param "Protocol" "2"
    check_param "LoginGraceTime" "30"
    check_param "PermitEmptyPasswords" "no"
}

check_ssh_port() {
    local port
    port=$(grep -iE "^Port" "$SSH_CONFIG" | awk '{print $2}' | head -1)
    port=${port:-22}
    if [[ "$port" -eq 22 ]]; then
        echo -e "  ${RED}[ALERTE]${NC}  Port SSH = 22 (recommandé : changer vers un port > 1024)"
    else
        echo -e "  ${GREEN}[OK]${NC}      Port SSH = $port (non-standard)"
    fi
}

check_fail2ban() {
    echo -e "\n${YELLOW}[FAIL2BAN]${NC} Vérification de fail2ban :"
    if systemctl is-active --quiet fail2ban; then
        echo -e "  ${GREEN}[OK]${NC}      fail2ban est actif."
        fail2ban-client status sshd 2>/dev/null | head -10
    else
        echo -e "  ${RED}[ALERTE]${NC}  fail2ban n'est pas actif. Installez-le : apt install fail2ban"
    fi
}

show_recommendations() {
    echo -e "\n${YELLOW}[RECOMMANDATIONS]${NC}"
    echo "  1. Désactivez l'accès root SSH : PermitRootLogin no"
    echo "  2. Utilisez uniquement les clés SSH (PasswordAuthentication no)"
    echo "  3. Changez le port SSH (ex: Port 2222)"
    echo "  4. Activez fail2ban pour bloquer les attaques brute-force"
    echo "  5. Limitez les utilisateurs autorisés avec AllowUsers"
    echo "  6. Réduisez MaxAuthTries à 3"
}

main() {
    check_root
    echo -e "\n${GREEN}=============================${NC}"
    echo -e "${GREEN}   AUDIT DURCISSEMENT SSH${NC}"
    echo -e "${GREEN}=============================${NC}"
    echo -e "  Date : $(date)"
    analyze_ssh_config
    echo ""
    check_ssh_port
    check_fail2ban
    show_recommendations
    echo -e "\n${GREEN}[FIN]${NC} Audit SSH terminé."
}

main
