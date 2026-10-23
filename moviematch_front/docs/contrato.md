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
- **`duracao_filme` pode ser nula**: CONFIRMADO, porque é `Integer`. Ver a decisão A-07 abaixo.

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

## 5. Decisão pendente

**A-07: filme com `duracao_filme` nula.** O banco aceita. Pela A-01, o front descarta o filme. Quando ele é o **único** item de uma resposta (por exemplo, uma pesquisa), a regra "lista não vazia sem itens válidos = erro sistêmico" mostra "Os dados recebidos estão em um formato inesperado" em vez de "Filme não localizado". No Flutter, o mesmo filme faria a lista inteira falhar (cast de `null` para `int`).

Alternativas:
- (a) aceitar duração nula como "não informada": o filme aparece e não pontua por duração;
- (b) manter o descarte, mas tratar "todos descartados" como vazio quando a resposta for pequena;
- (c) manter como está.

O comportamento atual (c) está documentado em `tests/e2e/c/backend-real.spec.ts`.

## 6. O que continua não verificado

- A produção (Render + Aiven): disponibilidade, collation, volume e tamanho real de `GET /filmes` (o limite de 5 MB do cliente segue como HIPÓTESE), e dados reais (nulos, grafias de streaming).
- Comportamento sob carga e com o cold start do Render.
