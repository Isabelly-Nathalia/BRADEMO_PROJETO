# Contrato da API legada: validação no perfil C

| Campo | Valor |
|---|---|
| Data | 2026-10-23 |
| Backend | `moviematch-back:baseline` (`sha256:b71433b2…`), construído em 2026-10-03 a partir de `4c90b64` com o `Dockerfile` da raiz **sem alterações**; Java 21.0.12.1 |
| Banco | `mysql:8.4.13` descartável (tmpfs), rede `internal`, credenciais aleatórias por execução |
| Dados | Sintéticos: `scripts/seed-perfil-c.mjs` (as 13 fixtures + 1 filme com nulos + 3 publicidades) |
| Testes | `tests/contrato/contrato.test.mjs` (12, backend direto) · `tests/e2e/b` + `tests/e2e/c` (44 execuções, pelo front) |
| Execução | `scripts/perfil.sh c` |

Classificação: **CONFIRMADO_EM_EXECUCAO** significa observado no backend original com MySQL 8.4 padrão. **Não** significa que a produção (Render + Aiven) se comporta igual: ela continua sem verificação (seção 4).

## 1. Isolamento (verificado em toda execução, antes do seed)

| Controle | Resultado |
|---|---|
| DNS de `moviematch-db-moviematch-db.k.aivencloud.com` a partir do namespace do backend | falha (`EAI_AGAIN`) |
| TCP para o Aiven (porta 22246), `1.1.1.1:443` e `8.8.8.8:53` | falha (timeout / `ENETUNREACH`) |
| TCP para o MySQL local | conecta |
| Conexões do usuário `mm` no MySQL local vindas do IP do backend | 10 (pool do Hikari) |
| Menções a `aivencloud` no log do backend | 0 |

O backend sobe **só com variáveis de ambiente** (`SPRING_DATASOURCE_URL`, `_USERNAME`, `_PASSWORD`, `DB_PASSWORD`, `PORT`), sem rebuild nem alteração de arquivos, em cerca de 4 s.

## 2. Schema criado pelo backend (`ddl-auto=update`)

| Tabela | Colunas (nulável = ?) |
|---|---|
| `filme` | `id_filme bigint`, `titulo_filme varchar(255)?`, `descricao_filme varchar(255)?`, `imagem_diretor_filme varchar(255)?`, **`duracao_filme int?`**, `streaming_filme varchar(255)?`, `nacionalidade_filme varchar(255)?`, `classificacao_filme varchar(255)?`, `diretor_filme varchar(255)?`, `link_imagem_filme_filme varchar(255)?`, `ator_especifico_filme varchar(255)?`, **`nota_filme double` (NOT NULL)** |
| `filme_generos` | `filme_id_filme bigint`, `generos varchar(255)?` |
| `publicidade` | `id_publicidade bigint`, `descricao varchar(255)?`, `link_imagem varchar(255)?` |
| `usuario`, `lista`, `lista_filmes`, `usuario_filmes_curtidos` | existem, mas não são usadas nem semeadas pelo front |

Hipóteses do plano resolvidas:
- **Todo texto é `VARCHAR(255)`**: CONFIRMADO. Uma foto de perfil em base64 não caberia.
- **`nota_filme` nunca é nula**: CONFIRMADO, porque é `double` primitivo.
- **`duracao_filme` pode ser nula**: CONFIRMADO, porque é `Integer`. Ver a decisão A-07 abaixo (seção 5).

## 3. Respostas (CONFIRMADO_EM_EXECUCAO)

| Rota | Resultado |
|---|---|
| `GET /filmes` | 200, `application/json`, lista com **exatamente** os 13 campos do contrato inferido; textos nulos como `null`; `generos` sempre lista (`[]` quando vazia); nota inteira serializada como `4` |
| `GET /filmes/aleatorios` | 200, 5 filmes do catálogo |
| `GET /filmes/{id}` | **404**, JSON do Spring `{timestamp, status: 404, error: "Not Found", path}` (a rota não existe) |
| `GET /filmes/streaming/{s}` | `Disney%2B` e `Disney+` literal chegam como `Disney+` |
| `GET /filmes/pesquisa/a%2Fb` | **400**, HTML do Tomcat (o proxy do front bloqueia antes) |
| `GET /publicidades` | 200, 3 campos; `link_imagem` pode ser `null` |
| CORS | **nenhum** `Access-Control-Allow-Origin`, nem no preflight `OPTIONS` (200 sem headers CORS). Um navegador em outra origem seria bloqueado; o proxy de mesma origem é obrigatório |

## 4. Divergências em relação ao mock e ao Flutter

O MySQL 8.4 usa por padrão a collation `utf8mb4_0900_ai_ci`, que **ignora maiúsculas e acentos** nas comparações. Com ela:

| Consulta | Backend real (MySQL padrão) | Mock do perfil B (comparação exata) |
|---|---|---|
| `/filmes/streaming/GloboPlay` | "Sombras do Vale" (`Globoplay`) **e** "Canção do Mar" (`GloboPlay`) | só "Canção do Mar" |
| `/filmes/streaming/netflix` | os 3 da Netflix | nenhum |
| `/filmes/streaming/outros` | "Pequenos Heróis" (`AppleTV`) e "Dragão de Jade" (`Mubi`). `GloboPlay` cai fora (igual a `Globoplay`); streaming `NULL` também fica de fora (lógica de três valores do `NOT IN`) | inclui "Canção do Mar" |
| `/filmes/pesquisa/acao` | encontra "Coração em Seul" e "Ação e Reação" | nada |

**Consequências para A-05 (grafias do Flutter):**
- `GloboPlay` × `Globoplay`: **não é problema** no MySQL padrão, porque a comparação ignora maiúsculas.
- `AppleTV` × `Apple TV`: **é problema**. A diferença é um espaço, que a collation não ignora: filmes gravados como `AppleTV` caem em "Outros" e não aparecem na página "Apple TV".
- **A collation do Aiven (produção) não foi verificada.** Se for binária ou sensível a maiúsculas, o comportamento é o do mock.

## 5. Decisão tomada

**A-07: filme com `duracao_filme` nula (decidido em 2026-10-23: opção "aceitar como não informada").** O banco aceita duração nula. O front mostra o filme normalmente, com a duração "não informada", e esse filme não pontua por duração nas sugestões. Duração em texto, fracionária ou negativa continua invalidando o filme (A-01).

O comportamento anterior era descartar o filme. Quando ele era o único resultado de uma pesquisa, a interface mostrava erro de formato. No Flutter, o mesmo filme faria a lista inteira falhar.

Coberto em `tests/unit/mapeadores.test.ts`, `duracao.test.ts`, `recomendacao.test.ts`, `tests/components/MovieCard.test.ts` e `tests/e2e/c/backend-real.spec.ts` (contra o backend original).

## 6. O que continua não verificado

- A produção (Render + Aiven): disponibilidade, collation, volume e tamanho real de `GET /filmes` (o limite de 5 MB do cliente segue como HIPÓTESE), e dados reais (nulos, grafias de streaming).
- Comportamento sob carga e com o cold start do Render.

## 7. Tentativa de validação na produção (2026-10-23, autorizada)

Autorização do usuário: **somente `GET`** nas rotas da allowlist, sem escrita, push, PR ou deploy. Três requisições, todas sem resposta:

| Horário (UTC) | Rota | Resultado |
|---|---|---|
| 22:10:19 | `GET /publicidades` | timeout de 120 s, 0 bytes recebidos |
| 22:12:27 | `GET /publicidades` | timeout de 90 s; DNS 0,05 s, TCP 0,06 s, TLS 1.3 + HTTP/2 em 0,10 s; pedido enviado, nenhum byte de resposta |
| 22:14:07 | `GET /filmes` | timeout de 90 s; TLS em 0,26 s, nenhum byte de resposta |

**Conclusão:** a borda do Render aceita a conexão, mas o serviço não responde, nas duas rotas, com até 120 s de espera (cold start normal do plano gratuito leva menos de um minuto). O mesmo aconteceu em 22/10. A causa não pode ser vista de fora: o serviço pode estar falhando ao iniciar (por exemplo, sem conseguir conectar ao banco do Aiven), parado ou sem recursos. Diagnosticar exige acesso ao painel e aos logs do Render, fora da autorização concedida.

**O contrato continua não validado na produção.** Os itens da seção 6 seguem em aberto, e o deploy do front continua bloqueado (ver [PUBLICACAO.md](PUBLICACAO.md)).
