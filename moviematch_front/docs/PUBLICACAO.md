# Publicação do frontend (F8-T03)

> **Nada deste documento foi executado.** Push, PR e deploy dependem de autorização explícita do responsável pelo projeto (F8-T04). O `main` não é alterado em nenhum passo.

## 1. Pré-requisitos (bloqueantes)

| # | Pré-requisito | Situação em 2026-10-23 |
|---|---|---|
| 1 | API de produção respondendo | **Não atendido:** `https://moviematch-apkx.onrender.com` não respondia (timeout) em 22/10 |
| 2 | Contrato validado contra a produção (somente leitura) | **Pendente.** Validado só contra o backend original com banco descartável (perfil C, [contrato.md](contrato.md)). Falta conferir na produção a collation, os dados reais (nulos, grafias de streaming) e o tamanho de `GET /filmes` |
| 3 | Fork do repositório | **Pendente.** O `origin` atual é o repositório original (`Isabelly-Nathalia/BRADEMO_PROJETO`), que não é do usuário |
| 4 | Gate da F8 verde | **Atendido** (perfis A, smoke, B, C, D e E; integridade do histórico) |

A validação do item 2 usa apenas as rotas de leitura da allowlist (`GET /filmes`, `/filmes/aleatorios`, `/filmes/streaming/{s}`, `/filmes/pesquisa/{t}`, `/publicidades`) e precisa de autorização própria. Nunca escrever na produção.

## 2. Levar a branch para o fork

O usuário cria o fork no GitHub e adiciona o remote. Só a branch `front-vue` é enviada.

```bash
git remote add fork https://github.com/<usuario>/BRADEMO_PROJETO.git
```

```bash
git push -u fork front-vue
```

Nunca `git push origin`. Um PR é opcional: `front-vue` → `main` do fork, ou do repositório original se os donos quiserem; a decisão é do usuário.

## 3. Render: Web Service com Docker

Um serviço **novo**, separado do backend existente. Valores pretendidos:

| Campo | Valor |
|---|---|
| Repositório / branch | o fork / `front-vue` |
| Runtime | Docker |
| Contexto do build | `moviematch_front/` |
| Dockerfile | `moviematch_front/docker/Dockerfile` |
| Health check path | `/healthz` |
| Variável `API_UPSTREAM` | `https://moviematch-apkx.onrender.com` (sem `/` no fim) |
| Variável `API_HOST` | `moviematch-apkx.onrender.com` |
| `PORT` | não definir: o Render injeta, e a imagem escuta nela |
| Plano | o gratuito serve; o front também terá cold start |

**Conferir no painel do Render** se os campos de caminho ("Root Directory", "Dockerfile Path", "Docker Build Context Directory") são relativos à raiz do repositório ou ao Root Directory. O resultado precisa ser: contexto = `moviematch_front/` e Dockerfile = `moviematch_front/docker/Dockerfile`. Isso não foi verificado.

Nenhum segredo é necessário: o front não usa credenciais, e a URL da API é pública.

## 4. Verificação depois do deploy

Trocar `<front>` pela URL do serviço.

| Verificação | Esperado |
|---|---|
| `curl -s -o /dev/null -w '%{http_code}' https://<front>/healthz` | `200` |
| `curl -s https://<front>/api/filmes \| head -c 200` | JSON da lista de filmes (pode demorar no cold start da API) |
| `curl -s -o /dev/null -w '%{http_code}' https://<front>/api/usuarios` | `404` (bloqueado pelo proxy) |
| `curl -sI https://<front>/inicio` | `200`, com `Content-Security-Policy` e `X-Content-Type-Options: nosniff` |
| Abrir `https://<front>/filmes/1` direto | a SPA carrega (sem 404 do servidor) |
| Navegador: início, pesquisa, streaming, detalhe, questionário e sugestões | sem erro no console; imagens reais sem distorção; layout no celular e no desktop |

## 5. Riscos conhecidos da publicação

- **Resolver DNS:** o Nginx resolve o host da API em tempo de execução, com o DNS lido de `/etc/resolv.conf` (`NGINX_ENTRYPOINT_LOCAL_RESOLVERS`, `ipv6=off`). Funcionou no Docker local; **não foi testado no Render**. Sintoma, se falhar: `/healthz` 200 e toda chamada `/api` com 502.
- **Dois cold starts:** com front e API no plano gratuito, a primeira visita pode esperar os dois. O cliente desiste em 30 s e oferece "Tentar novamente".
- **Pendências da F7:** Nginx sem gzip; LCP medido só com texto; só Chromium testado (ver [metricas.md](metricas.md) e o README).

## 6. Como desfazer

O front é um serviço separado: suspender ou apagar o Web Service no Render não afeta o backend, o banco nem o app Flutter. O `main` continua intacto, e a branch `front-vue` pode ser removida do fork.
