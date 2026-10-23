# Problemas comuns

Os itens abaixo aconteceram de fato durante o desenvolvimento ou são mensagens que o próprio projeto emite. Comandos a partir de `moviematch_front/`.

## Ambiente

**`npm` ou `node` reclamam da versão (Vitest, jsdom ou axe exigem Node ≥ 22.12).**
O projeto usa Node 24 (`.nvmrc`). Sem ele no host, rode tudo por `scripts/npm.sh`, por exemplo `scripts/npm.sh npm ci` ou `scripts/npm.sh npm test`. Ele monta só esta pasta em `node:24` e roda com o seu usuário.

**`docker stop` ou o fim de um perfil falham com `permission denied` (Docker instalado por snap).**
O daemon do snap às vezes perde a permissão (AppArmor) para mandar sinais aos containers. Rode `sudo snap restart docker` e repita. O `perfil.sh` avisa quando não conseguiu remover algo e imprime o ID da execução.

**Bind mount vazio ou com erro (Docker snap).**
O Docker do snap não enxerga `/tmp` do host. Mantenha o projeto dentro de `$HOME`.

**Uma execução de perfil foi interrompida e deixou containers ou rede.**
Os recursos têm a label `br.moviematch.front.teste=<id>`. Liste com `docker ps -a --filter label=br.moviematch.front.teste` e remova só os daquela execução com `scripts/perfil.sh limpar <id>`. Não use `docker system prune`: ele apagaria recursos de outros projetos.

**`test-results/` aparece com arquivos de falha do Playwright.**
É a saída das falhas (captura de tela, `error-context.md` e trace), ignorada pelo git. O trace abre com `npx playwright show-trace <arquivo>` numa máquina com Node 24 e interface gráfica (não dentro do `scripts/npm.sh`). Pode apagar a pasta.

## Container de produção

**O container sai na hora com `moviematch: defina API_UPSTREAM` (ou `API_HOST`, ou `PORT deve ser numérica`).**
Faltam variáveis obrigatórias. `API_UPSTREAM` começa com `http://` ou `https://` e não termina com `/`; `API_HOST` é o host dela (ex.: `moviematch-apkx.onrender.com`).

**`/healthz` responde 200, mas a interface mostra "O servidor encontrou um erro."**
`/healthz` só indica que o Nginx está no ar, de propósito. Erro 502 nas chamadas `/api` significa que o Nginx não alcançou a API: confira `API_UPSTREAM` e se a API está de pé.

**A interface mostra "O servidor demorou demais para responder."**
O cliente desiste depois de 30 s. No Render, a primeira requisição depois de um tempo parado pode demorar (cold start); o aviso "O servidor pode estar iniciando" aparece aos 5 s. Use "Tentar novamente" depois de alguns segundos.

**Uma rota `/api/...` responde 404 sem chegar ao backend.**
Ela não está em `api-allowlist.json`, por decisão: o front só repassa as rotas de que precisa. Para liberar uma rota nova, edite o JSON, rode `scripts/npm.sh npm run gerar:allowlist` e rode os perfis A e D.

**O build ou o perfil A falham em `check:allowlist`.**
`docker/nginx/allowlist.conf` está diferente do que `api-allowlist.json` gera. Rode `scripts/npm.sh npm run gerar:allowlist` e faça o commit dos dois arquivos juntos.

## Desenvolvimento

**`/api/...` responde 503 "API não configurada: defina MM_API_UPSTREAM" no `npm run dev`.**
O servidor do Vite não sabe para onde repassar. Defina `MM_API_UPSTREAM` (veja `.env.example` e o README).

**A porta 5173 ou 8080 já está em uso.**
Troque só o lado do host no `-p`, por exemplo `-p 127.0.0.1:5174:5173`.

**A pesquisa mostra 'A pesquisa não pode conter "/".'**
É intencional. A API recebe o termo no caminho da URL, e uma barra mudaria a rota.

## Perfil C (backend original)

**O perfil C falha porque não encontra a imagem `moviematch-back:baseline`.**
A imagem é construída a partir do `Dockerfile` da raiz do repositório, sem alterações: na raiz, `docker build -t moviematch-back:baseline .`. O perfil sobe essa imagem com um MySQL descartável na rede interna e **verifica antes de qualquer dado** que o backend não alcança a internet nem o banco de produção. Se essa verificação reprovar, o perfil para.
