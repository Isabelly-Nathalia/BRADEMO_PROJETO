#!/usr/bin/env bash
# Gera os assets otimizados do frontend a partir das imagens do Flutter.
# Lê projeto_brademo/ SOMENTE para leitura; escreve em moviematch_front/src/assets e public/.
#
# Ferramenta usada na geração versionada: ImageMagick 6.9.12-98 Q16 (libwebp 1.3.2).
# Outra versão pode gerar bytes diferentes; os arquivos gerados são versionados.
#
# Tamanhos (2x o tamanho exibido no Flutter):
#   logos de streaming: 65x65 recortados em círculo → 130x130 (home.dart:391-417)
#   pôsteres das boas-vindas: largura ≤ 360 (inicial.dart:118-136)
#   logo vertical da marca: largura 760 (transicao.dart:50-52, exibido com 380)
set -euo pipefail

front="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
origem="$front/../projeto_brademo"
destino="$front/src/assets"

command -v convert >/dev/null || { printf 'ImageMagick (convert) não encontrado\n' >&2; exit 1; }
[[ -d "$origem/assets" ]] || { printf 'origem não encontrada: %s\n' "$origem/assets" >&2; exit 1; }

mkdir -p "$destino/streamings" "$destino/posteres" "$destino/marca" "$front/public/icons"

webp() { convert "$1" -strip "${@:3}" -quality 78 -define webp:method=6 "$2"; }

for logo in netflix hbomax disney appletv globoplay prime telaBrasil outros; do
  webp "$origem/assets/$logo.png" "$destino/streamings/$logo.webp" \
    -resize '130x130^' -gravity center -extent 130x130
done

for poster in filme1.png filme2.png filme3.png filme4.jpg filme5.jpg filme6.png; do
  webp "$origem/assets/$poster" "$destino/posteres/${poster%.*}.webp" -resize '360x>'
done

webp "$origem/assets/MovieMatch_Vert.png" "$destino/marca/moviematch-vertical.webp" -resize '760x>'

cp "$origem/web/favicon.png" "$front/public/favicon.png"
cp "$origem/web/icons/Icon-192.png" "$origem/web/icons/Icon-512.png" "$front/public/icons/"

printf 'assets gerados em %s\n' "$destino"
