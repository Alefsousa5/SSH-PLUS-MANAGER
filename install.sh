#!/bin/bash
# =================================================================
#   SSHPLUS ALEF - SCRIPT DE INSTALACAO PARA VPS
#   Instala o SSHPLUS MANAGER somente com XRAY (VLESS/VMess)
#   Sistemas: Ubuntu 18.04/20.04/22.04/24.04 | Debian 9/10/11/12
#
#   Uso (como root):
#     bash install.sh
#
#   Depois de instalado:
#     menu      -> painel principal
#     sshplus   -> atualiza/reinstala o script (update)
# =================================================================
clear

RED='\033[1;31m'; GREEN='\033[1;32m'; YELLOW='\033[1;33m'
BLUE='\033[1;34m'; CYAN='\033[1;36m'; NC='\033[0m'

# Repositorio do script (troque para SSHPLUS-ALEF quando publicar)
REPO="https://raw.githubusercontent.com/Alefsousa5/SSH-PLUS-MANAGER/main"

echo -e "${BLUE}════════════════════════════════════════════════════════${NC}"
echo -e "        ${GREEN}SSHPLUS ALEF${NC} ${YELLOW}- INSTALADOR VPS + XRAY${NC}"
echo -e "${BLUE}════════════════════════════════════════════════════════${NC}"
echo ""

# ---------- Verifica root ----------
[[ "$(whoami)" != "root" ]] && {
  echo -e "${RED}[ERRO] Execute como root! Use: sudo bash install.sh${NC}"
  exit 1
}

# ---------- 1) Atualiza o sistema ----------
echo -e "${YELLOW}[1/4] ATUALIZANDO O SISTEMA...${NC}"
apt-get update -y
apt-get upgrade -y

# ---------- 2) Pacotes essenciais ----------
echo ""
echo -e "${YELLOW}[2/4] INSTALANDO PACOTES ESSENCIAIS...${NC}"
apt-get install -y bc screen nano unzip lsof net-tools dos2unix nload \
                   jq curl wget figlet python3 python3-pip zip git cron \
                   > /dev/null 2>&1

# ---------- 3) Baixa e executa o instalador do SSHPLUS ----------
echo ""
echo -e "${YELLOW}[3/4] BAIXANDO SSHPLUS MANAGER...${NC}"
cd "$HOME"
wget -qO Plus "$REPO/Plus"
chmod +x Plus
./Plus

# ---------- 4) Atalhos de comando (update) ----------
echo "menu" > /bin/h 2>/dev/null
chmod +x /bin/h 2>/dev/null

cat > /bin/sshplus <<EOF
#!/bin/bash
# SSHPLUS ALEF - Atualizar/Reinstalar
wget -qO /tmp/Plus $REPO/Plus
chmod +x /tmp/Plus
/tmp/Plus
EOF
chmod +x /bin/sshplus 2>/dev/null

echo ""
echo -e "${GREEN}════════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}          INSTALACAO CONCLUIDA COM SUCESSO!${NC}"
echo -e "${BLUE}  Painel principal : ${CYAN}menu${NC}"
echo -e "${BLUE}  Atualizar script : ${CYAN}sshplus${NC}"
echo -e "${BLUE}  XRAY (VLESS/VMess): menu -> GERENCIAR CONEXOES -> XRAY${NC}"
echo -e "${GREEN}════════════════════════════════════════════════════════${NC}"
