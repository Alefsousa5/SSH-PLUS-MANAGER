# Xray no SSH-PLUS-MANAGER (V32 EN)

Adição do **Xray** (VLESS + VMess) como opção **08** no menu **MANAGE CONNECTIONS**
(opção `10` do menu principal → `conexao`).

## O que foi alterado

Apenas **um arquivo**: `Modules/conexao` (que, após a instalação, vira `/bin/conexao`).

Novidades inseridas:

| Item | Descrição |
|------|-----------|
| `fun_xray` | Menu de gerenciamento do Xray |
| `xray_inst` | Instala/remove o Xray (baixa o binário oficial do repositório XTLS/Xray-core) |
| `fun_xray_create` | Cria usuário (gera UUID e adiciona nos inbounds VLESS + VMess) |
| `fun_xray_remove` | Remove usuário |
| `fun_xray_list` | Lista usuários com links VLESS e VMess |
| `xray_link` | Gera os links `vless://` e `vmess://` |

## Menu novo (MANAGE CONNECTIONS)

```
[01] OPENSSH        [05] SOCKS PROXY
[02] SQUID PROXY    [06] SSL TUNNEL
[03] DROPBEAR       [07] SSLH MULTIPLEX
[04] OPENVPN        [08] XRAY   ◉/○
                    [09] BACK
                    [00] EXIT
```

Dentro do **MANAGE XRAY**:

```
[01] INSTALL/REMOVE XRAY
[02] CREATE USER
[03] REMOVE USER
[04] LIST USERS
[05] RESTART XRAY
[00] BACK
```

## Detalhes técnicos

- Binário: `/usr/local/bin/xray`
- Config: `/usr/local/etc/xray/config.json` (VLESS na porta 443, VMess na porta 80 — configuráveis na instalação)
- Banco de usuários: `/etc/xray/users.db` (formato `nome UUID`)
- Serviço systemd: `xray.service` (auto-start no boot)
- Protocolos: **VLESS** e **VMess** sobre WebSocket (sem TLS — fácil de subir), outbound `freedom` (direct)

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
3. Rode `menu` → opção `10` (MANAGE CONNECTIONS) → opção `08` (XRAY).

### Opção B — hospedar no seu próprio GitHub (instalação limpa)

1. Faça um fork/upload deste repositório para a sua conta GitHub.
2. Substitua `jenbhie` pelo **seu usuário** do GitHub nos arquivos `Plus` e `Install/list`
   (o script baixa os módulos de `raw.githubusercontent.com/jenbhie/...`).
   ```bash
   sed -i 's/jenbhie/SEU_USUARIO/g' Plus Install/list
   ```
3. Rode a instalação apontando para o seu repositório:
   ```bash
   apt-get update -y; apt-get upgrade -y
   wget https://raw.githubusercontent.com/SEU_USUARIO/SSH-PLUS-MANAGER/main/Plus
   chmod 777 Plus; ./Plus
   ```

### Opção C — aplicar o patch no seu fork

Existe um arquivo `0001-feat-add-Xray-....patch` no workspace com todas as mudanças:
```bash
git am 0001-feat-add-Xray-VLESS-VMess-management-as-option-09-in.patch
```

## Observações

- A instalação baixa o Xray diretamente do GitHub oficial (XTLS/Xray-core), então o VPS
  precisa de acesso à internet no momento da instalação.
- As portas 443 e 80 são abertas automaticamente no `ufw` (se estiver ativo).
- Cada usuário criado gera um UUID próprio; os links são exibidos na tela ao criar/listar.
