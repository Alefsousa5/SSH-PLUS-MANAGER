# SSHPlus Manager V38 + V2ray / Xray

Cópia do [SSHPLUS-MANAGER-FREE](https://github.com/AAAAAEXQOSyIpN2JZ0ehUQ/SSHPLUS-MANAGER-FREE)
(SSHPlus Manager, versão final **38**) com **V2ray e Xray** adicionados ao menu
de conexões — VLESS + VMess sobre WebSocket, com criação e remoção de usuários
pelo próprio painel.

Todas as URLs já apontam para **este** repositório, então a instalação abaixo
instala esta versão (com V2ray/Xray), e não a original.

## Instalação no VPS

Como **root**, em Ubuntu ou Debian:

```bash
apt-get update -y; apt-get upgrade -y
wget https://raw.githubusercontent.com/Alefsousa5/SSH-PLUS-MANAGER/main/Plus
chmod +x Plus* && ./Plus
```

Ou em uma linha só:

```bash
wget https://raw.githubusercontent.com/Alefsousa5/SSH-PLUS-MANAGER/main/Plus; chmod +x Plus* && ./Plus
```

Depois de instalar, o comando principal é:

```bash
menu
```

O V2ray/Xray fica em `menu` → **GERENCIAR CONEXÕES** → opção **09**.

Requisitos: Ubuntu 16.04/18.04/20.04 ou Debian, x86_64 ou ARM64, acesso root.

## O que tem aqui

| Item | Descrição |
|---|---|
| `Plus` | Instalador (o que você baixa e roda no VPS) |
| `Modulos/` | Os 41 módulos do painel (`menu`, `conexao`, `criarusuario`, `bot`, ...) |
| `Install/` | Arquivos usados na instalação (`list`, SlowDNS, BadVPN, ShellBot, Skin_Plus, TCP-Speed) |
| `Imagenes/` | Imagens do README |
| `publicar.sh` | Copia tudo isto para **outro** repositório GitHub, ajustando as URLs |
| `V2RAY-XRAY.md` | Documentação da parte de V2ray/Xray |

## Recursos

* SSH (OpenSSH / Dropbear), Squid Proxy, OpenVPN, Proxy Socks, SSL Tunnel,
  SSLH Multiplex, SlowDNS, BadVPN, WebSocket
* **V2ray e Xray (VLESS + VMess)** — gerenciamento de usuários, links prontos
* Criação de usuários e testes, limite de conexões, expiração automática
* Bot do Telegram, monitor de conexões, backup de usuários
* Painel Web de revenda (só na cópia completa — veja abaixo)

## V2ray / Xray

Menu **GERENCIAR CONEXÕES** com a opção nova:

```
[01] OPENSSH          ◉      [06] SSL TUNNEL      ○
[02] SQUID PROXY      ○      [07] SSLH MULTIPLEX  ○
[03] DROPBEAR         ○      [08] SLOWDNS         ○
[04] OPENVPN          ○      [09] V2RAY/XRAY      ◉   ← NOVO
[05] PROXY SOCKS      ○      [10] VOLTAR
                             [00] SAIR
```

VLESS na porta 443 e VMess na porta 80 (perguntadas na instalação), links
`vless://` e `vmess://` prontos para copiar, os dois núcleos podem conviver e a
arquitetura do VPS (x86_64 ou ARM64) é detectada sozinha.
Detalhes completos em [`V2RAY-XRAY.md`](V2RAY-XRAY.md).

### Atualizar um VPS que já tem o painel instalado

Não precisa reinstalar. Só troque o módulo `conexao`:

```bash
wget -O /bin/conexao https://raw.githubusercontent.com/Alefsousa5/SSH-PLUS-MANAGER/main/Modulos/conexao
chmod +x /bin/conexao
```

## Copiar para outro repositório

O SSHPlus baixa os módulos por URL crua do GitHub durante a instalação, então as
URLs precisam apontar para o repositório certo. O `publicar.sh` cuida disso.

**1.** Crie um repositório **vazio** em <https://github.com/new>
(sem README, sem .gitignore).

**2.** Rode:

```bash
chmod +x publicar.sh

# publica TUDO (~1,1 GB: Panel_Web, Versiones, Proyectos, Source-Code)
./publicar.sh SEU_USUARIO SEU_REPO

# ou só o núcleo (~19 MB) — suficiente para instalar e usar
./publicar.sh SEU_USUARIO SEU_REPO main --nucleo
```

Ele baixa o restante da origem (no modo completo), aplica o `conexao` com
V2ray/Xray, reescreve todas as URLs para o seu repositório, commita e faz o
push — e no fim imprime o comando de instalação já com o seu link.

> **Autenticação:** se o git pedir senha, use um **Personal Access Token**
> (<https://github.com/settings/tokens>, escopo `repo`) — o GitHub não aceita
> mais senha de conta no push.

### Completo ou núcleo?

| | Núcleo (~19 MB) | Completo (~1,1 GB) |
|---|---|---|
| Instalar e usar o painel | ✅ | ✅ |
| V2ray/Xray | ✅ | ✅ |
| SlowDNS, BadVPN, Bot, Skin_Plus | ✅ | ✅ |
| Painel Web de revenda (`Install/Panel_Web`) | ❌ | ✅ |
| Versões antigas (`Versiones/`) e `Proyectos/` | ❌ | ✅ |
| Tempo de publicação | segundos | 20 min ou mais |

Este repositório é o **núcleo**. O modo completo baixa o resto direto da origem
na hora de publicar, para não guardar 1 GB de ZIPs antigos aqui.

## Créditos

* Código original: **@crazy_vpn** — canal [@sshplus](https://t.me/sshplus)
* Modificações da V38: **illuminati Dev Team**
  ([SSHPLUS-MANAGER-FREE](https://github.com/AAAAAEXQOSyIpN2JZ0ehUQ/SSHPLUS-MANAGER-FREE))
* Projeto original descontinuado em 09/08/2021
* V2ray/Xray: adicionado nesta cópia (veja [`V2RAY-XRAY.md`](V2RAY-XRAY.md))
