#!/bin/bash
#=========================================================================
#   INSTALADOR RÁPIDO - XRAY MANAGER (SSHPLUS MANAGER)
#   USO: wget -O xray.sh https://raw.githubusercontent.com/Alefsousa5/SSH-PLUS-MANAGER/main/xray.sh
#        chmod +x xray.sh && ./xray.sh
#   OU:  bash <(curl -sL https://raw.githubusercontent.com/Alefsousa5/SSH-PLUS-MANAGER/main/xray.sh)
#=========================================================================
clear
RED='\033[1;31m'; GREEN='\033[1;32m'; YELLOW='\033[1;33m'; WHITE='\033[1;37m'; SCOLOR='\033[0m'
REPO_RAW="https://raw.githubusercontent.com/Alefsousa5/SSH-PLUS-MANAGER/main"
DEST="/bin/xray-manager"

[[ "$(id -u)" != "0" ]] && {
	echo -e "${RED}VOCÊ PRECISA EXECUTAR COMO ROOT!${SCOLOR}"
	exit 1
}

echo -e "${RED}════════════════════════════════════════════════════${SCOLOR}"
echo -e "${WHITE}            INSTALADOR DO XRAY MANAGER              ${SCOLOR}"
echo -e "${RED}════════════════════════════════════════════════════${SCOLOR}\n"

echo -e "${YELLOW}[1/3] INSTALANDO DEPENDÊNCIAS...${SCOLOR}"
apt-get update -y >/dev/null 2>&1
apt-get install -y wget curl unzip jq net-tools lsof qrencode ca-certificates >/dev/null 2>&1

echo -e "${YELLOW}[2/3] BAIXANDO O GERENCIADOR...${SCOLOR}"
rm -f "$DEST"
if ! wget -q "$REPO_RAW/Modules/xray-manager" -O "$DEST"; then
	curl -sLo "$DEST" "$REPO_RAW/Modules/xray-manager"
fi
[[ ! -s "$DEST" ]] && {
	echo -e "${RED}FALHA AO BAIXAR O SCRIPT! VERIFIQUE A INTERNET DO VPS.${SCOLOR}"
	rm -f "$DEST"
	exit 1
}
command -v dos2unix >/dev/null 2>&1 && dos2unix "$DEST" >/dev/null 2>&1
sed -i 's/\r$//' "$DEST"
chmod +x "$DEST"
ln -sf "$DEST" /bin/xray 2>/dev/null

echo -e "${YELLOW}[3/3] REGISTRANDO IP DO SERVIDOR...${SCOLOR}"
[[ ! -s /etc/IP ]] && {
	ip=$(wget -qO- -T 5 ipv4.icanhazip.com 2>/dev/null | tr -d '[:space:]')
	[[ -z "$ip" ]] && ip=$(curl -s -m 5 https://api.ipify.org 2>/dev/null)
	[[ -n "$ip" ]] && echo "$ip" >/etc/IP
}

echo ""
echo -e "${GREEN}• INSTALAÇÃO CONCLUÍDA COM SUCESSO •${SCOLOR}\n"
echo -e "${YELLOW}COMANDO PRINCIPAL: ${GREEN}xray-manager${SCOLOR}"
echo -e "${YELLOW}ATALHO           : ${GREEN}xray${SCOLOR}\n"
echo -e "${WHITE}Abrindo o menu em 3 segundos...${SCOLOR}"
sleep 3
exec "$DEST"
