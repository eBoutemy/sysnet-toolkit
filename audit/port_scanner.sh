#!/bin/bash
# ============================================================
# port_scanner.sh — Scanner de ports TCP
# Auteur : Enzo Boutemy
# Usage : ./port_scanner.sh <IP> [port_début] [port_fin]
# ============================================================

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

TARGET=${1:?"Usage: $0 <IP> [port_début] [port_fin]"}
PORT_START=${2:-1}
PORT_END=${3:-1024}
TIMEOUT=1

declare -A KNOWN_PORTS=(
    [21]="FTP" [22]="SSH" [23]="Telnet" [25]="SMTP"
    [53]="DNS" [80]="HTTP" [110]="POP3" [143]="IMAP"
    [443]="HTTPS" [3306]="MySQL" [3389]="RDP" [8080]="HTTP-Alt"
)

echo -e "\n${GREEN}==============================${NC}"
echo -e "${GREEN}   SCANNER DE PORTS TCP${NC}"
echo -e "${GREEN}==============================${NC}"
echo -e "Cible    : ${YELLOW}$TARGET${NC}"
echo -e "Plage    : ${YELLOW}$PORT_START - $PORT_END${NC}"
echo -e "Début    : $(date)\n"
echo -e "${GREEN}Port\t\tStatut\t\tService${NC}"
echo "------------------------------------------"

OPEN_COUNT=0

for ((port=PORT_START; port<=PORT_END; port++)); do
    (echo >/dev/tcp/$TARGET/$port) &>/dev/null
    if [[ $? -eq 0 ]]; then
        SERVICE=${KNOWN_PORTS[$port]:-"Inconnu"}
        echo -e "${GREEN}$port/tcp\t\tOUVERT\t\t$SERVICE${NC}"
        ((OPEN_COUNT++))
    fi
done

echo "------------------------------------------"
echo -e "\n${YELLOW}[RÉSULTAT]${NC} $OPEN_COUNT port(s) ouvert(s) sur $TARGET"
echo -e "Fin : $(date)"
