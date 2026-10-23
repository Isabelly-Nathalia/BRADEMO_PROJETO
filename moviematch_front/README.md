# MovieMatch: frontend em Vue

Frontend web do MovieMatch em Vue 3, substituindo o app Flutter (`../projeto_brademo/`) no navegador. Consome a API legada em Spring Boot (`../moviematch_back/`) **sem modificá-la**, por um proxy de mesma origem com lista de rotas permitidas.

- **Plano, decisões e desvios:** [docs/PLANO_IMPLEMENTACAO.md](docs/PLANO_IMPLEMENTACAO.md)
- **Contrato da API validado contra o backend original:** [docs/contrato.md](docs/contrato.md)
- **Versões e digests das imagens:** [docs/ambiente.md](docs/ambiente.md)
- **Métricas de desempenho:** [docs/metricas.md](docs/metricas.md)
- **Problemas comuns:** [docs/troubleshooting.md](docs/troubleshooting.md)

## O que o app faz (MVP)

Início com publicidades, filmes sugeridos e atalhos por streaming; pesquisa por título; página de cada streaming; detalhe do filme; questionário de preferências em 8 passos e sugestões calculadas no navegador a partir das respostas. Responsivo de 360 px a desktop: navegação no rodapé abaixo de 900 px e no topo a partir de 900 px.

**Fora do MVP:** conta, login, curtidas e listas. A API legada expõe usuários sem autenticação (inclusive senhas); o front não usa nenhuma dessas rotas, e o proxy as bloqueia.

## Pré-requisitos

- **Docker** com Compose v2. Todo o toolchain roda em container; o host não precisa de Node.
- Linux ou macOS com `bash`. Os comandos abaixo partem da pasta `moviematch_front/`.

O projeto exige Node 24 (`.nvmrc`). Se você tiver Node 24 no host, os comandos `npm` também funcionam direto; sem ele, use `scripts/npm.sh`, que roda o comando em `node:24` (imagem fixada por digest) com esta pasta montada.

## Testes

```bash
scripts/perfil.sh a
```

| Perfil | O que verifica | Precisa de |
|---|---|---|
| `a` | `npm ci`, allowlist, lint, typecheck, testes unitários e de componentes, testes de scripts, build | internet só para o `npm ci` |
| `smoke` | a pilha (front + mock) sobe, conversa e é removida | — |
| `b` | E2E com Playwright contra a imagem de produção e a API simulada, em celular e desktop, incluindo layout em 6 larguras | — |
| `c` | contrato e E2E contra o **backend original** com MySQL descartável; testa antes que não há saída para a internet | imagem `moviematch-back:baseline` (ver [docs/ambiente.md](docs/ambiente.md)) |
| `d` | proxy e segurança: allowlist, cabeçalhos, caminhos maliciosos, API fora do ar | — |
| `e` | resiliência (lentidão, timeout, API parada e retomada, concorrência), acessibilidade (axe e teclado) e desempenho | — |

Os perfis com containers usam uma rede interna (sem internet), não publicam portas, marcam tudo com a label `br.moviematch.front.teste` e removem o que criaram, inclusive em erro. Opções extras do Playwright: `MMF_E2E_ARGS="--grep @responsivo" scripts/perfil.sh b`.

## Rodar localmente

### Imagem de produção

```bash
docker build -f docker/Dockerfile -t moviematch-front .
```

```bash
docker run --rm -p 127.0.0.1:8080:8080 -e API_UPSTREAM=https://moviematch-apkx.onrender.com -e API_HOST=moviematch-apkx.onrender.com moviematch-front
```

Abra http://127.0.0.1:8080. O container não sobe sem `API_UPSTREAM` (com `http://` ou `https://`, sem `/` no fim) e `API_HOST`. A porta vem de `PORT` (padrão 8080; o Render injeta a sua). `/healthz` responde 200 quando o Nginx está no ar e **não** depende da API.

### Servidor de desenvolvimento com a API simulada

```bash
docker network create mmf-dev
```

```bash
docker run -d --rm --name mmf-dev-api --network mmf-dev --label br.moviematch.front.teste=dev -v "$PWD/docker/mock-api:/mock:ro" -v "$PWD/tests/fixtures:/fixtures:ro" -e FIXTURES=/fixtures -e PORT=8081 node:24.22.1-alpine3.24 node /mock/server.mjs
```

```bash
docker run -d --rm --name mmf-dev-front --network mmf-dev --label br.moviematch.front.teste=dev -p 127.0.0.1:5173:5173 --user "$(id -u):$(id -g)" -e HOME=/tmp -e MM_API_UPSTREAM=http://mmf-dev-api:8081 -v "$PWD:/w" -w /w node:24.22.1-alpine3.24 npx vite --host 0.0.0.0
```

Abra http://127.0.0.1:5173 (rode `scripts/npm.sh npm ci` antes, uma vez). Para encerrar:

```bash
docker stop mmf-dev-front mmf-dev-api && docker network rm mmf-dev
```

Para apontar o desenvolvimento para outra API, troque `MM_API_UPSTREAM`. Ela só é lida pelo Vite (Node) e não entra no bundle.

## Como o front fala com a API

- O navegador só chama `/api/...` na **mesma origem**. O backend não envia cabeçalhos CORS, então chamá-lo direto do navegador não funciona.
- O Nginx (produção) e o Vite (desenvolvimento) só repassam as rotas de [`api-allowlist.json`](api-allowlist.json): `GET`/`HEAD` de `/filmes`, `/filmes/aleatorios`, `/filmes/streaming/{s}`, `/filmes/pesquisa/{t}` e `/publicidades`. Qualquer outra rota responde 404 sem chegar ao backend.
- A configuração do Nginx (`docker/nginx/allowlist.conf`) é **gerada** a partir do JSON: depois de editar a allowlist, rode `scripts/npm.sh npm run gerar:allowlist`. O perfil A e o build da imagem falham se os dois divergirem.
- O cliente desiste em 30 s (o proxy espera 35 s) e mostra "Tentar novamente"; não há retry automático. Depois de 5 s carregando, aparece um aviso de que o servidor pode estar iniciando (cold start do Render).

## Limitações

- **A allowlist não é segurança.** Ela impede que *este front* seja usado como ponte para as outras rotas, mas a API legada continua pública e sem autenticação para quem a acessar diretamente. Os problemas do backend (senhas expostas, sem autenticação, sem CORS) não são resolvidos aqui, porque o backend está congelado.
- **API legada sem rota de detalhe:** não existe `GET /filmes/{id}`. O detalhe e as sugestões baixam o catálogo inteiro (cache de 5 min no navegador). O limite de 5 MB por resposta é uma hipótese, não medida contra a produção.
- **Produção não verificada:** os testes usam a API simulada (perfis B, D e E) ou o backend original com banco descartável (perfil C). Disponibilidade, collation, dados reais e o tempo de cold start do Render não foram medidos (ver [docs/contrato.md](docs/contrato.md)).
- **Grafias de streaming** (`AppleTV`, `GloboPlay`) seguem o app Flutter (decisão A-05) e podem não casar com os dados reais.
- **Navegadores:** os testes rodam só no Chromium (incluindo emulação de celular). Safari e Firefox não foram testados.
- **Sem compressão gzip no Nginx:** o JS chega sem compressão (cerca de 124 KB em vez de 55 KB).
- As respostas do questionário ficam só no `localStorage` do navegador.
