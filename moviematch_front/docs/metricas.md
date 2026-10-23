# Métricas de desempenho (F7-T04)

| Campo | Valor |
|---|---|
| Data | 2026-10-23 |
| Commit medido | branch `front-vue`, depois de `e3dab01` |
| Onde | imagem de produção `moviematch-front:teste` (Nginx), API simulada, rede interna do perfil E |
| Navegador | Chromium do Playwright 1.64.1, 1280×800, **sem** throttle de CPU ou rede |
| Como repetir | `scripts/perfil.sh e` (os números saem no relatório como `js-inicial` e `lcp-inicio`) |

As metas foram definidas no plano **antes** da medição.

## Resultados

| Métrica | Meta | Medido | Onde é verificada |
|---|---|---|---|
| JS para abrir `/inicio` | ≤ 150 KB gzip | **55,0 KB** gzip (6 arquivos; 123,7 KB sem compressão) | `tests/e2e/e/desempenho.spec.ts` |
| Imagens do app (`src/assets`) | ≤ 1,5 MB | **194 KB** | `tests/scripts/assets.test.mjs` (perfil A) |
| LCP de `/inicio` | ≤ 2,5 s | **76 / 96 / 112 ms** (3 navegações frias) | `tests/e2e/e/desempenho.spec.ts` |
| Tempo até `/healthz` = 200 depois do `docker run` | ≤ 5 s | **353 a 367 ms** (3 containers novos) | medição manual (abaixo) |
| Reinício (`docker restart`) até `/healthz` = 200 | informativo | 376 ms | medição manual |

O tempo até `/healthz` inclui cerca de 95 ms do próprio `docker exec` usado para consultar. A medição foi feita com containers temporários com a label de teste, sem rede (`--network none`), removidos em seguida.

**Partida fria × quente:** sem diferença mensurável (353 a 376 ms). A imagem já estava no cache local nas duas situações. Uma partida realmente fria em outro servidor inclui o download da imagem (cerca de 91 MB, ver `docs/ambiente.md`), que não foi medido.

## Limites destas medições

- **O LCP medido é de texto, não de imagem.** O mock devolve URLs de imagem sem https, que o app troca pelo marcador. Com a API real, o LCP de `/inicio` tende a ser um pôster ou a publicidade, e depende do servidor de imagens e da latência da API, incluindo o cold start do Render. Isso não foi medido.
- **Sem throttle.** Em celular com CPU lenta e rede móvel os números serão maiores. A meta de 2,5 s vale para as condições acima.
- **O Nginx não comprime as respostas** (`content-encoding` ausente nos 6 scripts): o navegador baixa 123,7 KB em vez de 55 KB. A meta é medida em gzip, como no plano, e é cumprida mesmo sem compressão. Ligar `gzip` para JS, CSS e JSON é uma melhoria simples, registrada como pendência.
