#!/usr/bin/env bash
# Script exécuté automatiquement à la création du Codespace.
# Build le projet et prépare l'environnement.
set -euo pipefail

GREEN="\033[0;32m"
CYAN="\033[0;36m"
BOLD="\033[1m"
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
echo -e "${BOLD}Initialisation du Codespace Claw Code...${RESET}"
echo ""

# 1. Mise à jour de l'index apt (silencieuse)
echo -e "${CYAN}[1/3]${RESET} Vérification des dépendances système..."
sudo apt-get update -qq
sudo apt-get install -y -qq pkg-config libssl-dev git 2>/dev/null
echo -e "${GREEN}  ok${RESET} Dépendances système prêtes"

# 2. Build du workspace Rust
echo ""
echo -e "${CYAN}[2/3]${RESET} Build du workspace Rust (première fois ~2 min)..."
cd /workspaces/clawcode-2/rust
cargo build --workspace 2>&1
echo -e "${GREEN}  ok${RESET} Build terminé — binaire disponible : rust/target/debug/claw"

# 3. Message de bienvenue
echo ""
echo -e "${CYAN}[3/3]${RESET} Configuration finale..."

# Ajouter le binaire au PATH pour cette session
PROFILE_FILE="${HOME}/.zshrc"
[ -f "${HOME}/.bashrc" ] && PROFILE_FILE="${HOME}/.bashrc"

CLAW_BIN_LINE='export PATH="/workspaces/clawcode-2/rust/target/debug:$PATH"'
grep -qxF "${CLAW_BIN_LINE}" "${PROFILE_FILE}" 2>/dev/null || echo "${CLAW_BIN_LINE}" >> "${PROFILE_FILE}"

echo -e "${GREEN}  ok${RESET} PATH configuré"

echo ""
echo -e "${BOLD}${GREEN}Claw Code est prêt !${RESET}"
echo ""
echo -e "  ${BOLD}Utilisation rapide :${RESET}"
echo -e "  ${CYAN}claw prompt \"résume ce projet\"${RESET}"
echo -e "  ${CYAN}claw --model llama-3.3-70b-versatile prompt \"bonjour\"${RESET}"
echo ""
echo -e "  ${BOLD}Mode interactif (REPL) :${RESET}"
echo -e "  ${CYAN}claw${RESET}"
echo ""
echo -e "  ${BOLD}Vérification de la config :${RESET}"
echo -e "  ${CYAN}claw doctor${RESET}"
echo ""

if [ -z "${OPENAI_API_KEY:-}" ] && [ -z "${ANTHROPIC_API_KEY:-}" ]; then
  echo -e "  ⚠️  Aucune clé API détectée."
  echo -e "  Configurez OPENAI_API_KEY dans :"
  echo -e "  GitHub → Settings → Codespaces → Secrets"
  echo ""
fi
