# V2ray / Xray no SSH-PLUS-MANAGER (V33 PT-BR)

Adição do **V2ray** e do **Xray** (VLESS + VMess) como opção **08** no menu
**GERENCIAR CONEXÕES** (opção `10` do menu principal → `conexao`).

## O que foi alterado

Apenas **um arquivo**: `Modules/conexao` (que, após a instalação, vira `/bin/conexao`).

| Item | Descrição |
|------|-----------|
| `fun_v2x` | Menu de gerenciamento do V2ray/Xray |
| `v2x_inst` | Instala/remove o V2ray ou o Xray (baixa o binário oficial) |
| `v2x_paths` | Define binário/config/serviço de cada núcleo |
| `fun_v2x_create` | Cria usuário (gera UUID e adiciona nos inbounds VLESS + VMess) |
| `fun_v2x_remove` | Remove usuário |
| `fun_v2x_list` | Lista usuários com links VLESS e VMess |
| `v2x_link` | Gera os links `vless://` e `vmess://` |

## Menu novo (GERENCIAR CONEXÕES)

```
[01] OPENSSH        [05] SOCKS PROXY
[02] SQUID PROXY    [06] SSL TUNNEL
[03] DROPBEAR       [07] SSLH MULTIPLEX
[04] OPENVPN        [08] V2RAY/XRAY   ◉/○
                    [09] VOLTAR
                    [00] SAIR
```

Dentro do **GERENCIAR V2RAY / XRAY**:

```
[01] INSTALAR/REMOVER V2RAY   ◉/○
[02] INSTALAR/REMOVER XRAY    ◉/○
[03] CRIAR USUÁRIO
[04] REMOVER USUÁRIO
[05] LISTAR USUÁRIOS
[06] REINICIAR SERVIÇO
[00] VOLTAR
```

Você pode instalar os dois núcleos ao mesmo tempo. Ao criar/remover/listar
usuários, se ambos estiverem instalados, o script pergunta qual núcleo gerenciar.

## Detalhes técnicos

| Núcleo | Binário | Config | Repositório |
|--------|---------|--------|-------------|
| V2ray  | `/usr/local/bin/v2ray` | `/usr/local/etc/v2ray/config.json` | [v2fly/v2ray-core](https://github.com/v2fly/v2ray-core) |
| Xray   | `/usr/local/bin/xray`  | `/usr/local/etc/xray/config.json`  | [XTLS/Xray-core](https://github.com/XTLS/Xray-core) |

- VLESS na porta **443** e VMess na porta **80** (configuráveis na instalação)
- Banco de usuários: `/etc/v2x/users-v2ray.db` e `/etc/v2x/users-xray.db` (formato `nome UUID`)
- Serviços systemd: `v2ray.service` e `xray.service` (auto-start no boot)
- Protocolos: **VLESS** e **VMess** sobre WebSocket (sem TLS — fácil de subir), outbound `freedom` (direct)
- UUID gerado via `/proc/sys/kernel/random/uuid`

## Como aplicar no seu VPS

### Opção A — aplicar em uma instalação já existente

1. Copie o arquivo modificado para o VPS:
   ```bash
   scp Modules/conexao root@SEU_IP:/bin/conexao
   ```
2. No VPS:
   ```bash
   chmod +x /bin/conexao
   ```
3. Rode `menu` → opção `10` (GERENCIAR CONEXÕES) → opção `08` (V2RAY/XRAY).

### Opção B — hospedar no seu próprio GitHub (instalação limpa)

1. Faça um fork/upload deste repositório para a sua conta GitHub.
2. Substitua `jenbhie` pelo **seu usuário** do GitHub nos arquivos `Plus` e `Install/list`.
3. Rode a instalação apontando para o seu repositório.

## Observações

- A instalação baixa os binários diretamente do GitHub oficial (v2fly / XTLS), então o VPS
  precisa de acesso à internet no momento da instalação.
- As portas 443 e 80 são abertas automaticamente no `ufw` (se estiver ativo).
- Cada usuário criado gera um UUID próprio; os links são exibidos na tela ao criar/listar.
