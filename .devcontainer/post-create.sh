#!/usr/bin/env bash
# Exécuté automatiquement à la création du Codespace.
set -euo pipefail

GREEN="\033[0;32m"
CYAN="\033[0;36m"
BOLD="\033[1m"
YELLOW="\033[1;33m"
RESET="\033[0m"

echo -e "${BOLD}${CYAN}"
cat <<'BANNER'
   ____  _                   ____          _
  / ___|| |  __ _ __      __ / ___|___   __| | ___
 | |    | | / _` |\ \ /\ / /| |   / _ \ / _` |/ _ \
 | |___ | || (_| | \ V  V / | |__| (_) | (_| |  __/
  \____||_| \__,_|  \_/\_/   \____\___/ \__,_|\___|
BANNER
echo -e "${RESET}"

# 1. Dépendances système
echo -e "${CYAN}[1/3]${RESET} Dépendances système..."
sudo apt-get update -qq
sudo apt-get install -y -qq pkg-config libssl-dev git 2>/dev/null
echo -e "${GREEN}  ok${RESET}"

# 2. Build
echo -e "${CYAN}[2/3]${RESET} Build Rust (première fois ~2 min)..."
cd /workspaces/clawcode-2/rust
cargo build --workspace
echo -e "${GREEN}  ok${RESET} Binaire : rust/target/debug/claw"

# 3. Alias pratiques dans .zshrc et .bashrc
echo -e "${CYAN}[3/3]${RESET} Configuration des alias..."
for RCFILE in "${HOME}/.zshrc" "${HOME}/.bashrc"; do
  if [ -f "${RCFILE}" ]; then
    # Alias raccourcis pour coder avec claw
    grep -qxF "alias claw-code=" "${RCFILE}" 2>/dev/null || cat >> "${RCFILE}" << 'ALIASES'

# === Claw Code aliases ===
alias claw-code='claw --permission-mode workspace-write'
alias claw-full='claw --permission-mode danger-full-access'
alias claw-fast='claw --model llama-3.1-8b-instant'
alias claw-smart='claw --model llama-3.3-70b-versatile'
ALIASES
  fi
done

echo -e "${GREEN}  ok${RESET}"

echo ""
echo -e "${BOLD}${GREEN}Claw Code est prêt !${RESET}"
echo ""
echo -e "${BOLD}  Utiliser comme agent de code :${RESET}"
echo -e "  ${CYAN}claw --permission-mode workspace-write prompt \"crée une API REST en Python\"${RESET}"
echo -e "  ${CYAN}claw --permission-mode workspace-write prompt \"ajoute des tests unitaires\"${RESET}"
echo -e "  ${CYAN}claw --permission-mode workspace-write prompt \"corrige les bugs dans main.py\"${RESET}"
echo ""
echo -e "${BOLD}  Mode interactif (REPL comme Claude Code) :${RESET}"
echo -e "  ${CYAN}claw --permission-mode workspace-write${RESET}"
echo ""
echo -e "${BOLD}  Alias rapides disponibles :${RESET}"
echo -e "  ${CYAN}claw-code \"crée un serveur web\"${RESET}    ${YELLOW}# workspace-write${RESET}"
echo -e "  ${CYAN}claw-full  \"refactorise tout\"${RESET}     ${YELLOW}# accès total${RESET}"
echo -e "  ${CYAN}claw-smart \"analyse ce code\"${RESET}      ${YELLOW}# modèle 70B${RESET}"
echo -e "  ${CYAN}claw-fast  \"corrige la typo\"${RESET}      ${YELLOW}# modèle 8B rapide${RESET}"
echo ""

if [ -z "${OPENAI_API_KEY:-}" ] && [ -z "${ANTHROPIC_API_KEY:-}" ]; then
  echo -e "  ${YELLOW}⚠️  Clé API manquante !${RESET}"
  echo -e "  Va sur : GitHub → Settings → Codespaces → Secrets"
  echo -e "  Ajoute OPENAI_API_KEY = ta clé Groq"
  echo ""
fi
