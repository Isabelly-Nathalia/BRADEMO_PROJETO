# Ambiente verificado (F0-T05)

Data: 2026-10-23 · Host: x86_64, Ubuntu Core 24, Docker 29.7.2 (snap), Compose v5.4.0, Node do host 20.20.2 (não usado).

## Imagens fixadas

| Imagem | Digest | Tamanho local |
|---|---|---|
| `node:24.22.1-alpine3.24` | `sha256:06d7adf3e0ef61a13f1d28682726366f97a15aa1888c934d3ecec86c33918b53` | 243,6 MB |
| `nginxinc/nginx-unprivileged:1.31.7-alpine3.24` | `sha256:b5047b9b76845eac124358373c6852377c52e4b05834a47647e955dd91cb8f1e` | 91,1 MB |
| `mcr.microsoft.com/playwright:v1.64.1-noble` | `sha256:47b510dd9230bf0b9bfc9b20102241e577ea7a99334ab4c3ca19f19770e9b8ea` | 3,58 GB |
| `mysql:8.4.13` | não baixada (perfil C, depende da F6-T01) | — |

## Resultados

| # | Verificação | Resultado |
|---|---|---|
| 1 | Pull das 3 imagens | ok |
| 2a | `docker run` com label `br.moviematch.front.teste` | ok; processo com uid 101 |
| 2b | `docker stop` | **FALHOU**: `cannot stop container: permission denied` (14 s) |
| 2c | Encerramento por dentro (`docker exec <c> nginx -s quit`) | ok; o container sai com código 0 |
| 2d | `docker rm` de container já encerrado | ok; nenhum remanescente com a label |
| 3a | `docker network create --internal` + `docker volume create`, com label | ok |
| 3b | Na rede interna: DNS de `moviematch-db-moviematch-db.k.aivencloud.com` | falhou (`EAI_AGAIN`), como esperado |
| 3c | Na rede interna: TCP para `1.1.1.1:443` | falhou (`ENETUNREACH`), como esperado |
| 3d | Escrita no volume | ok |
| 3e | `docker network rm` + `docker volume rm` | ok |
| 4 | Bind mount de `moviematch_front/` com `--user 1000:1000` (Node v24.22.1) | ok; arquivos criados pertencem a 1000:1000 |
| 5 | Estado Docker antes × depois (containers, redes, volumes) | idêntico; recursos de outros projetos intactos |

Hipótese R-05 confirmada: a imagem `nginx-unprivileged` contém `/docker-entrypoint.d/15-local-resolvers.envsh` e `20-envsubst-on-templates.sh`.

## Consequências para o plano

1. **R-01 confirmado em parte.** O daemon (snap/AppArmor) não consegue mandar sinais aos containers (`stop`/`kill`), mas containers que **terminam sozinhos** são removidos normalmente. Duas saídas:
   - **corrigir o host** (ação do usuário, fora do escopo; por exemplo `sudo snap restart docker`), seguido de um novo teste; ou
   - **projetar os perfis para encerramento por dentro**: executores (Playwright, sondas, npm) rodam até o fim com `--rm`; serviços longos (nginx, mock, mysql, backend) recebem um comando de encerramento via `docker exec` antes do `docker compose down`.
2. **A meta de imagem final ≤ 60 MB (F5-T03) é inviável**: a base já tem 91,1 MB. Meta corrigida: até 10 MB acima da base.
3. Os controles de egresso da rede `internal` funcionam no host (DNS e TCP bloqueados). Eles serão repetidos no perfil C, no namespace do backend.
