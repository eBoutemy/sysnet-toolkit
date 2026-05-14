#!/bin/bash
# ============================================================
# firewall_check.sh — Vérification des règles de pare-feu
# Auteur : Enzo Boutemy
# Usage : sudo ./firewall_check.sh
# ============================================================

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

check_root() {
    [[ $EUID -ne 0 ]] && echo -e "${RED}[ERREUR]${NC} Droits root requis." && exit 1
}

detect_firewall() {
    if command -v ufw &>/dev/null && ufw status | grep -q "Status: active"; then
        FIREWALL="ufw"
    elif command -v iptables &>/dev/null; then
        FIREWALL="iptables"
    else
        echo -e "${RED}[ERREUR]${NC} Aucun pare-feu détecté."
        exit 1
    fi
    echo -e "${YELLOW}[INFO]${NC} Pare-feu détecté : $FIREWALL"
}

check_ufw() {
    echo -e "\n${GREEN}[UFW]${NC} Statut et règles :"
    ufw status verbose
}

check_iptables() {
    echo -e "\n${GREEN}[IPTABLES]${NC} Règles actives :"
    echo -e "\n  --- FILTER TABLE ---"
    iptables -L -n -v --line-numbers
    echo -e "\n  --- NAT TABLE ---"
    iptables -t nat -L -n -v 2>/dev/null
}

check_open_ports() {
    echo -e "\n${YELLOW}[PORTS]${NC} Ports en écoute (TCP/UDP) :"
    ss -tuln | awk 'NR==1 || /LISTEN/' | column -t
}

main() {
    check_root
    echo -e "\n${GREEN}=============================${NC}"
    echo -e "${GREEN}   VÉRIFICATION PARE-FEU${NC}"
    echo -e "${GREEN}=============================${NC}"
    echo -e "  Date : $(date)"
    detect_firewall
    if [[ "$FIREWALL" == "ufw" ]]; then
        check_ufw
    else
        check_iptables
    fi
    check_open_ports
    echo -e "\n${GREEN}[FIN]${NC} Vérification terminée."
}

main
