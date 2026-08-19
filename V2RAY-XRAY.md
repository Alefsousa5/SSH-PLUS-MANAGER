# V2ray / Xray no SSHPlus Manager V38

Adição do **V2ray** e do **Xray** (VLESS + VMess sobre WebSocket) como opção **09**
do menu **MODO DE CONEXÃO** (`menu` → `GERENCIAR CONEXÕES` → `09`).

Todo o código novo fica em **um único arquivo**: `Modulos/conexao` — que após a
instalação vira `/bin/conexao`. Nenhum outro módulo foi alterado, então o resto
do script (SSH, Dropbear, Squid, OpenVPN, SlowDNS, BadVPN, Bot, Painel) continua
exatamente igual ao original.

## Menu novo

```
[01] OPENSSH          ◉      [06] SSL TUNNEL      ○
[02] SQUID PROXY      ○      [07] SSLH MULTIPLEX  ○
[03] DROPBEAR         ○      [08] SLOWDNS         ○
[04] OPENVPN          ○      [09] V2RAY/XRAY      ◉   ← NOVO
[05] PROXY SOCKS      ○      [10] VOLTAR
                             [00] SAIR
```

Dentro de **GERENCIAR V2RAY / XRAY**:

```
V2RAY: 443,80    USUÁRIOS: 3
XRAY : 8443,8080 USUÁRIOS: 1

[01] INSTALAR/REMOVER V2RAY   ◉
[02] INSTALAR/REMOVER XRAY    ◉
[03] CRIAR USUÁRIO
[04] REMOVER USUÁRIO
[05] LISTAR USUÁRIOS
[06] REINICIAR SERVIÇO
[00] VOLTAR
```

Os dois núcleos podem ficar instalados ao mesmo tempo (em portas diferentes).
Quando isso acontece, o script pergunta qual núcleo você quer gerenciar antes de
criar, remover ou listar usuários.

## Funções adicionadas

| Função | Descrição |
|---|---|
| `fun_v2x` | Menu de gerenciamento do V2ray/Xray |
| `v2x_arch` | Detecta a arquitetura do VPS (x86_64, arm64, arm32, x86) |
| `v2x_paths` | Define binário, config, serviço e URL de download de cada núcleo |
| `v2x_inst` | Instala ou remove o núcleo (baixa o binário oficial do GitHub) |
| `v2x_resolve` | Descobre qual núcleo está instalado / pergunta quando há dois |
| `v2x_uuid` | Gera o UUID do usuário |
| `v2x_link` | Monta os links `vless://` e `vmess://` |
| `fun_v2x_create` | Cria usuário (adiciona o UUID nos inbounds VLESS e VMess) |
| `fun_v2x_remove` | Remove usuário (tira o UUID dos inbounds) |
| `fun_v2x_list` | Lista usuários com UUID e links prontos para copiar |

## Detalhes técnicos

| Núcleo | Binário | Config | Origem |
|---|---|---|---|
| V2ray | `/usr/local/bin/v2ray` | `/usr/local/etc/v2ray/config.json` | [v2fly/v2ray-core](https://github.com/v2fly/v2ray-core) (release mais recente) |
| Xray | `/usr/local/bin/xray` | `/usr/local/etc/xray/config.json` | [XTLS/Xray-core](https://github.com/XTLS/Xray-core) (release mais recente) |

* **VLESS** na porta **443** e **VMess** na porta **80** (as duas perguntadas na
  instalação; a porta é checada antes com `verif_ptrs`, igual aos outros serviços
  do painel, para não conflitar).
* Transporte **WebSocket** com `path: /`, sem TLS — é o modo que funciona direto,
  sem precisar de domínio nem certificado. Para usar com TLS/CDN, coloque um
  Nginx ou o Cloudflare na frente.
* Outbound `freedom` (saída direta).
* Banco de usuários: `/etc/v2x/users-v2ray.db` e `/etc/v2x/users-xray.db`,
  formato `nome UUID` (uma linha por usuário).
* Serviços systemd `v2ray.service` / `xray.service`, com `enable` (sobem sozinhos
  no boot) e `Restart=on-failure`.
* Se o `ufw` estiver instalado, as portas são liberadas automaticamente.
* O IP usado nos links vem de `/etc/IP`, o mesmo arquivo que o SSHPlus já cria.
* Depende de `jq`, `unzip` e `wget` — todos já instalados pelo `Plus`.
* Arquitetura detectada automaticamente: funciona em VPS **x86_64** e também em
  **ARM64** (Oracle Cloud Ampere, por exemplo).

## Aplicar em um VPS que JÁ tem o SSHPlus instalado

Não precisa reinstalar nada. Só troque o módulo `conexao`:

```bash
# no seu computador
scp Modulos/conexao root@SEU_IP:/bin/conexao

# no VPS
chmod +x /bin/conexao
```

Ou direto no VPS, puxando do seu repositório:

```bash
wget -O /bin/conexao https://raw.githubusercontent.com/SEU_USUARIO/SEU_REPO/main/Modulos/conexao
chmod +x /bin/conexao
```

Depois rode `menu` → `GERENCIAR CONEXÕES` → `09`.

## Instalação limpa a partir do seu repositório

Veja o `README.md` — o `publicar.sh` já deixa todas as URLs apontando para o seu
GitHub, então a instalação puxa esta versão com V2ray/Xray.
