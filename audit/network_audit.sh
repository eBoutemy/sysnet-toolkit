#!/bin/bash
# ============================================================
# network_audit.sh — Audit complet du réseau local
# Auteur : Enzo Boutemy
# Description : Détecte les hôtes actifs, leur IP et MAC
# Usage : sudo ./network_audit.sh [interface]
# ============================================================

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

check_root() {
    if [[ $EUID -ne 0 ]]; then
        echo -e "${RED}[ERREUR]${NC} Ce script nécessite les droits root."
        exit 1
    fi
}

get_interface() {
    INTERFACE=${1:-$(ip route | grep default | awk '{print $5}' | head -1)}
    echo -e "${YELLOW}[INFO]${NC} Interface utilisée : $INTERFACE"
}

get_network_range() {
    NETWORK=$(ip -o -f inet addr show "$INTERFACE" | awk '{print $4}')
    echo -e "${YELLOW}[INFO]${NC} Plage réseau : $NETWORK"
}

scan_hosts() {
    echo -e "\n${GREEN}[SCAN]${NC} Scan des hôtes actifs sur $NETWORK ..."
    echo "--------------------------------------------------------"
    printf "%-18s %-20s %-17s\n" "IP" "HOSTNAME" "MAC"
    echo "--------------------------------------------------------"

    if ! command -v nmap &> /dev/null; then
        echo -e "${RED}[ERREUR]${NC} nmap n'est pas installé. Installez-le avec : apt install nmap"
        exit 1
    fi

    nmap -sn "$NETWORK" -oG - 2>/dev/null | grep "Host:" | while read -r line; do
        IP=$(echo "$line" | awk '{print $2}')
        HOSTNAME=$(echo "$line" | awk -F'[()]' '{print $2}')
        MAC=$(arp -n "$IP" 2>/dev/null | awk '/ether/ {print $3}')
        MAC=${MAC:-"N/A"}
        printf "%-18s %-20s %-17s\n" "$IP" "$HOSTNAME" "$MAC"
    done
    echo "--------------------------------------------------------"
}

show_routing_table() {
    echo -e "\n${GREEN}[ROUTE]${NC} Table de routage :"
    ip route show
}

show_dns() {
    echo -e "\n${GREEN}[DNS]${NC} Serveurs DNS configurés :"
    if [ -f /etc/resolv.conf ]; then
        grep "nameserver" /etc/resolv.conf | awk '{print "  ➜ " $2}'
    else
        echo "  Fichier /etc/resolv.conf introuvable."
    fi
}

main() {
    check_root
    echo -e "\n${GREEN}=============================${NC}"
    echo -e "${GREEN}   AUDIT RÉSEAU LOCAL${NC}"
    echo -e "${GREEN}=============================${NC}"
    echo -e "Date : $(date)"
    get_interface "$1"
    get_network_range
    scan_hosts
    show_routing_table
    show_dns
    echo -e "\n${GREEN}[FIN]${NC} Audit terminé."
}

main "$@"
