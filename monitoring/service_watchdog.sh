#!/bin/bash
# ============================================================
# service_watchdog.sh — Surveillance et redémarrage de services
# Auteur : Enzo Boutemy
# Usage : sudo ./service_watchdog.sh
# ============================================================

SERVICES=("ssh" "nginx" "mysql" "cron")
LOG_FILE="/var/log/watchdog.log"
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

check_root() {
    if [[ $EUID -ne 0 ]]; then
        echo -e "${RED}[ERREUR]${NC} Ce script nécessite les droits root."
        exit 1
    fi
}

check_service() {
    local service=$1
    if systemctl is-active --quiet "$service"; then
        echo -e "  ${GREEN}[OK]${NC}      $service est actif"
        log "OK: $service actif"
    else
        echo -e "  ${RED}[ALERTE]${NC}  $service est ARRÊTÉ — tentative de redémarrage..."
        log "ALERTE: $service arrêté — redémarrage en cours"
        systemctl restart "$service"
        sleep 2
        if systemctl is-active --quiet "$service"; then
            echo -e "  ${GREEN}[OK]${NC}      $service redémarré avec succès"
            log "OK: $service redémarré avec succès"
        else
            echo -e "  ${RED}[ÉCHEC]${NC}   Impossible de redémarrer $service"
            log "ÉCHEC: Impossible de redémarrer $service"
        fi
    fi
}

main() {
    check_root
    echo -e "\n${YELLOW}╔══════════════════════════════════╗${NC}"
    echo -e "${YELLOW}║     SERVICE WATCHDOG             ║${NC}"
    echo -e "${YELLOW}╚══════════════════════════════════╝${NC}"
    echo -e "  Date : $(date)"
    echo -e "  Services surveillés : ${SERVICES[*]}\n"
    for service in "${SERVICES[@]}"; do
        check_service "$service"
    done
    echo -e "\n  Logs enregistrés dans : $LOG_FILE"
}

main
