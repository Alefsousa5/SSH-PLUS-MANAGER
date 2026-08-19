# SSHPlus Manager V38 + V2ray / Xray

Cópia do [SSHPLUS-MANAGER-FREE](https://github.com/AAAAAEXQOSyIpN2JZ0ehUQ/SSHPLUS-MANAGER-FREE)
(SSHPlus Manager, versão final **38**) com **V2ray e Xray** adicionados ao menu
de conexões — VLESS + VMess sobre WebSocket, com criação e remoção de usuários
pelo próprio painel.

## O que tem aqui

| Item | Descrição |
|---|---|
| `Plus` | Instalador (o que você baixa e roda no VPS) |
| `Modulos/` | Os 41 módulos do painel (`menu`, `conexao`, `criarusuario`, `bot`, ...) |
| `Install/` | Arquivos usados na instalação (`list`, SlowDNS, BadVPN, ShellBot, Skin_Plus, TCP-Speed) |
| `Imagenes/` | Imagens do README |
| `publicar.sh` | Publica tudo isso no **seu** repositório GitHub, já com as URLs ajustadas |
| `V2RAY-XRAY.md` | Documentação da parte de V2ray/Xray |

## Recursos

* SSH (OpenSSH / Dropbear), Squid Proxy, OpenVPN, Proxy Socks, SSL Tunnel,
  SSLH Multiplex, SlowDNS, BadVPN, WebSocket
* **V2ray e Xray (VLESS + VMess)** — gerenciamento de usuários, links prontos
* Criação de usuários e testes, limite de conexões, expiração automática
* Bot do Telegram, monitor de conexões, backup de usuários
* Painel Web de revenda (nas versões completas — veja abaixo)

## Instalação no VPS

> Troque `SEU_USUARIO` e `SEU_REPO` pelos seus, depois de publicar (veja a seção
> seguinte). Enquanto não publicar, o comando abaixo não existe ainda.

```bash
apt-get update -y; apt-get upgrade -y
wget https://raw.githubusercontent.com/SEU_USUARIO/SEU_REPO/main/Plus
chmod +x Plus* && ./Plus
```

Depois de instalar, o comando principal é:

```bash
menu
```

O V2ray/Xray fica em `menu` → **GERENCIAR CONEXÕES** → opção **09**.

Requisitos: Ubuntu 16.04/18.04/20.04 ou Debian, x86_64 ou ARM64, como **root**.

## Publicar no seu GitHub

O SSHPlus baixa os módulos por URL crua do GitHub durante a instalação. Por isso
não basta copiar os arquivos: as URLs precisam apontar para o **seu**
repositório, senão a instalação puxa o original (sem V2ray/Xray). O
`publicar.sh` faz isso sozinho.

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

O script:

1. baixa o repositório original (no modo completo),
2. aplica por cima o `Modulos/conexao` com V2ray/Xray,
3. reescreve **todas** as URLs `AAAAAEXQOSyIpN2JZ0ehUQ/SSHPLUS-MANAGER-FREE/master`
   para `SEU_USUARIO/SEU_REPO/main`,
4. cria o commit e faz o push.

No fim ele imprime o comando de instalação já com o seu link.

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

O que este repositório contém é o **núcleo**. O modo completo baixa o resto
direto da origem na hora de publicar — assim nada de 1 GB precisa ficar
armazenado aqui.

## Créditos

* Código original: **@crazy_vpn** — canal [@sshplus](https://t.me/sshplus)
* Modificações da V38: **illuminati Dev Team**
* Projeto original descontinuado em 09/08/2021
* V2ray/Xray: adicionado nesta cópia (veja `V2RAY-XRAY.md`)
