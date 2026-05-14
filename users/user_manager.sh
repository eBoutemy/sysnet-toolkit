#!/bin/bash
# ============================================================
# user_manager.sh — Gestion des utilisateurs Linux
# Auteur : Enzo Boutemy
# Usage : sudo ./user_manager.sh
# ============================================================

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

check_root() {
    [[ $EUID -ne 0 ]] && echo -e "${RED}[ERREUR]${NC} Droits root requis." && exit 1
}

create_user() {
    read -rp "Nom d'utilisateur : " username
    read -rp "Commentaire (nom complet) : " comment
    read -rsp "Mot de passe : " password; echo
    if id "$username" &>/dev/null; then
        echo -e "${RED}[ERREUR]${NC} L'utilisateur '$username' existe déjà."
        return
    fi
    useradd -m -c "$comment" -s /bin/bash "$username"
    echo "$username:$password" | chpasswd
    echo -e "${GREEN}[OK]${NC} Utilisateur '$username' créé avec succès."
}

delete_user() {
    read -rp "Nom de l'utilisateur à supprimer : " username
    if ! id "$username" &>/dev/null; then
        echo -e "${RED}[ERREUR]${NC} Utilisateur '$username' introuvable."
        return
    fi
    read -rp "Supprimer aussi le répertoire home ? (o/n) : " confirm
    if [[ "$confirm" == "o" ]]; then
        userdel -r "$username"
    else
        userdel "$username"
    fi
    echo -e "${GREEN}[OK]${NC} Utilisateur '$username' supprimé."
}

list_users() {
    echo -e "\n${CYAN}Liste des utilisateurs (UID >= 1000) :${NC}"
    echo "------------------------------------------"
    printf "%-20s %-6s %-30s\n" "Utilisateur" "UID" "Répertoire home"
    echo "------------------------------------------"
    awk -F: '$3 >= 1000 && $3 != 65534 {printf "%-20s %-6s %-30s\n", $1, $3, $6}' /etc/passwd
}

change_password() {
    read -rp "Nom de l'utilisateur : " username
    passwd "$username"
}

menu() {
    echo -e "\n${YELLOW}╔══════════════════════════════════╗${NC}"
    echo -e "${YELLOW}║      GESTION UTILISATEURS        ║${NC}"
    echo -e "${YELLOW}╚══════════════════════════════════╝${NC}"
    echo "  1) Créer un utilisateur"
    echo "  2) Supprimer un utilisateur"
    echo "  3) Lister les utilisateurs"
    echo "  4) Changer un mot de passe"
    echo "  5) Quitter"
    echo ""
    read -rp "Choix : " choice
    case $choice in
        1) create_user ;;
        2) delete_user ;;
        3) list_users ;;
        4) change_password ;;
        5) exit 0 ;;
        *) echo -e "${RED}Option invalide.${NC}" ;;
    esac
}

check_root
while true; do
    menu
done
