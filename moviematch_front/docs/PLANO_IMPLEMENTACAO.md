# MovieMatch Frontend (Vue): plano de implementação

| Campo | Valor |
|---|---|
| Versão do plano | 3 (substitui o plano em chat de 23/10/2026) |
| Data da auditoria | 2026-10-23 (consultas a registries às 13:51 UTC) |
| Base Git registrada | `main` @ `4c90b64c9445f7f005e7991cbfd9a08e4820e956` (igual a `origin/main`, árvore limpa) |
| Estado | **Aguardando aprovação.** Nenhuma tarefa de implementação foi iniciada |

Classificação usada neste documento:

- **CONFIRMADO**: evidência direta no código ou em execução já registrada.
- **SUPORTADO**: sustentado por evidências, sem validação completa.
- **HIPÓTESE**: precisa de verificação.
- **BLOQUEADO**: não pode ser confirmado com os recursos disponíveis.

---

## 1. Resumo executivo

- O objetivo é um frontend Vue **público e anônimo** (catálogo, pesquisa, streaming, detalhe, questionário e sugestões), em `moviematch_front/`, consumindo **sem alterações** a API Spring Boot existente.
- O frontend ainda não existe: `moviematch_front/` só contém este documento. Nada é reaproveitado de código Vue; do Flutter, reaproveitam-se só regras, textos e imagens, por leitura.
- Restrições que moldam o plano:
  1. o backend não tem CORS e não pode ser alterado, então o acesso é **obrigatoriamente** por proxy na mesma origem, com allowlist de 6 rotas GET;
  2. o host tem Node 20.20.2, mas Vitest 5, jsdom 30, msw e axe exigem Node ≥ 22.12, então **todo o toolchain roda em container `node:24.22.1-alpine3.24`**;
  3. o Docker do host é **snap**, que em 03/10 falhou em parar ou remover um container ("permission denied"). Isso é um **risco P0** para limpar os ambientes de teste e precisa ser verificado antes de qualquer perfil containerizado (F0-T05).
- Os testes são organizados em **cinco perfis independentes (A–E)**. Só o perfil A dispensa a pilha completa de containers; os perfis B–E rodam em redes Docker `internal`, sem portas publicadas.
- O contrato da API está **CONFIRMADO no código** (rotas e métodos), mas **não foi observado em execução**. A produção não respondeu em 22/10 e, nesta fase, não foi consultada. O perfil C (backend original + MySQL descartável) é o caminho para validar sem tocar em produção e **exige autorização**.

## 2. Estado atual confirmado

### 2.1 Repositório (CONFIRMADO, 2026-10-23)

| Item | Valor |
|---|---|
| Branch / HEAD | `main` @ `4c90b64`; `origin/main` idêntico |
| Árvore | 0 modificados, 0 não rastreados, 0 stashes (antes da criação deste arquivo) |
| `moviematch_front/` | não existia; agora contém **apenas** `docs/PLANO_IMPLEMENTACAO.md`, não rastreado |
| Documentação preexistente | só os README padrão do Flutter; nenhum plano versionado |
| Docker/Compose/CI no repo | só o `Dockerfile` da raiz (backend). Sem Compose, sem `.github/` |
| Identidade Git | `user.name` e `user.email` definidos **só na configuração global** (nome: Jonas Ribeiro da Rosa). Sem configuração local, sem `commit.gpgsign`, sem `commit.template`, sem hooks ativos |
| Remote | `github.com/Isabelly-Nathalia/BRADEMO_PROJETO` (terceiro) |

### 2.2 Ambiente do host (CONFIRMADO)

| Item | Valor | Consequência |
|---|---|---|
| Arquitetura | x86_64 | imagens `amd64` |
| Node / npm | 20.20.2 / 11.16.0 | **incompatível** com Vitest 5, jsdom 30, msw 3 e axe-playwright 4.14 |
| Docker | 29.7.2 (snap, Ubuntu Core 24, cgroup v2, overlayfs) | bind mount de `/tmp` falhou em 03/10; `docker rm -f` falhou em 03/10 |
| Compose | v5.4.0 | disponível |
| ImageMagick | 6.9.12-98, com WEBP (libwebp 1.3.2) e AVIF | otimização de imagens sem dependência npm nova |
| Recursos Docker de **outros projetos** | containers `f0`, `lab-localstack`, `adme_redis`; rede `easteregg-adme_adme_network`; 3 volumes | **não podem ser tocados** |
| Imagem do backend | `moviematch-back:baseline`, amd64, criada em 2026-10-03 a partir de um clone em `4c90b64` com o `Dockerfile` da raiz **sem alterações**; `CMD java -jar target/moviemach-0.0.1-SNAPSHOT.jar`; expõe 8080 | reutilizável no perfil C sem rebuild |

### 2.3 Frontend Flutter de referência (CONFIRMADO no código, somente leitura)

Regras e textos a portar, com origem:

| Item | Origem |
|---|---|
| Pontuação de sugestões | `projeto_brademo/lib/screens/form/sugestao.dart:42-97`; ordenação e top 3 em `:104-113` |
| Opções do questionário | `projeto_brademo/lib/screens/form/form.dart:20-66` |
| Validação ao finalizar | `form.dart:763-791` (gênero, duração e streaming obrigatórios; limpa as respostas ao voltar das sugestões) |
| Logos e streamings da Home | `projeto_brademo/lib/screens/home/home.dart:300-337` |
| Formatação de duração | `projeto_brademo/lib/service/filmeService.dart:50-55` |
| Parse de filme (não tolera nulos) | `projeto_brademo/lib/model/filme.dart:32-47` |
| Elenco | `sugestao.dart:258` usa `split(',')`; `pesquisa.dart:94` e outras telas usam a string inteira |
| Cores | `form.dart:68-71` e telas: `#222425`, `#001C30`, `#250203`, `#681F10` |
| Assets | `projeto_brademo/assets/` (16 arquivos, cerca de 3,8 MB; `filme1..6` somam cerca de 2,8 MB) |

## 3. Escopo e restrições

### 3.1 Dentro do escopo

Arquivos versionados **somente** em `moviematch_front/`. Telas, na ordem de implementação:

| # | Tela | Decisão |
|---|---|---|
| 1 | 404 | Implementar (F1, junto com o router) |
| 2 | Boas-vindas | Implementar; só na primeira visita (A-04) |
| 3 | Início | Implementar |
| 4 | Detalhe do filme | Implementar (carregado via catálogo) |
| 5 | Pesquisa | Implementar |
| 6 | Streaming | Implementar |
| 7 | Questionário | Implementar |
| 8 | Sugestões | Implementar |
| 9 | Notificações estáticas | **Não implementar no MVP** (A-06): um ícone de sino promete um sistema de notificações que não existe |

### 3.2 Fora do escopo

Login, cadastro, recuperação ou troca de senha, perfil, avatar, curtidas, listas, administração, qualquer endpoint `/usuarios*` ou `/listas*`, push e notificações. Também qualquer alteração em `moviematch_back/`, `projeto_brademo/`, arquivos da raiz, `.git/` (hooks e config), configuração global do Git, Render, Aiven ou outros serviços remotos.

### 3.3 Recursos temporários permitidos

Containers, redes e volumes **criados pelos scripts de teste**, identificados por label e nome de projeto únicos e removidos ao fim. É permitido usar imagens externas sem modificá-las, inclusive `moviematch-back:baseline`. **Nunca** `docker system prune`, nem remover recursos preexistentes.

## 4. Arquitetura proposta

### 4.1 Visão geral

```text
                    produção (Render, futuro: só com autorização)
 navegador ──HTTPS──► container front (nginx-unprivileged, uid 101, :$PORT)
                        ├── /, /assets/*  → arquivos estáticos (SPA fallback)
                        ├── /healthz      → 200 local (não depende da API)
                        ├── /api/<allowlist GET> → proxy → API_UPSTREAM
                        └── /api/* restante → 404 · método ≠ GET/HEAD → 403
```

### 4.2 Stack (versões verificadas em 2026-10-23, fixadas sem `^`)

| Pacote / imagem | Versão | Requisito verificado | Justificativa |
|---|---|---|---|
| Node (container) | `node:24.22.1-alpine3.24` (LTS "Krypton") | — | Satisfaz Vitest `^22.12\|\|^24`, jsdom `^24.15`, msw `>=22.12`, axe `>=22.12` |
| `vue` | 3.5.44 | — | Base |
| `vue-router` | 5.4.0 | Peers `pinia`, `vite`, `@pinia/colada`, `@vue/compiler-sfc` são **opcionais** | Rotas. **Major recente: ler o guia de migração na F1-T07 (HIPÓTESE: API de rotas estáticas compatível com a v4)** |
| `vite` | 8.3.5 | Node `^20.19\|\|>=22.12` | Build e dev server (o proxy vem embutido, sem dependência listada) |
| `@vitejs/plugin-vue` | 6.0.10 | Peers vue ^3.2.25, vite ^8 | SFC |
| `typescript` | **6.0.3** (publicado em 2026-04-16) | `typescript-eslint` 8.72 exige `<6.1.0`, então **o 7.0.2 está descartado** | Tipos |
| `vue-tsc` | 3.3.13 | Peer `typescript>=5` | Checagem de SFC |
| `vitest` | 5.0.5 | Node `^22.12\|\|^24`; vite ^8 | Testes unitários e de componentes |
| `jsdom` | 30.1.3 | Node `^22.22.2\|\|^24.15` | DOM do Vitest |
| `@vue/test-utils` | 2.5.1 | — | Montagem de componentes |
| `@playwright/test` | 1.64.1 | Node `>=20` | E2E |
| Imagem Playwright | `mcr.microsoft.com/playwright:v1.64.1-noble` | Dockerfile oficial da tag usa `NODE_VERSION=24` (SUPORTADO) | Navegadores fixados na mesma versão do pacote |
| `@axe-core/playwright` | 4.14.0 | Node `>=22.12` | Acessibilidade |
| `eslint` | 10.13.0 | — | Lint |
| `eslint-plugin-vue` | 10.11.1 | — | Regras Vue (`vue/no-v-html`) |
| `typescript-eslint` | 8.72.0 | Peer TS `<6.1.0` | Lint de TS |
| `@vue/eslint-config-typescript` | 14.9.0 | Depende de `typescript-eslint ^8.60` | Integra o parser de `.vue` com TS sem configuração manual |
| `@types/node` | 24.19.2 | Peer do Vitest `^22\|\|>=24` | Tipos de scripts e configs (alinhado ao Node 24) |
| Runtime | `nginxinc/nginx-unprivileged:1.31.7-alpine3.24` (amd64 disponível) | — | Estáticos e proxy, sem root |
| Perfil C | `mysql:8.4.13` (amd64 disponível) | — | Banco descartável |

**Descartados, com motivo:**

| Pacote | Motivo do descarte |
|---|---|
| Pinia | Só dois estados compartilhados pequenos (questionário e cache do catálogo); composables com estado de módulo resolvem, sem dependência |
| msw | O Vitest usa `vi.stubGlobal('fetch', …)` com as fixtures. Os perfis de container usam um mock HTTP próprio, sem dependências |
| axios | `fetch` + `AbortController` bastam |
| Biblioteca de UI | Cerca de 8 componentes simples, tema próprio |
| Prettier | Evita dependência e conflito com ESLint; `.editorconfig` cobre o básico |
| `@vitest/coverage-v8` | Cobertura não é critério de aceite; os critérios são casos explícitos |
| Biblioteca de datas | O MVP não tem datas |
| TypeScript 7 | Incompatível com `typescript-eslint` |

**Hipóteses a validar na F1:**
- CSP `style-src 'self'` compatível com o build do Vite;
- proxy do Vite aceitar chaves regex e `bypass` (SUPORTADO pela documentação, verificado por teste real na F2-T02);
- suporte a `/etc/nginx/templates` e ao `NGINX_ENTRYPOINT_LOCAL_RESOLVERS` na imagem unprivileged (SUPORTADO: mesma base de entrypoint da imagem oficial, verificado na F5-T03).

### 4.3 Estrutura de diretórios

```text
moviematch_front/
├── .fronteira-base            # SHA base registrado (4c90b64…), lido pelo script de fronteira
├── .gitignore  .editorconfig  .nvmrc  .dockerignore
├── api-allowlist.json         # FONTE ÚNICA das rotas de API permitidas
├── package.json  package-lock.json  tsconfig.json  tsconfig.node.json
├── vite.config.ts  vitest.config.ts  playwright.config.ts  eslint.config.js  index.html
├── docs/                      # este plano, contrato.md, ambiente.md, PUBLICACAO.md
├── scripts/
│   ├── verificar-fronteira.sh # somente leitura no Git
│   ├── npm.sh                 # npm/node dentro de node:24 (host tem Node 20)
│   ├── perfil.sh              # sobe/derruba perfis B–E com projeto único e limpeza
│   ├── allowlist.mjs          # carrega, valida e casa (método, caminho) com a allowlist
│   ├── gerar-nginx-allowlist.mjs  # gera nginx/allowlist.conf de forma determinística
│   └── otimizar-assets.sh     # ImageMagick; documenta como os assets foram gerados
├── docker/
│   ├── Dockerfile             # build (node) + runtime (nginx-unprivileged)
│   ├── nginx/default.conf.template
│   ├── compose.yml            # serviços e profiles: b, c, d, e
│   └── mock-api/server.mjs    # mock HTTP sem dependências, com cenários
├── public/                    # favicon e ícones (cópias dos de projeto_brademo/web)
├── src/
│   ├── main.ts  App.vue
│   ├── router/index.ts
│   ├── pages/                 # BoasVindas, Inicio, Pesquisa, Streaming, FilmeDetalhe, Questionario, Sugestoes, NaoEncontrado
│   ├── components/            # AppShell, BottomNav, BaseButton, SafeImage, MovieCard, ChipGroup, StateView
│   ├── composables/           # useCatalogo, useQuestionario, useAvisoLentidao, usePrimeiraVisita
│   ├── services/              # http.ts, filmes.ts, publicidades.ts, mapeadores.ts
│   ├── domain/                # recomendacao.ts, questionario.ts, streamings.ts, duracao.ts (regras puras)
│   ├── types/                 # contrato.ts (bruto) e modelos.ts (internos)
│   ├── assets/  styles/
└── tests/
    ├── fixtures/              # JSON determinísticos, compartilhados por Vitest e mock-api
    ├── unit/  components/     # Vitest (perfil A)
    ├── scripts/               # testes do script de fronteira e dos geradores
    ├── proxy/                 # node:test contra o container (perfil D)
    └── e2e/                   # Playwright (perfis B, C, E)
```

Diferenças em relação à sugestão do pedido:
- **sem `src/stores/`** (Pinia descartado);
- **sem `src/utils/`** (as regras ficam em `domain/`, que deixa explícito o que é regra de negócio portada do Flutter);
- **`src/domain/` adicionado** pelo mesmo motivo.

### 4.4 Cliente HTTP (`src/services/http.ts`)

- `getJson(caminho, { timeoutMs = 30000, signal })`, somente GET, base `import.meta.env.VITE_API_BASE ?? '/api'`.
- Erros tipados:
  - `{ tipo: 'rede' }`
  - `{ tipo: 'timeout' }`
  - `{ tipo: 'http', status }`
  - `{ tipo: 'formato', detalhe }` (JSON malformado, raiz inesperada, corpo acima do limite)
  - `{ tipo: 'cancelado' }`
- **Limite de corpo: 5 MB** (HIPÓTESE, a recalibrar na F6 com o tamanho real de `GET /filmes`). Primeiro pelo `Content-Length`; depois pela leitura em streaming com contagem de bytes.
- Path params com `encodeURIComponent`. Um termo de pesquisa com `/` é recusado no cliente (a rota da API é por path).
- Cancelamento: `AbortController` vinculado ao ciclo de vida da página.
- O aviso de lentidão aos **5 s** é só visual (`useAvisoLentidao`) e não é um timeout. O retry é **sempre manual**.
- **Cache:** só o catálogo completo (`GET /filmes`), em memória, TTL de 5 min, deduplicação de requisições simultâneas, **erro nunca vai para o cache**, invalidação no "Tentar novamente". Justificativa: o detalhe e as sugestões dependem do catálogo inteiro, porque não existe `GET /filmes/{id}`.

**Timeouts coerentes, testados na F5-T05:**

| Camada | Valor |
|---|---|
| Cliente | 30 s |
| Nginx `proxy_read_timeout` | 35 s |
| Nginx `proxy_connect_timeout` | 10 s |
| Nginx `proxy_send_timeout` | 10 s |

Com o mock atrasando 32 s, o cliente expira primeiro. Com uma chamada direta ao proxy e atraso de 40 s, o Nginx responde 504 por volta de 35 s.

### 4.5 Proxy e allowlist

- **Fonte única:** `api-allowlist.json`.

  ```json
  { "versao": 1, "metodos": ["GET", "HEAD"],
    "rotas": [ "/filmes", "/filmes/aleatorios", "/filmes/streaming/{segmento}",
               "/filmes/pesquisa/{segmento}", "/publicidades" ] }
  ```

  `{segmento}` = um único segmento não vazio, sem `/` depois da decodificação. `/filmes/streaming/outros` é coberto por `{segmento}`; o backend resolve a rota literal (`FilmeController.java:36`, CONFIRMADO).
- **Consumidores:**
  - `scripts/allowlist.mjs` valida o JSON (esquema fixo, sem rotas de `/usuarios` nem `/listas`, que são rejeitadas por regra) e exporta `permitido(metodo, caminhoDecodificado)`;
  - `vite.config.ts` importa esse módulo para o proxy de desenvolvimento;
  - `scripts/gerar-nginx-allowlist.mjs` gera `docker/nginx/allowlist.conf` de forma **determinística** (ordem fixa, sem timestamp). O `npm run check:allowlist` regenera em memória e falha se houver diferença em relação ao arquivo versionado.
- **Nginx:**
  - a `location` regex casa a URI **decodificada e normalizada**; o `proxy_pass` repassa o caminho **original** (`$request_uri` sem o prefixo `/api` e sem query string), para que `%2B`, espaços e acentos cheguem intactos;
  - `%2F` vira `/` após a decodificação, não casa `{segmento}` e devolve 404 (comportamento desejado);
  - `Cookie` e `Origin` são removidos; `Set-Cookie` é ocultado; `client_max_body_size 1k`.
- **A allowlist é uma fronteira de conectividade do frontend, não segurança da API.** A API continua pública para quem a acessar diretamente.

### 4.6 Persistência no navegador

| Chave | Conteúdo | Regra |
|---|---|---|
| `mm.questionario.v1` | respostas do questionário | versão no conteúdo; JSON inválido é descartado |
| `mm.visitou.v1` | marca de primeira visita (A-04) | se o storage estiver indisponível, a boas-vindas aparece uma vez por sessão (memória), sem loop |

Todo acesso fica em `src/composables/` com `try/catch`, e uma regra do ESLint proíbe `localStorage` fora dali. Nenhum dado pessoal é armazenado.

## 5. Contrato da API e evidências

Fonte: `moviematch_back/src/main/java/com/brademobackend/moviematch/` (somente leitura). **Nenhuma requisição foi feita nesta fase.**

| Rota | Método | Evidência | Rota/método | Formato da resposta | Comportamento em erro | Execução real |
|---|---|---|---|---|---|---|
| `/filmes` | GET | `controller/FilmeController.java:20` | CONFIRMADO | `Filme[]`: SUPORTADO (entidade `model/Filme.java` + `@Data`, sem DTO nem config do Jackson) | sem tratamento específico | BLOQUEADO |
| `/filmes/aleatorios` | GET | `FilmeController.java:25`; `service/FilmeService.java` (embaralha e limita a 5) | CONFIRMADO | `Filme[]` ≤ 5: SUPORTADO | — | BLOQUEADO |
| `/filmes/streaming/{streaming}` | GET | `FilmeController.java:30`; `repository/FilmeRepository.java` (igualdade exata) | CONFIRMADO | `Filme[]`: SUPORTADO | — | BLOQUEADO |
| `/filmes/streaming/outros` | GET | `FilmeController.java:36`; JPQL `NOT IN ('Netflix','HBO Max','Disney+','Apple TV','Globoplay','Prime Video','Tela Brasil')` | CONFIRMADO | `Filme[]`: SUPORTADO | — | BLOQUEADO |
| `/filmes/pesquisa/{titulo}` | GET | `FilmeController.java:41`; `LOWER(...) LIKE LOWER(CONCAT('%', :titulo, '%'))` | CONFIRMADO | `Filme[]`: SUPORTADO | `%2F` no path: 400 ou 404 (HIPÓTESE; bloqueado no proxy de qualquer forma) | BLOQUEADO |
| `/publicidades` | GET | `controller/PublicidadeController.java:18` | CONFIRMADO | `Publicidade[]`: SUPORTADO | — | BLOQUEADO |
| `/filmes/{id}` | — | Não existe mapeamento em `FilmeController.java` | **CONFIRMADO: não existe** | — | — | — |

**Formas (SUPORTADO):**
- `Filme`: `id_filme:number`, `titulo_filme`, `descricao_filme`, `imagemDiretor_filme`, `duracao_filme:number`, `streaming_filme`, `nacionalidade_filme`, `classificacao_filme`, `diretor_filme`, `linkImagemFilme_filme`, `atorEspecifico_filme`, `nota_filme:number`, `generos:string[]` (`@ElementCollection`).
- `Publicidade`: `id_publicidade`, `descricao`, `link_imagem`.

Qualquer `String` pode ser `null`: não há `@NotNull` nem `nullable=false` (CONFIRMADO no código). Se nulos existem nos dados, é BLOQUEADO.

**Origem dos valores:**
- Os valores de streaming, gênero, classificação e país do **frontend** são literais do Flutter (CONFIRMADO).
- Os valores do **banco** são desconhecidos (BLOQUEADO, sem acesso a dados).
- Divergências CONFIRMADAS no código: o questionário usa `AppleTV`/`GloboPlay`; a Home usa `Apple TV`/`GloboPlay`; o JPQL de "outros" usa `Apple TV`/`Globoplay`.

**Inicialização do backend (SUPORTADO, `application.properties`):**
- precisa de `DB_PASSWORD` ou de override de `spring.datasource.*` por variável de ambiente;
- `server.port=${PORT:8080}`;
- `ddl-auto=update` **cria e altera tabelas** no banco conectado;
- a URL padrão aponta para o **Aiven** (produção). Por isso o perfil C exige overrides **e** isolamento de rede verificado.

**Disponibilidade da produção:** em 22/10 (13:05–13:16 UTC) o TLS com a borda do Render completou, mas nenhum byte de resposta chegou em até 180 s. Um app de controle no mesmo domínio respondeu em 0,8 s. A causa está no caminho da borda até este serviço e não foi identificada. **Estado atual: não verificado** (consultas proibidas nesta fase).

## 6. Decisões técnicas

### 6.1 Decisões funcionais

| ID | Decisão | Estado após auditoria |
|---|---|---|
| A-01 | Descartar só o filme inválido e contar. **Erro sistêmico não é escondido**: se a raiz não for array, ou se **todos** os itens de uma lista não vazia forem inválidos, gera erro `formato` (tela de erro, não "vazio"). A contagem de descartes é exposta ao `StateView` em dev e logada com `console.warn` | Mantida, com regra de erro sistêmico explícita |
| A-02 | Elenco = `split(',')` + `trim` + remoção de vazios | Mantida. **Compatibilidade com os dados: HIPÓTESE** (`atorEspecifico_filme` é string única; vírgulas nos dados não verificadas). Reavaliar na F6 |
| A-03 | Remover do questionário o que **comprovadamente** não pontua | **Reinterpretada com base na evidência.** CONFIRMADO que não pontuam: os campos livres "Outro streaming" e "Outro país" (`TextField` sem `controller`/`onChanged` em `form.dart`), que serão removidos. **Não removidas**: as opções `AppleTV` e `GloboPlay`. Que elas nunca casem com os dados é BLOQUEADO até haver dados (perfil C ou produção); até lá vale a paridade (A-05) |
| A-04 | Sem espera de 3 s; boas-vindas só na primeira visita | Mantida (persistência na seção 4.6) |
| A-05 | Valores de streaming idênticos aos do Flutter (Home para o filtro, questionário para a pontuação) | Mantida; a tabela `domain/streamings.ts` guarda os dois valores separadamente |
| A-07 | Duração nula aceita como "não informada" (não pontua por duração) | **Nova, decidida em 2026-10-23** após o perfil C mostrar que o schema real permite `duracao_filme` nula (`docs/contrato.md`, seção 5) |
| A-06 | Notificações fora do MVP | **Nova.** A tela do Flutter é um texto fixo atrás de um ícone de sino, o que promete uma função inexistente |

### 6.2 Recomendação (paridade com `sugestao.dart`)

| Critério | Pontos | Condição exata |
|---|---|---|
| Gênero | +3 | Algum gênero do filme está entre os selecionados (igualdade exata, diferencia maiúsculas) |
| Duração | +2 | `Até 1h30` → `≤90`; `1h30 - 2h` → `>90 e ≤120`; `2h - 3h` → `>120 e ≤180`; `3h+` → `>180` |
| Streaming | +3 | `filme.streaming` está entre os streamings selecionados (exata) |
| Classificação | +2 | Igualdade exata |
| País | +1 | `filme.nacionalidade` está entre os países selecionados (exata) |
| Ator ou diretor | +1 | Se `ator` não for vazio (**sem trim**, como no Dart): `diretor` ou `atores` contém `ator`, sem diferenciar maiúsculas; acentos não são normalizados |

Ordenação decrescente, top 3, incluindo filmes com 0 ponto. **Desempate: preserva a ordem da API** (sort estável). O Dart não garante estabilidade, então isso é uma *definição*, não uma equivalência provada.

### 6.3 Alternativas descartadas

| Alternativa | Motivo |
|---|---|
| Chamada direta à API + CORS | Exige mudar o backend |
| Proxy amplo `/api/*` | Exporia `/usuarios`, `/listas` e escritas pela origem do frontend |
| Variável `VITE_API_URL` absoluta | Bloqueada por CORS; o proxy torna desnecessário |
| Flag para fluxos de conta | Código morto e risco de ativação acidental |
| `config.json` em runtime | Desnecessário: o bundle usa `/api` relativo e o upstream é variável do container |
| Kubernetes | Sem requisito de orquestração; Compose cobre os perfis. **Pode ser uma evolução futura**, não um requisito |
| Node local | O host tem 20.20.2, incompatível |
| CI no GitHub | Exige `.github/` na raiz e acesso ao remote de terceiro (fora do escopo); o perfil A cumpre o papel localmente |

## 7. Matriz dos perfis de teste

| Perfil | Objetivo | Precisa de Docker? | Serviços | Rede | Portas publicadas | Autorização extra | Duração-alvo (medir na F1/F5) |
|---|---|---|---|---|---|---|---|
| **A**: rápido | `npm ci`, lint, typecheck, unit, componentes, build, check da allowlist, testes de scripts | Só o container `node` efêmero (host sem Node 24) | nenhum | bridge padrão **só para o `npm ci`** (registry npm) | nenhuma | não (após aprovação da F0-T05) | ≤ 3 min (HIPÓTESE) |
| **B**: API simulada | E2E funcional com cenários determinísticos | sim | front, mock-api, playwright | `internal` | nenhuma | não | ≤ 6 min |
| **C**: backend original | Contrato e E2E contra o backend real com banco descartável | sim | mysql, backend (`moviematch-back:baseline`), front, sonda, playwright | `internal`, egresso **testado** | nenhuma | **sim** (F6-T01) | medir |
| **D**: proxy e segurança | Allowlist, codificação, headers, cache, healthcheck, uid, timeouts, falhas de upstream | sim | front, mock-api, sonda (`node:test`) | `internal` | nenhuma | não | ≤ 3 min (inclui o caso de 35 s) |
| **E**: navegador e resiliência | A11y, responsividade, lentidão, indisponibilidade, retry, concorrência, reinício, métricas | sim | front, mock-api, playwright | `internal` | nenhuma | não | ≤ 8 min |

O mock (`docker/mock-api/server.mjs`, Node puro):
- serve as fixtures de `tests/fixtures/`;
- expõe `POST /__cenario` (`normal`, `vazio`, `invalidos`, `todos-invalidos`, `json-malformado`, `http-500`, `http-404`, `lento:<ms>`, `pendurado`, `repetidos`, `streamings-divergentes`) e `GET /__requisicoes` (registro das requisições **recebidas**, com caminho bruto, método e headers);
- só é alcançável na rede interna;
- **não prova compatibilidade com a API real.**

## 8. Arquitetura dos containers de teste

```text
 projeto compose: mmf-<perfil>-<UTC>-<aleatório>   label: br.moviematch.front.teste=<run-id>
 ┌──────────────────────── rede "interna" (internal: true) ────────────────────────┐
 │  front (nginx-unprivileged) ──/api/*──► mock-api (B, D, E) │ backend (C) ──► mysql (C) │
 │        ▲                                                                         │
 │  playwright (B, C, E) · sonda node:test (C, D)                                   │
 └──────────────────────────────────────────────────────────────────────────────────┘
 nenhuma porta publicada; os resultados saem por bind mount de moviematch_front/test-results/ (gitignored)
```

- **Readiness real:** `healthcheck` em todos os serviços (`/healthz` do front, `GET /__saude` do mock, `mysqladmin ping`, sonda de `GET /filmes` no backend) e `depends_on: condition: service_healthy`. A ordem de inicialização, sozinha, não é considerada pronta.
- **Resolver do Nginx:** `resolver ${NGINX_LOCAL_RESOLVERS}` via `NGINX_ENTRYPOINT_LOCAL_RESOLVERS=1` (SUPORTADO). Funciona com o DNS embutido do Docker (`127.0.0.11`) e no Render. Verificado na F5-T03.

## 9. Fases e tarefas

**Convenções que valem para todas as tarefas:**
- **Rollback padrão:** `git revert <hash>` do commit da tarefa. Tarefas de registro não têm rollback Git; o rollback de ambiente é o próprio procedimento de limpeza (seção 14).
- **Comando de fronteira** (a partir da F0-T04): `moviematch_front/scripts/verificar-fronteira.sh`, obrigatório antes de todo commit.
- **Perfil A** (a partir da F1-T05): `moviematch_front/scripts/perfil.sh a`, obrigatório antes de todo commit que toque código.

### F0: Preparação e baseline

#### F0-T01: Registrar o baseline
- **Objetivo:** fixar o estado inicial para auditoria.
- **Evidência:** seção 2.1.
- **Pré-condições:** aprovação deste plano.
- **Dependências:** nenhuma.
- **Arquivos permitidos:** nenhum.
- **Alterações:** nenhuma.
- **Validação:** `git rev-parse HEAD`; `git status --porcelain --untracked-files=all` (só `moviematch_front/docs/PLANO_IMPLEMENTACAO.md`); `git config --global user.name`; e-mail global definido.
- **Aceite:** HEAD = `4c90b64…`; nenhuma outra alteração.
- **Resultado:** registro no relatório da tarefa.
- **Git:** nenhuma alteração versionável.
- **Riscos:** o remote mudou; nesse caso, parar e reportar.

#### F0-T02: Criar a branch de trabalho (**autorização explícita**)
- **Objetivo:** isolar o trabalho em `front-vue`.
- **Dependências:** F0-T01.
- **Arquivos permitidos:** nenhum.
- **Alterações:** `git switch -c front-vue` (o arquivo não rastreado acompanha).
- **Validação:** `git branch --show-current` = `front-vue`; `git rev-parse HEAD` = base.
- **Aceite:** branch criada a partir da base.
- **Resultado:** registro.
- **Git:** sem commit.
- **Rollback:** `git switch main && git branch -d front-vue`.
- **Riscos:** nenhum.

#### F0-T03: Versionar o plano, o `.gitignore` e a base de fronteira
- **Objetivo:** primeiro commit, só de documentação e configuração de diretório.
- **Dependências:** F0-T02.
- **Arquivos permitidos:** `moviematch_front/docs/PLANO_IMPLEMENTACAO.md`, `moviematch_front/.gitignore`, `moviematch_front/.fronteira-base`.
- **Alterações:**
  - `.gitignore`: `node_modules/`, `dist/`, `test-results/`, `playwright-report/`, `.env*` exceto `.env.example`;
  - `.fronteira-base`: uma linha com o SHA `4c90b64c9445f7f005e7991cbfd9a08e4820e956`.
- **Validação:** `git diff --cached --name-only` só com os 3 caminhos; `git diff --cached --check`.
- **Aceite:** commit contendo exatamente os 3 arquivos.
- **Git:** commit `docs(front): plano de implementação e base de fronteira`.
- **Riscos:** nenhum.

#### F0-T04: Script de verificação de fronteira
- **Objetivo:** detectar mecanicamente qualquer caminho fora de `moviematch_front/`.
- **Dependências:** F0-T03.
- **Arquivos permitidos:** `moviematch_front/scripts/verificar-fronteira.sh`, `moviematch_front/tests/scripts/verificar-fronteira.test.sh`.
- **Alterações:**
  - Script POSIX/bash, `set -euo pipefail`, **somente comandos de leitura**.
  - Valida que `.fronteira-base` contém um SHA existente (`git cat-file -e`) e ancestral de `HEAD` (`git merge-base --is-ancestor`).
  - Lista: (1) `git diff --name-only <base>...HEAD`; (2) `git diff --cached --name-only`; (3) `git diff --name-only`; (4) `git ls-files --others --exclude-standard`.
  - Falha (exit 1) se qualquer caminho não começar com `moviematch_front/`, imprimindo a origem de cada violação.
  - Exit 2 para base inválida.
- **Testes:** o script de teste cria um repositório **temporário** em `mktemp -d` (fora do projeto), com commits sintéticos, e cobre: limpo → 0; violação em commit, em staged, em unstaged, em não rastreado → 1 com origem correta; base inexistente ou não ancestral → 2. Ao final, confere com `git status` que o repositório real não mudou.
- **Aceite:** 7 casos verdes; o script roda no repositório real com exit 0.
- **Git:** commit `feat(front): verificação automática de fronteira`.
- **Riscos:** nomes com espaço ou quebra de linha (usar `-z`).

#### F0-T05: Verificar o ambiente Docker (**autorização explícita**: pull de imagens e containers efêmeros)
- **Objetivo:** provar que o Docker snap consegue criar, parar e remover containers, redes e volumes **próprios**; fixar digests.
- **Evidência:** em 03/10, `docker rm -f f0` e `docker stop f0` falharam com "permission denied" (AppArmor/snap); bind mount de `/tmp` não funcionou.
- **Dependências:** F0-T04.
- **Arquivos permitidos:** `moviematch_front/docs/ambiente.md`.
- **Alterações:** documentar os resultados e os digests.
- **Validação:**
  1. `docker pull` das 5 imagens da seção 4.2 (exceto mysql, que é da F6) e registro de `RepoDigests`;
  2. container `nginx-unprivileged` com label de teste → `docker stop` → `docker rm` → confirmar ausência;
  3. rede `--internal` e volume com label → criar e remover;
  4. `docker run --rm --user $(id -u):$(id -g) -v "$PWD/moviematch_front":/w node:24… ls /w` (bind mount em `$HOME`);
  5. `docker ps -a`, `docker network ls` e `docker volume ls` idênticos ao estado inicial, inclusive os recursos de outros projetos.
- **Aceite:** os 5 itens ok.
- **Git:** commit `docs(front): ambiente e digests verificados`.
- **Riscos / bloqueio:** se o passo 2 falhar, **parar**. A correção (por exemplo `sudo snap restart docker`) é uma ação no sistema do usuário, fora do escopo; os perfis B–E ficam bloqueados até lá.

### F1: Fundação

#### F1-T01: Wrapper do toolchain (`scripts/npm.sh`)
- **Objetivo:** executar `npm` e `node` 24 sem instalar nada no host.
- **Dependências:** F0-T05.
- **Arquivos permitidos:** `moviematch_front/scripts/npm.sh`, `moviematch_front/.nvmrc`.
- **Alterações:**
  - `docker run --rm --init --name mmf-npm-<aleatório> --label br.moviematch.front.teste=npm --user $(id -u):$(id -g) -e HOME=/tmp -e npm_config_cache=/w/.npm-cache -v <moviematch_front>:/w -w /w node:24.22.1-alpine3.24 "$@"`;
  - monta **apenas** `moviematch_front/`;
  - `.npm-cache/` vai para o `.gitignore`, o que já foi previsto (atualizar na mesma tarefa);
  - `.nvmrc` = `24.22.1`.
- **Validação:** `scripts/npm.sh node -v` = `v24.22.1`; nenhum container `mmf-npm-*` sobra; arquivos criados pertencem ao usuário do host.
- **Aceite:** os 3 critérios.
- **Git:** commit `build(front): wrapper de toolchain Node 24 em container`.
- **Riscos:** permissão de bind mount no snap (coberta pela F0-T05).

#### F1-T02: Scaffold Vite + Vue + TS
- **Dependências:** F1-T01.
- **Arquivos permitidos:** `package.json`, `package-lock.json`, `tsconfig.json`, `tsconfig.node.json`, `vite.config.ts`, `index.html`, `src/main.ts`, `src/App.vue`, `src/env.d.ts`, `.editorconfig`, `.gitignore` (todos em `moviematch_front/`).
- **Alterações:**
  - `vue@3.5.44`, `vite@8.3.5`, `@vitejs/plugin-vue@6.0.10`, `typescript@6.0.3`, `vue-tsc@3.3.13`, `@types/node@24.19.2`, todos com versão exata;
  - `"engines": {"node": "24.22.1"}`;
  - scripts `build` (`vue-tsc -b && vite build`) e `typecheck`;
  - lockfile gerado via wrapper.
- **Validação:** `scripts/npm.sh npm ci && scripts/npm.sh npm run typecheck && scripts/npm.sh npm run build`.
- **Aceite:** os três com exit 0; `dist/index.html` existe; `npm ls --depth=0` sem `invalid` ou `missing`.
- **Git:** commit `build(front): scaffold Vue 3 + Vite + TypeScript`.
- **Riscos:** conflito de peers não previsto; nesse caso, parar e registrar.

#### F1-T03: ESLint
- **Dependências:** F1-T02.
- **Arquivos permitidos:** `eslint.config.js`, `package.json`, `package-lock.json`, `tests/lint/proibido.vue`, `tests/lint/lint.test.mjs`.
- **Alterações:**
  - `eslint@10.13.0`, `eslint-plugin-vue@10.11.1`, `typescript-eslint@8.72.0`, `@vue/eslint-config-typescript@14.9.0`;
  - regras `vue/no-v-html: error` e `no-restricted-globals: localStorage, sessionStorage` (exceto em `src/composables/**`);
  - `tests/lint` ignorado no lint normal.
- **Validação:** `npm run lint` verde; `lint.test.mjs` (via `node --test`, usando a API do ESLint) confirma 2 erros esperados em `proibido.vue`.
- **Aceite:** ambos.
- **Git:** commit `build(front): ESLint com regras de segurança`.

#### F1-T04: Vitest
- **Dependências:** F1-T03.
- **Arquivos permitidos:** `vitest.config.ts`, `package.json`, `package-lock.json`, `tests/unit/app.test.ts`.
- **Alterações:** `vitest@5.0.5`, `jsdom@30.1.3`, `@vue/test-utils@2.5.1`; um teste que monta o `App`.
- **Validação:** `npm test`.
- **Aceite:** 1 teste verde.
- **Git:** commit `test(front): Vitest + jsdom + Vue Test Utils`.

#### F1-T05: Perfil A (`scripts/perfil.sh a`)
- **Dependências:** F1-T04.
- **Arquivos permitidos:** `scripts/perfil.sh`, `package.json`.
- **Alterações:** o subcomando `a` executa, via wrapper, `npm ci && npm run lint && npm run typecheck && npm test && npm run build && node --test tests/scripts tests/lint` e registra a duração.
- **Validação:** `scripts/perfil.sh a`.
- **Aceite:** exit 0; duração registrada no relatório (meta inicial ≤ 3 min, a ajustar com a medição); nenhum container remanescente.
- **Git:** commit `test(front): perfil A`.

#### F1-T06: Tokens e estilos base
- **Dependências:** F1-T05.
- **Arquivos permitidos:** `src/styles/tokens.css`, `src/styles/base.css`, `src/main.ts`, `tests/unit/tokens.test.ts`.
- **Alterações:** cores do Flutter (seção 2.3); texto branco/70%/54%; foco visível; `prefers-reduced-motion`.
- **Validação:** teste calcula o contraste de cada par texto/fundo dos tokens (função WCAG pura).
- **Aceite:** todos os pares de texto ≥ 4.5:1.
- **Git:** commit `feat(front): tokens visuais`.

#### F1-T07: Router + 404
- **Dependências:** F1-T06.
- **Arquivos permitidos:** `src/router/index.ts`, `src/pages/*.vue` (placeholders), `src/pages/NaoEncontrado.vue`, `src/App.vue`, `package.json`, `package-lock.json`, `tests/unit/router.test.ts`.
- **Alterações:**
  - `vue-router@5.4.0` (ler o guia de migração da v5 e registrar as diferenças relevantes);
  - rotas: `/`, `/boas-vindas`, `/inicio`, `/pesquisa`, `/streaming/:slug`, `/filmes/:id(\\d+)`, `/questionario/:passo(\\d)?`, `/sugestoes`, catch-all;
  - título por rota;
  - placeholders **não linkados** por nenhuma navegação até a tarefa da página.
- **Validação:** testes de resolução de cada rota; `/x/y` e `/filmes/abc` → `NaoEncontrado`.
- **Aceite:** 100% das rotas da tabela resolvem como especificado.
- **Git:** commit `feat(front): roteamento e página 404`.
- **Riscos:** API da v5 diferente (HIPÓTESE).

#### F1-T08: `AppShell` + `BottomNav`
- **Dependências:** F1-T07.
- **Arquivos permitidos:** `src/components/AppShell.vue`, `src/components/BottomNav.vue`, `src/App.vue`, `tests/components/BottomNav.test.ts`.
- **Alterações:**
  - navegação com **só** Início e Questionário;
  - oculta em `/boas-vindas` e `/questionario/*`;
  - `aria-current` no item ativo.
- **Validação:** testes de visibilidade por rota e de `aria-current`.
- **Aceite:** os casos verdes; nenhum link para rota inexistente.
- **Git:** commit `feat(front): layout e navegação inferior`.

#### F1-T09: `BaseButton` + `SafeImage`
- **Dependências:** F1-T08.
- **Arquivos permitidos:** `src/components/BaseButton.vue`, `src/components/SafeImage.vue`, `tests/components/SafeImage.test.ts`, `tests/components/BaseButton.test.ts`.
- **Alterações:** `SafeImage` só aceita `https:` (o resto vira placeholder), `loading="lazy"`, `referrerpolicy="no-referrer"`, fallback no `error`, `alt` obrigatório por prop.
- **Validação:** casos `http:`, `javascript:`, `data:`, vazio, `https:` válido e evento de erro.
- **Aceite:** 6 casos verdes.
- **Git:** commit `feat(front): componentes base`.

### F2: API e normalização

#### F2-T01: Allowlist única
- **Dependências:** F1-T09.
- **Arquivos permitidos:** `api-allowlist.json`, `scripts/allowlist.mjs`, `tests/scripts/allowlist.test.mjs`.
- **Alterações:** JSON da seção 4.5; o módulo valida o esquema, **rejeita** rotas que comecem com `/usuarios` ou `/listas`, ou que contenham `{` sem ser `{segmento}`, e exporta `permitido(metodo, caminhoDecodificado)`.
- **Validação:** `node --test`. Casos:
  - as 5 rotas permitidas;
  - `/filmes/1/extra` → não;
  - `/filmes/streaming/` → não;
  - `/usuarios` → não;
  - POST/PUT/DELETE → não;
  - HEAD → sim;
  - JSON com `/usuarios` → erro de validação.
- **Aceite:** todos verdes.
- **Git:** commit `feat(front): allowlist única da API`.

#### F2-T02: Proxy de desenvolvimento no Vite
- **Dependências:** F2-T01.
- **Arquivos permitidos:** `vite.config.ts`, `.env.example`, `tests/unit/proxy-dev.test.ts`.
- **Alterações:** `server.proxy['^/api/.*']` com `bypass` usando `permitido` (fora da lista: 404) e `rewrite` removendo `/api`. O upstream vem de `VITE_DEV_API_UPSTREAM` (sem valor padrão de produção).
- **Validação:** o teste sobe **de verdade** o `createServer` do Vite com um upstream `node:http` local, no mesmo processo e sem rede externa, e confere as requisições **recebidas** pelo upstream: caminho permitido chega; `/api/usuarios` e POST não chegam (404 ou 405 no Vite).
- **Aceite:** os casos verdes.
- **Git:** commit `feat(front): proxy de desenvolvimento restrito`.
- **Riscos:** a semântica de `bypass` no Vite 8 (HIPÓTESE). Se não suportar, usar um middleware `configureServer` e registrar.

#### F2-T03: Cliente HTTP
- **Dependências:** F2-T02.
- **Arquivos permitidos:** `src/services/http.ts`, `tests/unit/http.test.ts`.
- **Alterações:** seção 4.4.
- **Validação:** `fetch` simulado com:
  - 200 válido;
  - 404 e 500;
  - JSON malformado;
  - corpo vazio;
  - `Content-Length` acima de 5 MB;
  - stream acima do limite sem `Content-Length`;
  - timeout (`vi.useFakeTimers`, 30 s);
  - abort externo;
  - erro de rede;
  - `encodeURIComponent` aplicado (`Disney+` → `Disney%2B`);
  - termo com `/` recusado.
- **Aceite:** 12 casos verdes.
- **Git:** commit `feat(front): cliente HTTP com timeout e erros tipados`.

#### F2-T04: Fixtures determinísticas
- **Dependências:** F2-T03.
- **Arquivos permitidos:** `tests/fixtures/*.json`, `tests/fixtures/README.md`.
- **Alterações:** `filmes-validos.json` (≥ 12 filmes cobrindo todas as durações, streamings, classificações e países, incluindo `Apple TV`/`AppleTV`/`Globoplay`/`GloboPlay`/`Disney+`, títulos acentuados e empates de pontuação), `filmes-com-invalidos.json`, `filmes-todos-invalidos.json`, `filmes-vazio.json`, `publicidades.json`, `malformado.txt`. O README declara: **sintéticas, não representam a produção**.
- **Validação:** teste de esquema (cada arquivo é JSON válido, exceto `malformado.txt`).
- **Aceite:** verde.
- **Git:** commit `test(front): fixtures determinísticas`.

#### F2-T05: Tipos e mapeadores (A-01)
- **Dependências:** F2-T04.
- **Arquivos permitidos:** `src/types/contrato.ts`, `src/types/modelos.ts`, `src/services/mapeadores.ts`, `tests/unit/mapeadores.test.ts`.
- **Alterações:**
  - campos do contrato como `T | null`;
  - obrigatórios para manter um filme: `id_filme` (inteiro > 0), `titulo_filme` (não vazio), `duracao_filme` (≥ 0), `nota_filme` (número finito);
  - strings opcionais nulas → `''`; `generos` nulo → `[]`;
  - URLs passam pela mesma regra do `SafeImage`;
  - retorno `{ itens, descartados }`; raiz não-array, ou todos inválidos com lista não vazia → erro `formato`.
- **Validação:** cada campo nulo individualmente; tipos errados; lista mista 9+1; todos inválidos; `[]` → vazio (não erro).
- **Aceite:** todos verdes.
- **Git:** commit `feat(front): contrato e normalização de dados`.

#### F2-T06: Serviços de catálogo e publicidade
- **Dependências:** F2-T05.
- **Arquivos permitidos:** `src/services/filmes.ts`, `src/services/publicidades.ts`, `tests/unit/servicos.test.ts`.
- **Alterações:** `listarTodos`, `aleatorios`, `porStreaming(valor)`, `outros`, `pesquisar(termo)`, `listarPublicidades`.
- **Validação:** cada função chama o caminho exato esperado (verificado pela URL que o `fetch` simulado recebeu) e mapeia a fixture.
- **Aceite:** 6 funções × (sucesso + erro) verdes.
- **Git:** commit `feat(front): serviços de catálogo`.

#### F2-T07: Cache do catálogo (`useCatalogo`)
- **Dependências:** F2-T06.
- **Arquivos permitidos:** `src/composables/useCatalogo.ts`, `tests/unit/useCatalogo.test.ts`.
- **Alterações:** TTL de 5 min; deduplicação; `porId(id)`; `invalidar()`; erro não fica em cache.
- **Validação:** duas chamadas simultâneas = 1 fetch; após o TTL = novo fetch; após erro, a próxima chamada refaz; `porId` inexistente → `undefined`.
- **Aceite:** os casos verdes.
- **Git:** commit `feat(front): cache do catálogo`.

#### F2-T08: `StateView` + aviso de lentidão + retry
- **Dependências:** F2-T07.
- **Arquivos permitidos:** `src/components/StateView.vue`, `src/composables/useAvisoLentidao.ts`, `tests/components/StateView.test.ts`.
- **Alterações:** estados `carregando | erro | vazio | sucesso`; mensagens por tipo de erro; aviso após 5 s; botão "Tentar novamente" que emite um evento (sem retry automático); `aria-live="polite"`.
- **Validação:** relógio falso: aviso ausente em 4,9 s e presente em 5 s; o retry emite um evento; nenhum retry automático em 60 s simulados.
- **Aceite:** verdes.
- **Git:** commit `feat(front): estados de carregamento, erro e vazio`.

### F3: Domínio e recomendações

#### F3-T01: Opções do questionário
- **Dependências:** F2-T08.
- **Arquivos permitidos:** `src/domain/questionario.ts`, `tests/unit/questionario-opcoes.test.ts`.
- **Evidência:** `form.dart:20-66`.
- **Alterações:** listas literais (12 gêneros, 4 durações, 6 streamings, 6 classificações, 10 países), sem "Outro" (A-03).
- **Validação:** snapshot literal com comentário citando as linhas de origem.
- **Aceite:** igualdade exata, inclusive a ordem.
- **Git:** commit `feat(front): opções do questionário`.

#### F3-T02: Tabela de streamings
- **Dependências:** F3-T01.
- **Arquivos permitidos:** `src/domain/streamings.ts`, `tests/unit/streamings.test.ts`.
- **Evidência:** `home.dart:300-337`.
- **Alterações:** `{slug, rotulo, logo, valorFiltro}` para `netflix, hbo-max, disney-plus, apple-tv, globoplay, prime-video, tela-brasil, outros`; `valorFiltro` com os valores da Home (A-05); `outros` aponta para o endpoint próprio.
- **Validação:** slugs únicos; `globoplay → "GloboPlay"`; `apple-tv → "Apple TV"`.
- **Aceite:** verde.
- **Git:** commit `feat(front): tabela de streamings`.

#### F3-T03: `formatarDuracao`
- **Dependências:** F3-T02.
- **Arquivos permitidos:** `src/domain/duracao.ts`, `tests/unit/duracao.test.ts`.
- **Validação:** 0 → `0h0min`; 59 → `0h59min`; 125 → `2h5min`.
- **Aceite:** verdes.
- **Git:** commit `feat(front): formatação de duração`.

#### F3-T04: Recomendação
- **Dependências:** F3-T03.
- **Arquivos permitidos:** `src/domain/recomendacao.ts`, `tests/unit/recomendacao.test.ts`.
- **Alterações:** `calcularPontuacao(filme, respostas)` e `ordenarSugestoes(filmes, respostas, n = 3)`, conforme a seção 6.2.
- **Validação:** casos tabelados:

  | # | Caso | Esperado |
  |---|---|---|
  | 1 | gênero coincide | 3 |
  | 2 | dois gêneros coincidem | 3 (não soma por gênero) |
  | 3 | `drama` × `Drama` | 0 |
  | 4–7 | durações 90, 91, 180 e 181 com a faixa correspondente | 2 cada |
  | 8 | 90 com `1h30 - 2h` | 0 |
  | 9 | `Apple TV` × `AppleTV` | 0 |
  | 10 | classificação igual | 2 |
  | 11 | país igual | 1 |
  | 12 | ator no diretor | 1 |
  | 13 | ator no elenco | 1 |
  | 14 | `conceicao` × `Conceição` | 0 |
  | 15 | ator `"  "` | 1 se a string contiver `"  "`, senão 0 |
  | 16 | todos os critérios | 12 |
  | 17 | 2 filmes | top 2 |
  | 18 | empate | ordem de entrada preservada |
  | 19 | 0 filmes | `[]` |
  | 20 | filme com 0 ponto | entra no top 3 |
- **Aceite:** 20 casos verdes.
- **Git:** commit `feat(front): regra de recomendação (paridade)`.

#### F3-T05: `useQuestionario`
- **Dependências:** F3-T04.
- **Arquivos permitidos:** `src/composables/useQuestionario.ts`, `tests/unit/useQuestionario.test.ts`.
- **Alterações:**
  - alternar gênero, streaming e país;
  - duração única;
  - classificação alternável (clicar de novo desmarca);
  - ator;
  - persistência em `mm.questionario.v1`;
  - `limpar()`;
  - `validar()` com os textos literais: "Selecione pelo menos um gênero", "Selecione uma duração", "Selecione pelo menos uma plataforma de streaming".
- **Validação:** alternâncias; persistência e restauração; JSON corrompido; storage que lança exceção; ordem das validações.
- **Aceite:** verdes.
- **Git:** commit `feat(front): estado do questionário`.

### F4: Experiência pública

Para cada página: testes de componente para os 4 estados + E2E no perfil B (F5-T06), adicionados à suíte na tarefa da página quando o perfil B existir. Até lá, só testes de componente.

#### F4-T01: Assets
- **Dependências:** F3-T05.
- **Arquivos permitidos:** `scripts/otimizar-assets.sh`, `src/assets/**`, `public/favicon.png`, `public/icons/**`.
- **Alterações:**
  - o script lê `../projeto_brademo/assets/` e `../projeto_brademo/web/` (**só leitura**) e gera, com o ImageMagick 6.9.12 do host, WebP para pôsteres e logos;
  - os originais do Flutter não são tocados;
  - o comando exato e a versão da ferramenta ficam no cabeçalho do script.
- **Validação:** `git status` mostra zero alterações em `projeto_brademo/`; tamanho total de `src/assets` ≤ 1,5 MB; cada pôster ≤ 150 KB.
- **Aceite:** ambos.
- **Git:** commit `feat(front): assets otimizados`.
- **Riscos:** reprodutibilidade depende da versão do ImageMagick, que fica registrada; os arquivos gerados são versionados.

#### F4-T02: `MovieCard`
- **Dependências:** F4-T01.
- **Arquivos permitidos:** `src/components/MovieCard.vue`, `tests/components/MovieCard.test.ts`.
- **Alterações:** pôster (`SafeImage`), título em maiúsculas, nota, duração; o card inteiro é um link para `/filmes/:id`.
- **Validação:** renderização; `href` correto; `alt` igual ao título.
- **Aceite:** verdes.
- **Git:** commit `feat(front): cartão de filme`.

#### F4-T03: Raiz + Boas-vindas (A-04)
- **Dependências:** F4-T02.
- **Arquivos permitidos:** `src/pages/BoasVindas.vue`, `src/composables/usePrimeiraVisita.ts`, `src/router/index.ts`, `tests/components/BoasVindas.test.ts`, `tests/unit/usePrimeiraVisita.test.ts`.
- **Alterações:**
  - `/` → `/boas-vindas` na primeira visita, senão `/inicio`;
  - textos "Bem-vindo(a) ao MovieMatch" e "Descubra novos filmes e conheça o seu próximo favorito para assistir";
  - botões "Começar questionário" e "Explorar filmes";
  - sem login.
- **Validação:** primeira visita, segunda visita, storage indisponível (sem loop).
- **Aceite:** verdes.
- **Git:** commit `feat(front): boas-vindas na primeira visita`.

#### F4-T04: Início
- **Dependências:** F4-T03.
- **Arquivos permitidos:** `src/pages/Inicio.vue`, `tests/components/Inicio.test.ts`.
- **Alterações:**
  - "Olá!" e "Encontre o filme perfeito para sua noite";
  - atalho para Pesquisa (sem sino, A-06);
  - carrossel de publicidade com scroll-snap, sem autoplay;
  - "Você pode gostar" com os aleatórios;
  - "Descubra novos filmes por streaming" com os 8 logos;
  - **cada seção com seu próprio `StateView`**.
- **Validação:** sucesso; falha só em publicidade (filmes continuam aparecendo); vazio; erro geral; retry.
- **Aceite:** verdes.
- **Git:** commit `feat(front): página inicial`.

#### F4-T05: Detalhe
- **Dependências:** F4-T04.
- **Arquivos permitidos:** `src/pages/FilmeDetalhe.vue`, `tests/components/FilmeDetalhe.test.ts`.
- **Alterações:**
  - carrega via `useCatalogo().porId`;
  - "BOA ESCOLHA!", "Direção", "Descrição", "Disponível em:", "Elenco" (A-02);
  - **sem** Curtir nem Minha Lista;
  - id inexistente → estado "não encontrado".
- **Validação:** sucesso, não encontrado, erro, retry.
- **Aceite:** verdes.
- **Git:** commit `feat(front): detalhe do filme`.

#### F4-T06: Pesquisa
- **Dependências:** F4-T05.
- **Arquivos permitidos:** `src/pages/Pesquisa.vue`, `tests/components/Pesquisa.test.ts`.
- **Alterações:**
  - campo "Pesquisar"; Enter atualiza `?q=`;
  - estados inicial, carregando, vazio ("Filme não localizado no catálogo") e erro;
  - `/` recusado com mensagem;
  - F5 com `?q=` refaz a busca.
- **Validação:** os estados; acentos e espaço; `/`.
- **Aceite:** verdes.
- **Git:** commit `feat(front): pesquisa`.

#### F4-T07: Streaming
- **Dependências:** F4-T06.
- **Arquivos permitidos:** `src/pages/Streaming.vue`, `tests/components/Streaming.test.ts`.
- **Alterações:** slug → `valorFiltro`; `outros` → endpoint próprio; slug desconhecido → `NaoEncontrado`; "Últimos lançamentos no catálogo".
- **Validação:** `disney-plus` chama `porStreaming('Disney+')`; `outros`; slug inválido.
- **Aceite:** verdes.
- **Git:** commit `feat(front): navegação por streaming`.

#### F4-T08: Questionário
- **Dependências:** F4-T07.
- **Arquivos permitidos:** `src/pages/Questionario.vue`, `src/components/ChipGroup.vue`, `tests/components/Questionario.test.ts`, `tests/components/ChipGroup.test.ts`.
- **Alterações:**
  - 8 passos com os textos do Flutter, sem "Outro";
  - progresso `passo/8`;
  - passo na URL;
  - ✕ volta para `/inicio`;
  - FINALIZAR (passos 5 e 8) valida e vai para `/sugestoes`;
  - LIMPAR no passo 8;
  - chips com `role="checkbox"` ou `"radio"` e teclado (Espaço/Enter).
- **Validação:** navegação por todos os passos; validações; teclado; voltar do navegador entre passos.
- **Aceite:** verdes.
- **Git:** commit `feat(front): questionário`.

#### F4-T09: Sugestões
- **Dependências:** F4-T08.
- **Arquivos permitidos:** `src/pages/Sugestoes.vue`, `tests/components/Sugestoes.test.ts`.
- **Alterações:**
  - `ordenarSugestoes(catálogo, respostas)`, top 3;
  - "Sugestões com base nas suas respostas" e "Disponível em …";
  - sem respostas válidas → redireciona para `/questionario/1`;
  - "voltar ao questionário" limpa as respostas (paridade com `form.dart:789-791`);
  - estado "nenhum filme no catálogo".
- **Validação:** o top 3 exibido é igual ao da função para a fixture; redirecionamento; limpeza.
- **Aceite:** verdes.
- **Git:** commit `feat(front): sugestões`.

### F5: Containers e proxy

#### F5-T01: Gerador da allowlist do Nginx
- **Dependências:** F4-T09.
- **Arquivos permitidos:** `scripts/gerar-nginx-allowlist.mjs`, `docker/nginx/allowlist.conf`, `package.json`, `tests/scripts/gerar-nginx-allowlist.test.mjs`.
- **Alterações:** gera uma `location ~ ^/api/(…)$` a partir do JSON; `npm run check:allowlist` falha se houver diferença.
- **Validação:**
  - duas execuções produzem bytes idênticos;
  - alterar o JSON em uma cópia temporária faz o check falhar;
  - a regex gerada aceita e recusa os mesmos casos de `permitido()` (tabela compartilhada com a F2-T01).
- **Aceite:** verdes; o `check:allowlist` entra no perfil A.
- **Git:** commit `build(front): allowlist do Nginx gerada da fonte única`.

#### F5-T02: Mock da API
- **Dependências:** F5-T01.
- **Arquivos permitidos:** `docker/mock-api/server.mjs`, `tests/unit/mock-api.test.ts`.
- **Alterações:** seção 7; Node puro (`node:http`), sem dependências; porta 8081; registro de requisições **brutas** (`req.url` sem decodificar).
- **Validação:** no perfil A, o teste sobe o servidor em processo (porta efêmera) e verifica cada cenário e o registro de `/filmes/streaming/Disney%2B` literal.
- **Aceite:** 11 cenários verdes.
- **Git:** commit `test(front): mock da API com cenários`.

#### F5-T03: Dockerfile + Nginx
- **Dependências:** F5-T02.
- **Arquivos permitidos:** `docker/Dockerfile`, `docker/nginx/default.conf.template`, `.dockerignore`.
- **Alterações:**
  - build `node:24.22.1-alpine3.24` (`npm ci`, `check:allowlist`, `build`);
  - runtime `nginxinc/nginx-unprivileged:1.31.7-alpine3.24`;
  - `include allowlist.conf`;
  - headers de segurança e cache **em todos os blocos** (`include` comum, evitando a armadilha de herança do `add_header`);
  - `/healthz` local;
  - `listen ${PORT}` (padrão 8080);
  - `resolver ${NGINX_LOCAL_RESOLVERS}`;
  - `HEALTHCHECK` com `wget`;
  - CSP `default-src 'self'; img-src 'self' https: data:; connect-src 'self'; script-src 'self'; style-src 'self'; font-src 'self'; frame-ancestors 'none'; base-uri 'self'; form-action 'none'`.
- **Validação:**
  - `docker build -f docker/Dockerfile moviematch_front` (contexto = diretório do front);
  - imagem ≤ base + 10 MB (a base `nginx-unprivileged` já tem 91,1 MB; a meta original de 60 MB era inviável, ver `docs/ambiente.md`);
  - `docker run` efêmero com label; `/healthz` (via `docker exec wget`) responde; `id -u` = 101;
  - o template foi processado (`nginx -T` contém a porta).
- **Aceite:** os 4 critérios; container removido.
- **Git:** commit `build(front): imagem de produção com Nginx sem root`.
- **Riscos:** suporte a `NGINX_LOCAL_RESOLVERS` na variante unprivileged (HIPÓTESE). Alternativa: script de entrypoint próprio que lê `/etc/resolv.conf`.

#### F5-T04: Orquestração dos perfis (`docker/compose.yml` + `scripts/perfil.sh`)
- **Dependências:** F5-T03.
- **Arquivos permitidos:** `docker/compose.yml`, `scripts/perfil.sh`, `tests/scripts/perfil.test.sh`.
- **Alterações:**
  - `perfil.sh <b|c|d|e> [cenario]` gera `-p mmf-<perfil>-<UTC>-<rand>`, aplica a label `br.moviematch.front.teste=<run-id>`, usa redes e volumes do próprio projeto (`internal: true`) e **nenhuma** porta publicada;
  - faz o build da imagem do front **antes** do `up` (único passo com rede);
  - `up --wait` com healthchecks;
  - `trap` que executa `down -v --remove-orphans` **só do próprio projeto** e depois confere que não sobrou recurso com a label do run.
- **Validação:** `perfil.sh smoke` (front + mock) passa; após a execução, `docker ps -a/network ls/volume ls --filter label=…` ficam vazios; os recursos de outros projetos permanecem inalterados (comparação antes/depois).
- **Aceite:** ambos.
- **Git:** commit `test(front): orquestração isolada dos perfis`.

#### F5-T05: Perfil D (proxy e segurança)
- **Dependências:** F5-T04.
- **Arquivos permitidos:** `tests/proxy/*.test.mjs`, `docker/compose.yml`.
- **Alterações:** a sonda `node:24` executa `node --test` contra `http://front:8080` e consulta o `GET /__requisicoes` do mock.
- **Validação (cada caso confere a resposta E o que o mock recebeu):**

  | Caso | Esperado |
  |---|---|
  | as 6 rotas, GET | 200 |
  | HEAD | 200 sem corpo |
  | POST/PUT/DELETE/PATCH/OPTIONS | 403, mock nada recebeu |
  | `/api/usuarios`, `/api/listas`, `/api/filmes/1/x`, `/api/filmes/streaming/` | 404, mock nada recebeu |
  | `/api/filmes/streaming/Disney%2B` | mock recebe `Disney%2B` |
  | `/api/filmes/streaming/Disney+` | mock recebe `Disney+` |
  | `/api/filmes/pesquisa/a%2Fb` | 404 |
  | pesquisa com `%20` e acentos `%C3%A7` | intactos |
  | `?x=1` | query **não** repassada |
  | `Cookie` e `Origin` | removidos no upstream |
  | `Set-Cookie` do upstream | ausente na resposta |
  | headers de segurança | em `/`, `/index.html`, `/assets/*`, `/api/*` |
  | `Cache-Control` | `immutable` em `/assets/*`, `no-cache` em `index.html` |
  | `/rota/qualquer` | `index.html` (SPA) |
  | `/healthz` com o mock parado | 200 |
  | mock parado | `/api/filmes` → 502 |
  | mock `lento:40000` | 504 em 35 s ± 2 |
  | mock `lento:32000` | 200 (proxy aguarda mais que o cliente) |
  | processo nginx | uid 101 |
  | upstream por nome de serviço | resolve via DNS da rede |
- **Aceite:** 100% verdes; limpeza confirmada.
- **Git:** commit `test(front): perfil D proxy e segurança`.

#### F5-T06: Perfil B (E2E com API simulada)
- **Dependências:** F5-T05.
- **Arquivos permitidos:** `playwright.config.ts`, `tests/e2e/b/*.spec.ts`, `package.json`, `package-lock.json`, `docker/compose.yml`.
- **Alterações:** `@playwright/test@1.64.1` na imagem `v1.64.1-noble`; specs por página, cobrindo o fluxo completo: boas-vindas → questionário → sugestões → detalhe; pesquisa; streaming; 404.
- **Validação:**
  - cada cenário do mock (`vazio`, `invalidos`, `todos-invalidos`, `json-malformado`, `http-500`, `repetidos`, `streamings-divergentes`) produz o estado esperado;
  - acesso direto e F5 em todas as rotas;
  - voltar do navegador;
  - **escuta de `securitypolicyviolation`: zero violações de CSP.**
- **Aceite:** 100% verdes, em 3 execuções seguidas (detecção de testes instáveis).
- **Git:** commit `test(front): perfil B E2E com API simulada`.

### F6: Integração isolada (perfil C)

#### F6-T01: Pré-condições e autorização (**autorização explícita**)
- **Objetivo:** obter autorização para: pull de `mysql:8.4.13`; executar `moviematch-back:baseline`; **o backend criar o schema** (`ddl-auto=update`) no MySQL descartável; inserir o seed sintético.
- **Dependências:** F5-T06.
- **Arquivos permitidos:** nenhum.
- **Validação:** `docker image inspect` confirma a imagem (seção 2.2); a imagem não é reconstruída.
- **Aceite:** autorização registrada.
- **Git:** registro.
- **Bloqueio:** sem autorização, a F6 inteira fica BLOQUEADA e a integração **não** é declarada validada.

#### F6-T02: Compose do perfil C com controles de egresso testados
- **Dependências:** F6-T01.
- **Arquivos permitidos:** `docker/compose.yml`, `docker/perfil-c/seed.sql`, `tests/proxy/egresso.test.mjs`.
- **Alterações:**
  - serviços `mysql` (credenciais descartáveis geradas pelo `perfil.sh` a cada execução, nunca versionadas) e `backend` com `SPRING_DATASOURCE_URL=jdbc:mysql://mysql:3306/mm`, `SPRING_DATASOURCE_USERNAME`, `SPRING_DATASOURCE_PASSWORD` e `DB_PASSWORD` descartáveis, e `PORT=8080`;
  - rede `internal`;
  - o seed é aplicado **depois** de o backend criar as tabelas (espera por `GET /filmes` = 200 com lista vazia).
- **Controles (todos testados, nenhum presumido):**
  1. Da rede do backend (`network_mode: service:backend` na sonda): resolução DNS de `moviematch-db-moviematch-db.k.aivencloud.com` **falha**; TCP para `1.1.1.1:443` e para o IP público do host **falham**.
  2. O log do backend mostra a URL JDBC apontando para `mysql:3306` e nenhuma ocorrência de `aivencloud`.
  3. Nenhuma credencial real está presente: `DB_PASSWORD` é aleatório por execução.
- **Aceite:** os 3 controles verdes antes de qualquer teste funcional.
- **Git:** commit `test(front): perfil C isolado com controles de egresso`.
- **Riscos:** se o backend exigir algo além de variáveis de ambiente para subir, **parar**, registrar e seguir só com o perfil B.

#### F6-T03: Validação de contrato
- **Dependências:** F6-T02.
- **Arquivos permitidos:** `tests/contrato/*.test.mjs`, `docs/contrato.md`.
- **Alterações:** a sonda chama os 6 endpoints e `GET /filmes/1`, `/filmes/streaming/Disney%2B` e `/filmes/pesquisa/<acentos>` direto no backend, e registra status, `Content-Type`, formato, campos nulos com seed contendo nulos, e ausência de headers CORS.
- **Validação:** os tipos de `src/types/contrato.ts` aceitam 100% das respostas; divergências viram itens em `docs/contrato.md`.
- **Aceite:** cada linha da seção 5 reclassificada para CONFIRMADO (em execução isolada) ou divergente, com evidência.
- **Git:** commit `docs(front): contrato validado no perfil C`.

#### F6-T04 (condicional): Ajustes por divergência
- **Dependências:** F6-T03.
- **Arquivos permitidos:** os da tarefa original afetada.
- **Alterações:** **uma tarefa e um commit por divergência**, cada um com teste de regressão. Mudanças de comportamento (A-02, A-05) exigem aprovação antes.
- **Git:** commits `fix(front): …`.

#### F6-T05: E2E principal no perfil C
- **Dependências:** F6-T03 (e F6-T04, se houver).
- **Arquivos permitidos:** `tests/e2e/c/*.spec.ts`.
- **Validação:** fluxo boas-vindas → questionário → sugestões → detalhe; pesquisa; streaming, contra o backend real e o seed.
- **Aceite:** verde em 3 execuções.
- **Git:** commit `test(front): E2E contra o backend original isolado`.

### F7: Qualidade e documentação

| ID | Título | Dependências | Arquivos permitidos | Validação e aceite mensurável | Git |
|---|---|---|---|---|---|
| F7-T01 | Resiliência (perfil E) | F6-T05 ou F5-T06 se a F6 estiver bloqueada | `tests/e2e/e/resiliencia.spec.ts` | `lento:6000` → aviso visível ≥ 5 s, depois sucesso; `lento:32000` → erro de timeout aos 30 s ± 1; `pendurado` → idem; mock parado → erro; mock reiniciado + "Tentar novamente" → sucesso **sem recarregar a página**; 5 componentes pedindo o catálogo ao mesmo tempo → 1 requisição registrada no mock | commit |
| F7-T02 | Acessibilidade | F7-T01 | `tests/e2e/e/a11y.spec.ts` | axe em todas as rotas e estados (sucesso, erro, vazio): 0 violações `serious` ou `critical`; questionário completo só por teclado | commit |
| F7-T03 | Responsividade | F7-T02 | `tests/e2e/e/responsivo.spec.ts` | 360×800, 768×1024, 1280×800: `scrollWidth ≤ clientWidth` em todas as rotas; alvos de toque ≥ 44 px | commit |
| F7-T04 | Desempenho | F7-T03 | `tests/e2e/e/desempenho.spec.ts`, `docs/metricas.md` | Métricas definidas **antes**: JS inicial ≤ 150 KB gzip (medido em `dist/`); imagens ≤ 1,5 MB; LCP no Chromium do perfil E (CPU sem throttle, rede interna) ≤ 2,5 s em `/inicio`; tempo até `/healthz` = 200 após `up` ≤ 5 s. Inicialização fria × quente do container registrada (informativo) | commit |
| F7-T05 | README e troubleshooting | F7-T04 | `README.md`, `docs/troubleshooting.md` | Um terceiro executa os perfis A e B só com o README (verificação manual registrada); seção de limitações (sem conta, API legada, allowlist não é segurança) | commit |
| F7-T06 | Reprodutibilidade | F7-T05 | nenhum | Clone limpo em diretório temporário: perfis A, B e D verdes; `package-lock.json` sem alterações após `npm ci` | registro |

### F8: Gate de entrega

| ID | Título | Dependências | Ação | Aceite | Git |
|---|---|---|---|---|---|
| F8-T01 | Execução final | F7-T06 | Perfis A, B, D, E (+ C se autorizado) | 100% verdes; limpeza confirmada | registro |
| F8-T02 | Integridade | F8-T01 | `verificar-fronteira.sh`; `git log <base>..HEAD --format='%an%x09%s'` (autor = identidade autorizada); `git log <base>..HEAD --format=%B \| grep -iE 'co-authored\|claude\|anthropic\|generated with'` **vazio**; cada commit mapeado a uma tarefa | tudo ok | registro |
| F8-T03 | Instruções de publicação | F8-T02 | `docs/PUBLICACAO.md`: Render Web Service Docker (contexto `moviematch_front`, `-f docker/Dockerfile`), variáveis `API_UPSTREAM`, `API_HOST`, `PORT`, healthcheck `/healthz`; **pré-requisito: API de produção respondendo e contrato validado** | revisado | commit |
| F8-T04 | Push, PR e deploy | F8-T03 | **Não executar sem autorização explícita.** O `main` fica intacto. Push **só da branch `front-vue`** para o **fork do usuário** (remote a ser adicionado pelo usuário; o `origin` atual é o repositório original, `fork: false`). Deploy no Render a partir da branch `front-vue`, com Dockerfile `moviematch_front/docker/Dockerfile` e contexto `moviematch_front/`. PR (opcional): `front-vue` → `main` do fork ou do repositório original, decisão do usuário | — | — |

## 10. Grafo de dependências

```text
F0-T01 → F0-T02* → F0-T03 → F0-T04 → F0-T05*
  → F1-T01 → T02 → T03 → T04 → T05 → T06 → T07 → T08 → T09
  → F2-T01 → T02 → T03 → T04 → T05 → T06 → T07 → T08
  → F3-T01 → T02 → T03 → T04 → T05
  → F4-T01 → T02 → T03 → T04 → T05 → T06 → T07 → T08 → T09
  → F5-T01 → T02 → T03 → T04 → T05 → T06
  → F6-T01* → T02 → T03 → [T04…] → T05      (bloqueável; se bloqueada, F7 segue a partir de F5-T06)
  → F7-T01 → T02 → T03 → T04 → T05 → T06
  → F8-T01 → T02 → T03 → F8-T04*
* = exige autorização explícita
```

A execução é estritamente sequencial, sem branches auxiliares.

## 11. Estratégia de commits

1. Uma tarefa por vez. Tarefas com arquivos geram **um** commit; tarefas sem arquivos geram **registro**, nunca commit vazio.
2. Antes de cada commit:
   - `git status --porcelain --untracked-files=all`;
   - `git diff`;
   - `git add <caminhos explícitos da tarefa>` (**nunca** `git add .` ou `-A`);
   - `git diff --cached --name-only` (só caminhos permitidos da tarefa);
   - `git diff --cached --check`;
   - `scripts/verificar-fronteira.sh`;
   - perfil A (e o perfil da tarefa).
3. Mensagem no formato `tipo(front): descrição`, com corpo `Tarefa: <ID>`. **Sem trailers de coautoria, sem menções a Claude, Anthropic ou ferramentas de IA.** A mensagem e os metadados são inspecionados antes de gravar (`git commit` com mensagem por arquivo temporário revisado).
4. Autor: a identidade global existente (Jonas Ribeiro da Rosa). Ela **não é alterada**; se estiver ausente ou divergente, parar.
5. O hash é registrado no relatório **depois** do commit, nunca dentro dele.
6. Nada de push, PR ou alteração remota sem autorização.

## 12. Critérios de aceitação globais

- [ ] `verificar-fronteira.sh` com exit 0 em relação à base `4c90b64`.
- [ ] Perfis A, B, D e E verdes no estado final; C verde **ou** registrado como BLOQUEADO com motivo.
- [ ] 20 casos de recomendação e listas do questionário idênticas às do Flutter.
- [ ] Proxy: todos os casos da F5-T05 verdes, inclusive o bloqueio de `/usuarios`, `/listas` e não-GET.
- [ ] Zero violações de CSP; zero violações axe `serious`/`critical`.
- [ ] Métricas da F7-T04 dentro dos limites.
- [ ] Nenhum `localStorage` além de `mm.questionario.v1` e `mm.visitou.v1`; nenhum dado pessoal.
- [ ] Zero recursos Docker remanescentes com a label de teste; recursos de outros projetos inalterados.
- [ ] Histórico sem coautoria ou menções a IA; um commit por tarefa com arquivos.
- [ ] **Publicação** (fora deste plano) só com a API de produção respondendo e o contrato validado.

## 13. Riscos, hipóteses e bloqueios

| ID | Tipo | Descrição | Prioridade | Tratamento |
|---|---|---|---|---|
| R-01 | Bloqueio potencial | Docker snap sem permissão para parar ou remover containers (visto em 03/10) | **P0** | F0-T05; correção no sistema pelo usuário |
| R-02 | Bloqueio | API de produção sem resposta (22/10); não verificada nesta fase | **P0 para publicar** | Fora do escopo; perfil C como alternativa de validação |
| R-03 | Bloqueio condicionado | Perfil C exige autorização para executar backend, criar schema e semear | P1 | F6-T01 |
| R-04 | Hipótese | Majors recentes: `vue-router` 5, `vite` 8, `vitest` 5, `eslint` 10 | P1 | Guias de migração na tarefa; parar em incompatibilidade |
| R-05 | Hipótese | `NGINX_LOCAL_RESOLVERS` e templates na imagem unprivileged | P2 | F5-T03 com alternativa definida |
| R-06 | Hipótese | Vite 8: `bypass` no proxy | P2 | F2-T02 com alternativa (middleware) |
| R-07 | Bloqueado | Valores reais de streaming, gênero, classificação, país e nulos | P1 | Perfil C (seed sintético não resolve); produção, quando autorizada e disponível |
| R-08 | Hipótese | Limite de 5 MB para o catálogo | P2 | Recalibrar na F6/F8 |
| R-09 | Risco | `--internal` não ser suficiente sozinho | P1 | Controles testados na F6-T02 |
| R-10 | Risco | O `ddl-auto=update` do backend conectar no Aiven por override errado | **P0 no perfil C** | Rede `internal` + teste de DNS/TCP + verificação do log **antes** do seed; credenciais reais nunca presentes |
| R-11 | Risco | Testes instáveis no E2E | P2 | 3 execuções seguidas como aceite |
| R-12 | Restrição | O `origin` local aponta para o repositório **original** (`Isabelly-Nathalia/BRADEMO_PROJETO`, `fork: false` pela API do GitHub), não para o fork do usuário | P1 | Nunca fazer push no `origin`. Na F8-T04, o usuário adiciona o remote do fork, e o push vai **só** para a branch `front-vue` desse remote |

## 14. Execução e limpeza dos ambientes

```bash
moviematch_front/scripts/perfil.sh a               # sem pilha; só container node efêmero
moviematch_front/scripts/perfil.sh b [cenario]     # front + mock + playwright
moviematch_front/scripts/perfil.sh d               # front + mock + sonda
moviematch_front/scripts/perfil.sh e               # front + mock + playwright (resiliência, a11y, desempenho)
moviematch_front/scripts/perfil.sh c               # só após F6-T01: mysql + backend + front + sonda + playwright
```

**Limpeza automática (trap no `perfil.sh`):**
- `docker compose -p <projeto> down -v --remove-orphans`;
- depois, verifica que `docker ps -a`, `docker network ls` e `docker volume ls` filtrados por `label=br.moviematch.front.teste=<run-id>` estão vazios.

**Limpeza manual de um run interrompido:** `scripts/perfil.sh limpar <run-id>`, que remove **somente** recursos com aquela label.

**Proibido:** `docker system prune`, `docker rm`/`network rm`/`volume rm` sem filtro de label, remover imagens.

Recursos preexistentes (`f0`, `lab-localstack`, `adme_redis`, `easteregg-adme_adme_network`, 3 volumes) são comparados antes e depois de cada perfil.

## 15. O que não será feito

- Alterar `moviematch_back/`, `projeto_brademo/`, o `Dockerfile` da raiz ou qualquer arquivo da raiz.
- Reconstruir a imagem do backend.
- Implementar login, cadastro, senha, perfil, avatar, curtidas, listas, notificações ou administração.
- Chamar `/usuarios*` ou `/listas*`.
- Acessar o Aiven, a produção do Render ou outros serviços remotos sem autorização específica.
- Push, PR, deploy, CI no GitHub ou alteração de configuração global do Git e de hooks.
- Usar Kubernetes (possível evolução futura, sem requisito atual).
- Declarar a integração validada sem evidência de execução do perfil C ou da produção.

## 16. Registro de execução e desvios

Desvios em relação às tarefas, registrados à medida que ocorrem. Todos ficaram dentro de `moviematch_front/`.

| Tarefa | Desvio | Motivo |
|---|---|---|
| F0-T04 | Script com `--no-renames` e `GIT_OPTIONAL_LOCKS=0` | Um rename de fora para dentro escondia a deleção externa, e o `git diff` podia reescrever o índice |
| F0-T05 | Commit extra com o reteste do Docker | O `sudo snap restart docker`, executado pelo usuário, resolveu o R-01 |
| F1-T02 | `tsconfig.app.json` adicionado (layout de solução com 3 arquivos) | O TypeScript recusa referência a projeto com `noEmit` a partir de um projeto com arquivos (TS6310) |
| F1-T03 | `no-restricted-properties` além de `no-restricted-globals` | A regra de globais não pega `window.localStorage` |
| F1-T04 | Testes e `vitest.config.ts` incluídos no typecheck | Erros de tipo nos testes passariam despercebidos |
| F1-T06 | `vitest.config.ts`: `css.include` para `src/styles/` | Por padrão o Vitest devolve CSS vazio, inclusive com `?raw` |
| F1-T06 | Texto terciário proibido sobre `--cor-destaque` | Contraste abaixo de 4,5:1 |
| F1-T07 | Commit extra: `vitest.config.ts` importa `vite.config.ts` com extensão | Aviso do Vite sobre o carregador nativo de configuração (padrão em major futuro) |
| F1-T07 | Lint com `--max-warnings 0`; `vue/multi-word-component-names` desligada em `src/pages/` | Avisos não podem se acumular; páginas não são usadas como tag |
| F1-T08 | `tests/unit/app.test.ts` ajustado | O atalho "Pular para o conteúdo" passou a ser o primeiro link |
| F1-T09 | `SafeImage` só para URLs da API; assets locais usam `<img>` | O Vite pode embutir assets locais como `data:`, que o componente recusa de propósito |
| F2-T01 | Casos da allowlist em `tests/scripts/casos-allowlist.mjs` | Serão reutilizados pelo teste do gerador do Nginx; importar um `.test.mjs` faria os testes rodarem duas vezes |
| F2-T01 | Script `test:scripts` incluído no perfil A | Os testes `node --test` de `tests/scripts/` não rodavam automaticamente |
| F2-T02 | Plugin com middleware próprio em vez de `bypass` (R-06) | Comportamento verificável e idêntico ao do Nginx (404/403); a chave do proxy virou regex porque `/api` casaria `/apix` |
| F2-T02 | Teste em `tests/scripts/proxy-dev.test.mjs` (`node --test`), não em `tests/unit/` | Sobe o Vite real com `node:http`; os testes unitários não têm tipos de Node |
| F2-T02 | Upstream em `MM_API_UPSTREAM` (sem prefixo `VITE_`) | Variáveis `VITE_*` podem vazar para o bundle do navegador |
| F2-T02 | `allowJs` + `checkJs` no `tsconfig.node.json` para `scripts/*.mjs` | O `vite.config.ts` importa os scripts; agora eles passam pelo typecheck |
| F2-T03 | Caso extra: corpo que trava depois dos cabeçalhos | Prova que o timeout cobre a leitura do corpo |
| F2-T04 | Fixtures extras: `filmes-repetidos.json`, `objeto-na-raiz.json` | Cobrem os cenários "repetidos" do mock e o erro sistêmico de raiz |
| F2-T05 | Deduplicação por `id` (mantém o primeiro, conta `repetidos`) | IDs repetidos quebrariam as chaves das listas no Vue |
| F2-T05 | `src/services/url.ts` extraído; `SafeImage` passou a usá-lo | Uma única regra de URL https para mapeadores e componente |
| F2-T06 | `porStreaming('outros')` recusado | No backend, `/filmes/streaming/outros` é uma rota própria, não um streaming |
| F2-T08 | `src/components/mensagemErro.ts` | Textos de erro por tipo, testáveis sem montar o componente |
| F3-T01 | Tipo `Respostas` e `respostasVazias()` definidos em `domain/questionario.ts` | Ficam junto das opções que tipam; usados pela F3-T04 e pela F3-T05 |
| F3-T01 | Teste de normalização NFC dos textos | A pontuação compara strings exatas; acentos decompostos nunca casariam com a API |
| F3-T02 | Logo como nome-base do arquivo | Os assets só entram na F4-T01 |
| F3-T02 | Checagem cruzada tabela × allowlist em `tests/scripts/streamings-allowlist.test.mjs` | Usa a allowlist (Node); o Node 24 importa `.ts` direto, sem tipos de Node no código do navegador |
| F3-T05 | Fábrica `criarQuestionario(obterArmazenamento)` + instância única `useQuestionario()` | Permite testar persistência, corrupção e bloqueio do storage sem tocar no `localStorage` real |
| F3-T05 | Valores salvos que não são opções válidas são descartados ao carregar | Dado antigo ou adulterado no navegador não pode gerar estado impossível |
| F4-T01 | `MovieMatch_Vert` reaproveitado nas boas-vindas; `MovieMatch_Hor` não copiado | O vertical era usado só na splash removida (A-04); o horizontal não é usado no Flutter |
| F4-T01 | Teste `tests/scripts/assets.test.mjs` | Garante as metas de tamanho e um logo para cada streaming da tabela |
| F4-T02 | `src/domain/nota.ts` (`4` → `"4.0"`) | Paridade com o `double.toString` do Dart |
| F4-T02 | Rótulos "Nota" e "Duração" como texto oculto, não `aria-label` em `<span>` | ARIA 1.2 proíbe nome acessível em elemento genérico |
| F4-T03 | `BaseButton` com prop `para` (vira link) | Navegação deve ser link, não botão |
| F4-T04 | `src/composables/useRecurso.ts` (commit próprio) | Ciclo de carga compartilhado: cancela ao sair, ignora respostas antigas, retry manual |
| F4-T04 | Correções vindas do teste em navegador (commit `fix`) | Texto oculto do cartão alargava a página; a navegação piscava antes da 1ª rota; o mosaico das boas-vindas (agora 3×2, no Flutter 2×3) escondia os botões |
| F4-T05 | `BotaoVoltar` usa o estado do histórico do router | Sem histórico no app (URL direta), vai ao início em vez de sair do site |
| F4-T05 | Slot `vazio` no `StateView` | Oferecer "Voltar ao início" no filme não encontrado |
| F4-T06 | Termo só com espaços não pesquisa | No Flutter viraria uma busca por " ", que traz quase todo o catálogo |
| F4-T07 | Título da aba com o nome do streaming | Diferencia as abas; slug desconhecido → 404 |
| F4-T08 | `ChipGroup` sobre `<input>` nativos (checkbox/radio) | Teclado e leitor de tela sem código extra |
| F4-T08 | Erro de validação como alerta abaixo dos botões (no Flutter, SnackBar) | Anunciado por `role="alert"`; não some sozinho |
| F4-T09 | Guard no router para `/sugestoes` | Sem as respostas mínimas, redireciona ao passo 1 antes de buscar o catálogo |
| F4-T09 | Tipo `RespostasLeitura` na regra de recomendação | A regra não altera as respostas; o estado do questionário é exposto como somente leitura |
| F4-T09 | "Refazer questionário" limpa as respostas | Paridade com `form.dart:789-791`; o "voltar" do navegador preserva as respostas |
| F5-T01 | Regex do Nginx exclui segmentos `.`/`..` | O teste de equivalência mostrou que `[^/]+` aceitava o que o verificador recusa |
| F5-T01 | Regex entre aspas na `location` (commit `fix`) | O `{1,2}` era lido como início de bloco pelo parser do Nginx; só apareceu ao subir a imagem real |
| F5-T02 | Mock em `tests/scripts/mock-api.test.mjs` (`node --test`), não `tests/unit/` | Usa `node:http` |
| F5-T02 | Cenário por requisição (cabeçalho `x-mock-cenario`) além do global | Testes em paralelo e E2E por estado sem interferência |
| F5-T03 | Configuração do Nginx em 4 arquivos: `default.conf.template`, `api-proxy.inc.template`, `cabecalhos.conf`, `allowlist.conf` | Separar o que é gerado, o que depende de variável e o que é repetido em cada `location` |
| F5-T03 | `05-verificar-ambiente.sh` no entrypoint | Sem `API_UPSTREAM`/`API_HOST` válidos, o container não sobe (mensagem clara) |
| F5-T03 | Imagem 91,9 MB (+0,84 MB sobre a base) | Meta corrigida: até +10 MB |
| F5-T04 | Perfil `smoke` | Prova da orquestração e da limpeza antes dos perfis completos |
| F5-T04 | Comparação dos recursos Docker externos antes/depois em todo perfil | Garante que nada fora dos testes muda |
| F5-T05 | Recusa de segmentos `.`/`..` (literais ou `%2e`) e `//` no caminho bruto de `/api` | O Nginx escolhe a rota pelo caminho normalizado, mas repassa o bruto: evita interpretações diferentes entre proxy e backend |
| F5-T05 | Serviço `front-sem-api` no perfil D | Testa API fora do ar (502 rápido, healthz e SPA no ar) |
| F5-T06 | Projetos `celular` (Pixel 7) e `desktop` (1280×800) | A rolagem horizontal da F4 só apareceu em tela estreita |
| F5-T06 | Fixture automática: CSP, erros de JS e rolagem horizontal | Cada E2E reprova se houver violação de CSP ou erro de JavaScript |
| F5-T06 | Lib DOM no `tsconfig.node.json` | Código executado no navegador via `page.evaluate` |
| F6-T02 | Execução exploratória antes do perfil definitivo (recursos temporários, removidos) | Descobrir o schema real criado pelo backend em vez de adivinhar nomes de tabelas |
| F6-T02 | Seed gerado por `scripts/seed-perfil-c.mjs` a partir das fixtures (não um `.sql` versionado) | Uma fonte de dados para todos os perfis; `utf8mb4` explícito (o primeiro seed manual gravou acentos corrompidos) |
| F6-T02 | `perfil.sh c` em etapas com `return` explícito | `set -e` é ignorado em funções chamadas com `||`: sem isso, o seed rodaria mesmo com o egresso reprovado |
| F6-T02 | Variáveis do banco com `:-` em vez de `:?` no Compose | O Compose interpola o arquivo inteiro: `:?` quebraria os outros perfis e a limpeza |
| F6-T03 | Testes de contrato em `tests/contrato/contrato.test.mjs` | Backend direto, sem proxy; 12 casos |
| F6-T04 | Ajuste A-07: duração nula aceita | Decisão do usuário após o perfil C; demais divergências só documentadas |
| F6-T05 | E2E do perfil C reaproveita `tests/e2e/b/navegacao` e `fluxos` (`--grep-invert @so-mock`) + `tests/e2e/c` | Os mesmos fluxos contra o backend real; o que depende do mock fica marcado |
| F6-T05 | Teste do filme com duração nula cobre a decisão A-07 | Pesquisa e detalhe mostram "não informada" contra o backend original |
| F7-R01..R06 | Responsividade ampliada (pedido do usuário em 23/10): 6 commits fora da lista original da F7 | Auditoria no navegador: estouro em `/pesquisa` a 375 px, navegação de celular no desktop, pôster distorcido no detalhe, alvos de toque pequenos |
| F7-R01 | Estouro de `/pesquisa` só aparece com emulação móvel (`isMobile`) | O Chromium móvel dá ao `input type="search"` largura mínima de 239 px; o projeto `desktop` não reproduzia. O E2E responsivo emula toque abaixo de 900 px |
| F7-R01 | `h1` visualmente oculto em `/pesquisa` | A página não tinha título; o E2E responsivo nem chegava a medir a rota |
| F7-R02 | `BottomNav` renomeado para `NavegacaoPrincipal` e movido para antes do `<main>` | A partir de 900 px é cabeçalho no topo; o nome antigo deixou de descrever o componente |
| F7-R04 | Links "Voltar ao início" viram `BaseButton` com `para` | Alvo de 45 px de altura; continuam sendo links |
| F7-R06 | Primeira rodada do E2E responsivo mal lida (12 "imagens distorcidas") | Eram linhas de código citadas no relatório do Playwright, não falhas; a linha de base correta é 29 de 60 falhando |
| F7-T01 | "Mock parado" por porta de controle (8082: `/__parar`, `/__retomar`), não por `docker stop` | O container do Playwright não tem acesso ao Docker. Fechar a porta de dados dá ao Nginx a mesma conexão recusada de uma API fora do ar e preserva o registro de requisições |
| F7-T01 | Perfil E com 1 worker e só o projeto `desktop` | `/__parar` derruba a API para todos os testes em andamento |
| F7-T01 | Teste de concorrência validado por mutação | Com o cache do catálogo desligado (TTL 0) o teste falha com 5 requisições em vez de 1 |
| F7-T02 | axe em 1280 e 375 px (54 casos) e correção do carrossel (`6ef21cb`) | A navegação muda de lugar conforme a largura; o carrossel sem links não era rolável pelo teclado (`scrollable-region-focusable`) |
| F7-T03 | Entregue como F7-R06 em `tests/e2e/b/responsivo.spec.ts`, não em `tests/e2e/e` | Feita antes, a pedido do usuário, com 6 larguras em vez de 3 e emulação de toque |
| F7-T04 | Imagens verificadas no perfil A (`assets.test.mjs`, já existente) e `/healthz` medido manualmente | O container do Playwright não vê `dist/` nem controla o ciclo de vida do front; números em `docs/metricas.md` |
| F7-T04 | Achado: Nginx sem compressão gzip | Meta cumprida mesmo assim (55 KB gzip; 124 KB transferidos). Ligar gzip fica como pendência |
| F7-T05 | Comandos do README executados como escritos, com a API simulada no lugar da produção | Sem autorização para acessar a produção. **Pendente:** a verificação por um terceiro, que só o usuário pode providenciar |
| F7-T06 | Registro: clone limpo de `c6961d4` (`--no-hardlinks`, em `$HOME`), perfis A (352 testes unitários e de componentes), B (108) e D verdes; `git status` vazio depois do `npm ci` (lockfile inalterado); clone removido | Em `$HOME` porque o Docker do snap não monta `/tmp` |
| F8-T01 | Registro: em `4c7c562`, perfis A (352 unitários/componentes + 148 de scripts), smoke, B (108), C (12 de contrato + 44 E2E, egresso reprovado como esperado), D (57) e E (61) verdes; 0 containers, redes e volumes de teste restantes; recursos preexistentes intactos | — |
| F8-T02 | Registro: fronteira ok; 68 commits, todos do autor autorizado, nenhum vazio, nenhum fora de `moviematch_front/`, todos com `Tarefa:`; 0 menções a coautoria/IA; nenhum segredo ou dado pessoal no conteúdo; `main` em `4c90b64` | — |
| F8-T03 | `docs/PUBLICACAO.md` com os pré-requisitos marcados como **não atendidos** (API de produção sem resposta em 22/10, contrato não validado na produção, fork inexistente) | O plano exige API respondendo e contrato validado antes do deploy |
