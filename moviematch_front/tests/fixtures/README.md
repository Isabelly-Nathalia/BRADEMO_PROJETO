# Fixtures de teste

**Sintéticas.** Títulos, pessoas e descrições são fictícios, e nenhum dado veio da API de produção nem do banco.

As imagens apontam para `img.exemplo.invalid`. O TLD `.invalid` é reservado (RFC 2606) e nunca resolve, então os testes não fazem acesso externo e exercitam o fallback de imagem.

As formas seguem o contrato **inferido** do backend (`docs/PLANO_IMPLEMENTACAO.md`, seção 5). Elas não provam compatibilidade com a API real, que depende da validação no perfil C ou em produção.

| Arquivo | Uso |
|---|---|
| `filmes-validos.json` | 13 filmes. Cobre durações nos limites (85, 90, 91, 120, 121, 180, 181, 185), todas as classificações, 10 países, os streamings com as grafias divergentes do Flutter (`Apple TV`/`AppleTV`, `Globoplay`/`GloboPlay`), `Disney+`, `Tela Brasil` e um "outro" (`Mubi`), títulos acentuados e notas iguais |
| `filmes-com-invalidos.json` | 16 itens: 5 válidos (um com todos os opcionais nulos, um com URLs inseguras) e 11 inválidos (id nulo, negativo ou fracionário; título vazio ou nulo; duração texto ou negativa; nota nula; gêneros como texto; item texto; item nulo) |
| `filmes-todos-invalidos.json` | só os 11 inválidos (erro sistêmico, não "vazio") |
| `filmes-vazio.json` | lista vazia (estado "vazio", não erro) |
| `filmes-repetidos.json` | `id_filme` 1 repetido |
| `objeto-na-raiz.json` | raiz objeto em vez de lista (erro sistêmico) |
| `publicidades.json` | 3 publicidades |
| `malformado.txt` | JSON truncado |
