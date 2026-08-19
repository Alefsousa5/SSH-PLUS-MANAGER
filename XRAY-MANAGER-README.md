# XRAY MANAGER — Script Xray para VPS

Script completo e independente para instalar e gerenciar o **Xray-core** em um VPS
(Debian/Ubuntu), no mesmo padrão visual PT-BR do SSH-PLUS-MANAGER.

Arquivo principal: **`Modules/xray-manager`** (vira `/bin/xray-manager` no VPS)
Instalador rápido: **`xray.sh`**

---

## Instalação no VPS (1 comando)

```bash
bash <(curl -sL https://raw.githubusercontent.com/Alefsousa5/SSH-PLUS-MANAGER/arena/01a01a73-ssh-plus-manager/xray.sh)
```

ou

```bash
wget -O xray.sh https://raw.githubusercontent.com/Alefsousa5/SSH-PLUS-MANAGER/arena/01a01a73-ssh-plus-manager/xray.sh
chmod +x xray.sh && ./xray.sh
```

> **Importante:** os arquivos estão no branch `arena/01a01a73-ssh-plus-manager`.
> Eles **ainda não foram enviados para a `main`**, então uma URL com `/main/`
> retorna **404**. Depois de fazer o merge para a `main`, troque o trecho
> `arena/01a01a73-ssh-plus-manager` por `main` — ou use `XR_REF`:
>
> ```bash
> XR_REF="main" bash <(curl -sL https://raw.githubusercontent.com/Alefsousa5/SSH-PLUS-MANAGER/main/xray.sh)
> ```

### Se o download falhar no VPS

O instalador já tenta **4 espelhos** automaticamente (`raw.githubusercontent.com`,
`github.com`, `jsDelivr` e `api.github.com`) em cada branch candidato. Se mesmo
assim falhar, a rede do VPS está bloqueando o GitHub. Nesse caso, copie o arquivo
direto do seu PC:

```bash
scp Modules/xray-manager root@SEU_IP:/bin/xray-manager
ssh root@SEU_IP 'chmod +x /bin/xray-manager && xray-manager'
```

Ou, se você já clonou o repositório dentro do VPS:

```bash
cd SSH-PLUS-MANAGER && ./xray.sh --local
```

Depois disso, abra o painel a qualquer momento com:

```bash
xray-manager     # ou apenas: xray
```

No menu, escolha a opção **[01] INSTALAR XRAY**.

> Se você já usa o SSH-PLUS-MANAGER, o gerenciador também aparece em
> `menu` → **10 (GERENCIAR CONEXÕES)** → **09 (XRAY MANAGER)**.

---

## Menu

```
                XRAY MANAGER  V1.0
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
STATUS : ◉ ONLINE   USUÁRIOS : 3
PORTAS : WS 80 | VMESS 8080 | REALITY 443
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
[01] • INSTALAR XRAY          [08] • TLS / DOMÍNIO
[02] • CRIAR USUÁRIO          [09] • STATUS E LOGS
[03] • REMOVER USUÁRIO        [10] • REINICIAR SERVIÇO
[04] • RENOVAR USUÁRIO        [11] • ATUALIZAR XRAY-CORE
[05] • LISTAR USUÁRIOS        [12] • BACKUP / RESTAURAR
[06] • VER LINKS / QR CODE    [13] • REMOVER XRAY
[07] • ALTERAR PORTAS / PATH  [00] • SAIR
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

---

## Protocolos criados

Cada usuário criado funciona **simultaneamente** em todos os inbounds abaixo
(mesmo UUID em todos), então o cliente escolhe o que passar melhor na operadora.

| Inbound | Protocolo | Porta padrão | Segurança | Uso típico |
|---|---|---|---|---|
| `vless-ws` | VLESS + WebSocket | 80 | nenhuma | payload/HTTP injection |
| `vmess-ws` | VMess + WebSocket | 8080 | nenhuma | apps VMess clássicos |
| `vless-reality` | VLESS + REALITY + Vision | 443 | REALITY | anti-bloqueio (DPI) |
| `vless-ws-tls` | VLESS + WS + TLS | 2053 | TLS real | só se ativar domínio (opção 08) |

O inbound TLS só é criado quando você ativa um domínio na opção **[08]**
(certificado Let's Encrypt emitido via `certbot --standalone`).

---

## Recursos

- **Instalação automática** do binário oficial do [XTLS/Xray-core](https://github.com/XTLS/Xray-core), com detecção de arquitetura (amd64, arm64, armv7, armv6, x86).
- **Chaves REALITY** geradas automaticamente (`xray x25519`), com parser compatível tanto com o formato antigo (`Private key:` / `Public key:`) quanto com o novo (`PrivateKey:` / `Password:`) das versões v25+/v26.
- **Validade por usuário**: cada conta tem data de expiração; um cron a cada 6h remove as vencidas automaticamente (`xray-manager --exp-check`).
- **Renovação** de usuários somando dias à validade atual (ou a partir de hoje, se já vencida).
- **Links prontos** `vless://`, `vmess://` e `vless://...reality...` + **QR Code** no terminal (`qrencode`).
- **Alteração de portas e path** sem perder os usuários (o config é regerado a partir do banco).
- **Backup e restauração** em `.tar.gz`.
- **Firewall**: libera as portas no `ufw` automaticamente quando ele existe.
- **BitTorrent bloqueado** por regra de routing.
- Serviço **systemd** com auto-start no boot e restart em falha.

---

## Arquivos e caminhos

| Item | Caminho |
|---|---|
| Binário | `/usr/local/bin/xray` |
| Config | `/usr/local/etc/xray/config.json` |
| Banco de usuários | `/etc/xray-manager/users.db` |
| Configurações | `/etc/xray-manager/settings.conf` |
| Certificados | `/etc/xray-manager/cert/` |
| Logs | `/var/log/xray/` |
| Serviço | `/etc/systemd/system/xray.service` |
| Gerenciador | `/bin/xray-manager` |

Formato do banco de usuários (`users.db`):

```
nome|uuid|validade
joao|11111111-1111-1111-1111-111111111111|2026-09-18
```

O `config.json` é sempre **reconstruído a partir do `users.db`**, então editar o
banco e rodar qualquer ação do menu já sincroniza os inbounds.

---

## Uso por linha de comando

```bash
xray-manager              # abre o menu
xray-manager --install    # vai direto para a instalação
xray-manager --status     # status, portas e últimos logs
xray-manager --list       # lista os usuários
xray-manager --exp-check  # remove vencidos (usado pelo cron)
```

---

## Dicas

- **Porta 80 ocupada?** Se o Apache/Nginx já usa a 80, escolha outra porta para o
  VLESS-WS na instalação (ex.: 8880). O script recusa portas em uso.
- **REALITY** não precisa de domínio nem certificado — é a opção mais resistente a bloqueio.
- **SNI do REALITY**: use um site real e grande, com TLS 1.3 e HTTP/2
  (padrão `www.microsoft.com`; alternativas: `www.cloudflare.com`, `dl.google.com`).
- Para **TLS com domínio**, aponte o DNS (registro A) para o IP do VPS **antes** de
  usar a opção 08, e deixe a porta 80 livre durante a emissão do certificado.

---

## Requisitos

- Debian 9+ / Ubuntu 18.04+ (systemd), acesso **root**
- Acesso à internet no momento da instalação (baixa o binário do GitHub)
- Dependências instaladas automaticamente: `wget curl unzip jq net-tools lsof qrencode`
