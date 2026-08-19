#!/bin/bash
# ============================================================================
#  publicar.sh - Publica o SSHPlus Manager V38 + V2ray/Xray no SEU GitHub
# ============================================================================
#
#  USO:
#    ./publicar.sh <usuario> <repositorio> [branch]
#
#  EXEMPLO:
#    ./publicar.sh Alefsousa5 SSHPLUS-MANAGER-V38
#
#  OPCOES:
#    --completo   (padrao) Baixa o repositorio original inteiro (~1,1 GB:
#                 Panel_Web, Versiones, Proyectos, Source-Code) e publica
#                 TUDO ja com o V2ray/Xray aplicado.
#    --nucleo     Publica apenas o nucleo (~19 MB): Plus, Modulos, Install
#                 essencial, Imagenes. E o suficiente para instalar e usar.
#
#  O script reescreve automaticamente TODAS as URLs do repositorio original
#  para o SEU usuario/repositorio, para que a instalacao baixe os modulos
#  do SEU GitHub (senao o V2ray/Xray nao aparece no menu).
# ============================================================================

set -u

UPSTREAM_USER="AAAAAEXQOSyIpN2JZ0ehUQ"
UPSTREAM_REPO="SSHPLUS-MANAGER-FREE"
UPSTREAM_BRANCH="master"
UPSTREAM_URL="https://github.com/$UPSTREAM_USER/$UPSTREAM_REPO.git"

# repositorio atual (de onde este script esta rodando) - as URLs dos arquivos
# daqui apontam para ele, entao tambem precisam ser reescritas
ATUAL_USER="Alefsousa5"
ATUAL_REPO="SSH-PLUS-MANAGER"
ATUAL_BRANCH="main"

AQUI="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MODO="completo"

vermelho() { echo -e "\033[1;31m$*\033[0m"; }
verde()    { echo -e "\033[1;32m$*\033[0m"; }
amarelo()  { echo -e "\033[1;33m$*\033[0m"; }
ciano()    { echo -e "\033[1;36m$*\033[0m"; }

uso() {
	cat <<EOF

  USO: ./publicar.sh <usuario> <repositorio> [branch] [--completo|--nucleo]

  EXEMPLOS:
    ./publicar.sh Alefsousa5 SSHPLUS-MANAGER-V38
    ./publicar.sh Alefsousa5 SSHPLUS-MANAGER-V38 main --nucleo

  Crie o repositorio VAZIO antes em: https://github.com/new

EOF
	exit 1
}

# ---------------------------------------------------------------- argumentos
ARGS=()
for a in "$@"; do
	case "$a" in
	--completo) MODO="completo" ;;
	--nucleo) MODO="nucleo" ;;
	-h | --help) uso ;;
	*) ARGS+=("$a") ;;
	esac
done

[[ ${#ARGS[@]} -lt 2 ]] && uso

GH_USER="${ARGS[0]}"
GH_REPO="${ARGS[1]}"
GH_BRANCH="${ARGS[2]:-main}"

command -v git >/dev/null 2>&1 || {
	vermelho "  [ERRO] git nao encontrado. Instale com: apt install git -y"
	exit 1
}

clear
echo ""
ciano "  ════════════════════════════════════════════════════════════"
ciano "     PUBLICAR SSHPLUS MANAGER V38 + V2RAY/XRAY NO SEU GITHUB"
ciano "  ════════════════════════════════════════════════════════════"
echo ""
echo -e "  Destino : \033[1;37mhttps://github.com/$GH_USER/$GH_REPO\033[0m"
echo -e "  Branch  : \033[1;37m$GH_BRANCH\033[0m"
echo -e "  Modo    : \033[1;37m$MODO\033[0m"
echo ""

TMP="$(mktemp -d /tmp/sshplus-publicar.XXXXXX)"
trap 'rm -rf "$TMP"' EXIT

if [[ "$MODO" == "completo" ]]; then
	amarelo "  [1/5] Baixando o repositorio original completo (~1,1 GB)..."
	amarelo "        Isso pode demorar bastante. Aguarde."
	echo ""
	git clone --depth 1 --branch "$UPSTREAM_BRANCH" "$UPSTREAM_URL" "$TMP/repo" || {
		vermelho "  [ERRO] Falha ao clonar o repositorio original."
		exit 1
	}
	rm -rf "$TMP/repo/.git"

	echo ""
	amarelo "  [2/5] Aplicando o modulo V2ray/Xray e a documentacao..."
	cp -f "$AQUI/Modulos/conexao" "$TMP/repo/Modulos/conexao"
	cp -f "$AQUI/credits" "$TMP/repo/credits"
	cp -f "$AQUI/README.md" "$TMP/repo/README.md"
	cp -f "$AQUI/V2RAY-XRAY.md" "$TMP/repo/V2RAY-XRAY.md"
	cp -f "$AQUI/publicar.sh" "$TMP/repo/publicar.sh"
	[[ -f "$AQUI/LICENSE" ]] && cp -f "$AQUI/LICENSE" "$TMP/repo/LICENSE"
else
	amarelo "  [1/5] Copiando o nucleo deste diretorio (~19 MB)..."
	mkdir -p "$TMP/repo"
	(cd "$AQUI" && tar --exclude=.git -cf - .) | (cd "$TMP/repo" && tar -xf -)
	echo ""
	amarelo "  [2/5] Modulo V2ray/Xray ja incluido."
fi

# ------------------------------------------------- reescrita das URLs (raw)
echo ""
amarelo "  [3/5] Apontando as URLs para o SEU repositorio..."
PARA="$GH_USER/$GH_REPO/$GH_BRANCH"
PARA2="$GH_USER/$GH_REPO"
ALTERADOS=0
while IFS= read -r -d '' arq; do
	grep -Iq . "$arq" 2>/dev/null || continue # pula binarios
	mudou=0
	for par in "$UPSTREAM_USER/$UPSTREAM_REPO/$UPSTREAM_BRANCH|$UPSTREAM_USER/$UPSTREAM_REPO" \
		"$ATUAL_USER/$ATUAL_REPO/$ATUAL_BRANCH|$ATUAL_USER/$ATUAL_REPO"; do
		DE="${par%%|*}"
		DE2="${par##*|}"
		[[ "$DE2" == "$PARA2" ]] && continue # ja e o destino
		if grep -q "$DE2" "$arq" 2>/dev/null; then
			sed -i "s|$DE|$PARA|g; s|$DE2|$PARA2|g" "$arq"
			mudou=1
		fi
	done
	[[ "$mudou" == "1" ]] && ALTERADOS=$((ALTERADOS + 1))
done < <(find "$TMP/repo" -type f -print0)
verde "        $ALTERADOS arquivo(s) atualizado(s)."

# nos arquivos .md, os links de CREDITO ao projeto original nao devem apontar
# para o repositorio novo - so as URLs "raw" (de download) e que mudam
while IFS= read -r -d '' md; do
	sed -i "s|github.com/$PARA2/blob|github.com/$UPSTREAM_USER/$UPSTREAM_REPO/blob|g" "$md"
	sed -i "s|(https://github.com/$PARA2)|(https://github.com/$UPSTREAM_USER/$UPSTREAM_REPO)|g" "$md"
done < <(find "$TMP/repo" -maxdepth 1 -name '*.md' -print0)

# ------------------------------------------------------------- aviso 100 MB
GRANDES=$(find "$TMP/repo" -type f -size +100M | wc -l)
[[ "$GRANDES" != "0" ]] && {
	echo ""
	vermelho "  [AVISO] $GRANDES arquivo(s) acima de 100 MB - o GitHub REJEITA esses arquivos."
	find "$TMP/repo" -type f -size +100M -printf '          %p\n'
	echo -ne "  Remover esses arquivos e continuar? [s/n]: "
	read -r rr
	[[ "$rr" == "s" ]] && find "$TMP/repo" -type f -size +100M -delete || exit 1
}

# ------------------------------------------------------------------- commit
echo ""
amarelo "  [4/5] Criando o commit..."
cd "$TMP/repo" || exit 1
git init -q
git checkout -q -b "$GH_BRANCH"
git add -A
git -c user.name="$GH_USER" -c user.email="$GH_USER@users.noreply.github.com" \
	commit -q -m "SSHPlus Manager V38 com suporte a V2ray/Xray (VLESS + VMess)" || {
	vermelho "  [ERRO] Nada para commitar."
	exit 1
}
verde "        $(git ls-files | wc -l) arquivo(s) - $(du -sh --exclude=.git . | cut -f1)"

# --------------------------------------------------------------------- push
echo ""
amarelo "  [5/5] Enviando para o GitHub..."
echo ""
echo -e "  \033[1;33mSe pedir senha, use um Personal Access Token\033[0m"
echo -e "  \033[1;33m(github.com/settings/tokens - marque o escopo 'repo').\033[0m"
echo ""
git remote add origin "https://github.com/$GH_USER/$GH_REPO.git"
if git push -u origin "$GH_BRANCH"; then
	echo ""
	verde "  ════════════════════════════════════════════════════════════"
	verde "     PUBLICADO COM SUCESSO !"
	verde "  ════════════════════════════════════════════════════════════"
	echo ""
	echo -e "  Repositorio: \033[1;36mhttps://github.com/$GH_USER/$GH_REPO\033[0m"
	echo ""
	amarelo "  Instale no seu VPS com:"
	echo ""
	echo -e "\033[1;37m  apt-get update -y; apt-get upgrade -y"
	echo -e "  wget https://raw.githubusercontent.com/$GH_USER/$GH_REPO/$GH_BRANCH/Plus"
	echo -e "  chmod +x Plus* && ./Plus\033[0m"
	echo ""
else
	echo ""
	vermelho "  [ERRO] O push falhou."
	echo ""
	amarelo "  Verifique se:"
	echo "    - O repositorio $GH_USER/$GH_REPO ja existe (crie em github.com/new)"
	echo "    - Voce tem permissao de escrita nele"
	echo "    - O token/credencial informado esta correto"
	echo ""
	amarelo "  Os arquivos prontos ficaram em: $TMP/repo"
	trap - EXIT
	exit 1
fi
