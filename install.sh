#!/usr/bin/env bash
set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${CYAN}==============================================${NC}"
echo -e "${CYAN}       Automated n8n + SSL Installer         ${NC}"
echo -e "${CYAN}==============================================${NC}"

if [ "$EUID" -ne 0 ]; then
  echo -e "${RED}[ERROR] Please run as root (sudo bash install.sh)${NC}"
  exit 1
fi

read -rp "Enter your Domain/Subdomain (e.g. n8n.yourdomain.com): " DOMAIN_NAME
if [ -z "$DOMAIN_NAME" ]; then
  echo -e "${RED}[ERROR] Domain name cannot be empty.${NC}"
  exit 1
fi

read -rp "Enter your Email for SSL Certificate: " SSL_EMAIL
if [ -z "$SSL_EMAIL" ]; then
  echo -e "${RED}[ERROR] Email cannot be empty.${NC}"
  exit 1
fi

read -rp "Enter Timezone (default: Asia/Tehran): " TIMEZONE
TIMEZONE=${TIMEZONE:-Asia/Tehran}

read -rp "Enter OpenRouter / OpenAI API Key (optional, press Enter to skip): " AI_API_KEY
read -rp "Enter AI Base URL (default: https://openrouter.ai/api/v1, press Enter to skip): " AI_BASE_URL
AI_BASE_URL=${AI_BASE_URL:-https://openrouter.ai/api/v1}

echo -e "\n${YELLOW}[1/4] Installing Docker and Dependencies...${NC}"
apt-get update -y && apt-get install -y curl ufw git jq

if ! command -v docker &> /dev/null; then
  curl -fsSL https://get.docker.com -o get-docker.sh
  sh get-docker.sh
  rm -f get-docker.sh
  systemctl enable --now docker
else
  echo -e "${GREEN}Docker is already installed.${NC}"
fi

apt-get install -y docker-compose-plugin

echo -e "\n${YELLOW}[2/4] Configuring Firewall...${NC}"
ufw allow 22/tcp || true
ufw allow 80/tcp || true
ufw allow 443/tcp || true
ufw --force enable || true

echo -e "\n${YELLOW}[3/4] Setting up Caddy and n8n Compose...${NC}"
INSTALL_DIR="/opt/n8n-docker"
mkdir -p "$INSTALL_DIR"
cd "$INSTALL_DIR"

cat <<EOF > Caddyfile
${DOMAIN_NAME} {
    reverse_proxy n8n:5678 {
        flush_interval -1
    }
}
EOF

cat <<EOF > docker-compose.yml
services:
  caddy:
    image: caddy:latest
    container_name: caddy-proxy
    restart: always
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./Caddyfile:/etc/caddy/Caddyfile:ro
      - caddy_data:/data
      - caddy_config:/config
    networks:
      - n8n_net

  n8n:
    image: docker.n8n.io/n8nio/n8n:latest
    container_name: n8n-app
    restart: always
    environment:
      - N8N_HOST=${DOMAIN_NAME}
      - N8N_PORT=5678
      - N8N_PROTOCOL=https
      - NODE_ENV=production
      - WEBHOOK_URL=https://${DOMAIN_NAME}/
      - GENERIC_TIMEZONE=${TIMEZONE}
      - N8N_ENFORCE_SETTINGS_FILE_PERMISSIONS=true
      - N8N_AI_OPENAI_API_KEY=${AI_API_KEY}
      - N8N_AI_OPENAI_BASE_URL=${AI_BASE_URL}
    volumes:
      - n8n_data:/home/node/.n8n
    networks:
      - n8n_net

volumes:
  caddy_data:
  caddy_config:
  n8n_data:

networks:
  n8n_net:
EOF

chmod 600 "$INSTALL_DIR/docker-compose.yml"

echo -e "\n${YELLOW}[4/4] Starting Services...${NC}"
docker compose down || true
docker compose up -d

echo -e "\n${YELLOW}[SECURITY] Applying additional hardening...${NC}"

if ! command -v fail2ban-client &> /dev/null; then
  apt-get install -y fail2ban
  systemctl enable --now fail2ban
  echo -e "${GREEN}Fail2ban installed and enabled.${NC}"
else
  echo -e "${GREEN}Fail2ban is already installed.${NC}"
fi

if [ -s /root/.ssh/authorized_keys ]; then
  sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config
  sed -i 's/#PubkeyAuthentication yes/PubkeyAuthentication yes/' /etc/ssh/sshd_config
  systemctl restart ssh
  echo -e "${GREEN}SSH hardened: password auth disabled, key auth enabled.${NC}"
else
  echo -e "${YELLOW}[WARN] No SSH keys found in /root/.ssh/authorized_keys.${NC}"
  echo -e "${YELLOW}[WARN] Skipping SSH hardening to prevent lockout.${NC}"
  echo -e "${YELLOW}[WARN] Add your SSH key first, then re-run the hardening step manually.${NC}"
fi

echo -e "\n${GREEN}====================================================${NC}"
echo -e "${GREEN}  n8n Installed & Started Successfully!             ${NC}"
echo -e "${GREEN}====================================================${NC}"
echo -e "Dashboard URL: ${CYAN}https://${DOMAIN_NAME}${NC}"
echo -e "Directory:     ${CYAN}${INSTALL_DIR}${NC}"
echo -e "Logs:          ${CYAN}cd ${INSTALL_DIR} && docker compose logs -f${NC}"
