#!/usr/bin/env bash
# Executa npm/node/npx com o Node fixado, dentro de um container efêmero.
# Motivo: o host tem Node 20; o toolchain exige Node 24 (docs/ambiente.md).
# Monta somente moviematch_front/ em /w; os arquivos criados pertencem ao usuário do host.
#
# Uso: scripts/npm.sh <comando> [args...]   ex.: scripts/npm.sh npm ci
set -euo pipefail

# Digest registrado na F0-T05 (docs/ambiente.md).
readonly IMAGEM="node:24.22.1-alpine3.24@sha256:06d7adf3e0ef61a13f1d28682726366f97a15aa1888c934d3ecec86c33918b53"

if (( $# == 0 )); then
  printf 'uso: scripts/npm.sh <comando> [args...]\n' >&2
  exit 2
fi

front="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

tty=()
if [[ -t 0 && -t 1 ]]; then
  tty=(-it)
fi

exec docker run --rm --init "${tty[@]}" \
  --name "mmf-npm-$(date +%s)-$$" \
  --label br.moviematch.front.teste=npm \
  --user "$(id -u):$(id -g)" \
  -e HOME=/tmp \
  -e npm_config_cache=/w/.npm-cache \
  -e npm_config_update_notifier=false \
  -v "$front":/w \
  -w /w \
  "$IMAGEM" "$@"
