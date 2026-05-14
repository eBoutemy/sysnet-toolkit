#!/bin/bash
# ============================================================
# system_monitor.sh — Monitoring système en temps réel
# Auteur : Enzo Boutemy
# Usage : ./system_monitor.sh [intervalle_secondes]
# ============================================================

INTERVAL=${1:-5}
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
CYAN='\033[0;36m'
NC='\033[0m'

get_cpu_usage() {
    CPU=$(top -bn1 | grep "Cpu(s)" | awk '{print $2 + $4}' | cut -d. -f1)
    if [ "$CPU" -ge 80 ]; then
        echo -e "${RED}${CPU}%${NC}"
    elif [ "$CPU" -ge 50 ]; then
        echo -e "${YELLOW}${CPU}%${NC}"
    else
        echo -e "${GREEN}${CPU}%${NC}"
    fi
}

get_ram_usage() {
    TOTAL=$(free -m | awk '/Mem:/ {print $2}')
    USED=$(free -m | awk '/Mem:/ {print $3}')
    PERCENT=$((USED * 100 / TOTAL))
    if [ "$PERCENT" -ge 85 ]; then
        echo -e "${RED}${USED}MB / ${TOTAL}MB (${PERCENT}%)${NC}"
    else
        echo -e "${GREEN}${USED}MB / ${TOTAL}MB (${PERCENT}%)${NC}"
    fi
}

get_disk_usage() {
    df -h / | awk 'NR==2 {print $3 " / " $2 " (" $5 ")" }'
}

get_top_processes() {
    echo ""
    echo -e "${CYAN}  Top 5 processus (CPU) :${NC}"
    ps aux --sort=-%cpu | awk 'NR>=2 && NR<=6 {printf "    %-8s %-25s %s%%\n", $1, $11, $3}'
}

get_network_stats() {
    IFACE=$(ip route | grep default | awk '{print $5}' | head -1)
    RX=$(cat /sys/class/net/$IFACE/statistics/rx_bytes 2>/dev/null || echo 0)
    TX=$(cat /sys/class/net/$IFACE/statistics/tx_bytes 2>/dev/null || echo 0)
    RX_MB=$(echo "scale=2; $RX / 1048576" | bc)
    TX_MB=$(echo "scale=2; $TX / 1048576" | bc)
    echo -e "  ↓ RX: ${GREEN}${RX_MB} MB${NC}  |  ↑ TX: ${GREEN}${TX_MB} MB${NC}  (interface: $IFACE)"
}

monitor_loop() {
    while true; do
        clear
        echo -e "${CYAN}╔══════════════════════════════════════════╗${NC}"
        echo -e "${CYAN}║       MONITORING SYSTÈME - SysNet        ║${NC}"
        echo -e "${CYAN}╚══════════════════════════════════════════╝${NC}"
        echo -e "  Hôte    : ${YELLOW}$(hostname)${NC}  |  Date : $(date '+%d/%m/%Y %H:%M:%S')"
        echo -e "  Uptime  : $(uptime -p)"
        echo "  ------------------------------------------"
        echo -e "  CPU     : $(get_cpu_usage)"
        echo -e "  RAM     : $(get_ram_usage)"
        echo -e "  Disque  : $(get_disk_usage)"
        echo "  ------------------------------------------"
        echo -e "${CYAN}  Réseau :${NC}"
        get_network_stats
        get_top_processes
        echo ""
        echo -e "  Rafraîchissement toutes les ${INTERVAL}s — Ctrl+C pour quitter"
        sleep "$INTERVAL"
    done
}

monitor_loop
