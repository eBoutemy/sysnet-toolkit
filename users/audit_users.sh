#!/bin/bash
# ============================================================
# audit_users.sh — Audit des comptes utilisateurs
# Auteur : Enzo Boutemy
# Usage : sudo ./audit_users.sh
# ============================================================

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

check_root() {
    [[ $EUID -ne 0 ]] && echo -e "${RED}[ERREUR]${NC} Droits root requis." && exit 1
}

check_no_password() {
    echo -e "\n${YELLOW}[1] Comptes sans mot de passe :${NC}"
    EMPTY=$(awk -F: '($2 == "" || $2 == "!") {print $1}' /etc/shadow 2>/dev/null)
    if [[ -z "$EMPTY" ]]; then
        echo -e "  ${GREEN}Aucun compte sans mot de passe détecté.${NC}"
    else
        echo -e "  ${RED}ATTENTION :${NC} $EMPTY"
    fi
}

check_sudoers() {
    echo -e "\n${YELLOW}[2] Utilisateurs avec droits sudo :${NC}"
    grep -Po '^sudo.+:\K.*$' /etc/group | tr ',' '\n' | while read -r user; do
        echo -e "  ${RED}➜ $user${NC}"
    done
    getent group sudo | awk -F: '{print $4}' | tr ',' '\n' | while read -r user; do
        echo -e "  ${RED}➜ $user${NC} (groupe sudo)"
    done
}

check_inactive_users() {
    echo -e "\n${YELLOW}[3] Comptes inactifs (jamais connectés) :${NC}"
    lastlog | awk 'NR>1 && /Never logged/ {print "  ➜ " $1}'
}

check_uid_zero() {
    echo -e "\n${YELLOW}[4] Comptes avec UID 0 (root-like) :${NC}"
    awk -F: '$3 == 0 {print "  " $1}' /etc/passwd
}

main() {
    check_root
    echo -e "\n${GREEN}=============================${NC}"
    echo -e "${GREEN}   AUDIT DES UTILISATEURS${NC}"
    echo -e "${GREEN}=============================${NC}"
    echo -e "  Date : $(date)"
    check_no_password
    check_sudoers
    check_inactive_users
    check_uid_zero
    echo -e "\n${GREEN}[FIN]${NC} Audit utilisateurs terminé."
}

main
