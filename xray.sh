#!/bin/bash
#=========================================================================
#   INSTALADOR RÁPIDO - XRAY MANAGER (SSHPLUS MANAGER)
#
#   USO PADRÃO:
#     bash <(curl -sL https://raw.githubusercontent.com/Alefsousa5/SSH-PLUS-MANAGER/arena/01a01a73-ssh-plus-manager/xray.sh)
#
#   FORÇAR UM BRANCH/TAG ESPECÍFICO:
#     XR_REF="main" bash <(curl -sL .../xray.sh)
#
#   INSTALAR A PARTIR DE UM CLONE LOCAL (sem internet no GitHub):
#     ./xray.sh --local
#=========================================================================
clear
RED='\033[1;31m'; GREEN='\033[1;32m'; YELLOW='\033[1;33m'; WHITE='\033[1;37m'; SCOLOR='\033[0m'

OWNER="${XR_OWNER:-Alefsousa5}"
REPO="${XR_REPO:-SSH-PLUS-MANAGER}"
DEST="/bin/xray-manager"

# Refs candidatos (na ordem). XR_REF tem prioridade.
REFS=()
[[ -n "$XR_REF" ]] && REFS+=("$XR_REF")
REFS+=("arena/01a01a73-ssh-plus-manager" "main" "master")

# Caminhos candidatos dentro do repositório (a main usa "Modulos", o branch usa "Modules")
PATHS=("Modules/xray-manager" "Modulos/xray-manager")

[[ "$(id -u)" != "0" ]] && {
	echo -e "${RED}VOCÊ PRECISA EXECUTAR COMO ROOT!${SCOLOR}"
	exit 1
}

echo -e "${RED}════════════════════════════════════════════════════${SCOLOR}"
echo -e "${WHITE}            INSTALADOR DO XRAY MANAGER              ${SCOLOR}"
echo -e "${RED}════════════════════════════════════════════════════${SCOLOR}\n"

echo -e "${YELLOW}[1/4] INSTALANDO DEPENDÊNCIAS...${SCOLOR}"
apt-get update -y >/dev/null 2>&1
apt-get install -y wget curl unzip jq net-tools lsof qrencode ca-certificates >/dev/null 2>&1

# ---------------------------------------------------------------- baixar
baixar() {
	# $1 = url destino | escreve em $TMPF ; retorna 0 se baixou algo válido
	local url="$1"
	rm -f "$TMPF"
	curl -fsSL --max-time 45 -o "$TMPF" "$url" 2>/dev/null ||
		wget -q --timeout=45 -O "$TMPF" "$url" 2>/dev/null
	# valida: precisa existir, ter conteúdo e ser um shell script (não uma página 404)
	[[ -s "$TMPF" ]] && head -1 "$TMPF" | grep -q '^#!/bin/bash' && return 0
	return 1
}

baixar_api() {
	# $1 = ref | $2 = caminho no repo. Usa api.github.com, que costuma estar
	# liberado mesmo quando raw.githubusercontent.com é bloqueado pela rede.
	local ref="$1" path="$2"
	rm -f "$TMPF"
	curl -fsSL --max-time 45 -H "Accept: application/vnd.github.v3.raw" \
		-o "$TMPF" "https://api.github.com/repos/$OWNER/$REPO/contents/$path?ref=$ref" 2>/dev/null
	[[ -s "$TMPF" ]] && head -1 "$TMPF" | grep -q '^#!/bin/bash' && return 0
	return 1
}

TMPF="/tmp/.xray-manager.dl"
OK=0
ORIGEM=""

if [[ "$1" == "--local" ]]; then
	echo -e "${YELLOW}[2/4] PROCURANDO O MÓDULO LOCALMENTE...${SCOLOR}"
	BASE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
	for p in "${PATHS[@]}"; do
		if [[ -s "$BASE/$p" ]]; then
			cp "$BASE/$p" "$TMPF"
			OK=1
			ORIGEM="arquivo local: $BASE/$p"
			break
		fi
	done
else
	echo -e "${YELLOW}[2/4] BAIXANDO O GERENCIADOR...${SCOLOR}"
	for ref in "${REFS[@]}"; do
		for p in "${PATHS[@]}"; do
			# espelho 1: raw.githubusercontent.com
			if baixar "https://raw.githubusercontent.com/$OWNER/$REPO/$ref/$p"; then
				OK=1; ORIGEM="raw.githubusercontent.com [$ref]"; break 2
			fi
			# espelho 2: github.com (raw redirect)
			if baixar "https://github.com/$OWNER/$REPO/raw/$ref/$p"; then
				OK=1; ORIGEM="github.com [$ref]"; break 2
			fi
			# espelho 3: jsDelivr CDN (útil onde o raw está bloqueado)
			if baixar "https://cdn.jsdelivr.net/gh/$OWNER/$REPO@$ref/$p"; then
				OK=1; ORIGEM="jsDelivr [$ref]"; break 2
			fi
			# espelho 4: API do GitHub (host diferente; funciona onde o raw é bloqueado)
			if baixar_api "$ref" "$p"; then
				OK=1; ORIGEM="api.github.com [$ref]"; break 2
			fi
		done
	done
fi

[[ $OK -ne 1 ]] && {
	echo -e "\n${RED}FALHA AO OBTER O SCRIPT!${SCOLOR}\n"
	echo -e "${YELLOW}Refs testados:${SCOLOR} ${REFS[*]}"
	echo -e "${YELLOW}Caminhos testados:${SCOLOR} ${PATHS[*]}\n"
	echo -e "${WHITE}Possíveis causas:${SCOLOR}"
	echo -e "  ${YELLOW}1.${SCOLOR} O VPS está sem acesso ao GitHub (teste: ${GREEN}curl -I https://github.com${SCOLOR})"
	echo -e "  ${YELLOW}2.${SCOLOR} O arquivo ainda não existe no branch informado"
	echo -e "  ${YELLOW}3.${SCOLOR} DNS quebrado no VPS (teste: ${GREEN}ping -c1 raw.githubusercontent.com${SCOLOR})\n"
	echo -e "${WHITE}Alternativa — envie o arquivo do seu PC para o VPS:${SCOLOR}"
	echo -e "  ${GREEN}scp Modules/xray-manager root@SEU_IP:/bin/xray-manager${SCOLOR}"
	echo -e "  ${GREEN}ssh root@SEU_IP 'chmod +x /bin/xray-manager && xray-manager'${SCOLOR}\n"
	rm -f "$TMPF"
	exit 1
}

echo -e "${GREEN}      → obtido de: $ORIGEM${SCOLOR}"

echo -e "${YELLOW}[3/4] INSTALANDO EM $DEST ...${SCOLOR}"
rm -f "$DEST"
mv "$TMPF" "$DEST"
sed -i 's/\r$//' "$DEST"
chmod +x "$DEST"
ln -sf "$DEST" /bin/xray-manager 2>/dev/null
[[ ! -e /bin/xray ]] && ln -sf "$DEST" /bin/xray 2>/dev/null

# valida a sintaxe antes de entregar
if ! bash -n "$DEST" 2>/dev/null; then
	echo -e "\n${RED}O ARQUIVO BAIXADO ESTÁ CORROMPIDO!${SCOLOR}"
	rm -f "$DEST"
	exit 1
fi

echo -e "${YELLOW}[4/4] REGISTRANDO IP DO SERVIDOR...${SCOLOR}"
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
