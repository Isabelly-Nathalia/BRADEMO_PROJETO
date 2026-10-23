#!/bin/sh
# Executado pelo entrypoint da imagem antes do envsubst: falha cedo e com mensagem clara
# em vez de subir com um proxy quebrado.
set -eu

erro() {
  echo "moviematch: $1" >&2
  exit 1
}

[ -n "${API_UPSTREAM:-}" ] || erro "defina API_UPSTREAM (ex.: https://moviematch-apkx.onrender.com)"
[ -n "${API_HOST:-}" ] || erro "defina API_HOST (ex.: moviematch-apkx.onrender.com)"
case "$API_UPSTREAM" in
  http://* | https://*) ;;
  *) erro "API_UPSTREAM deve começar com http:// ou https://" ;;
esac
case "$API_UPSTREAM" in
  */) erro "API_UPSTREAM não deve terminar com /" ;;
esac
case "${PORT:-}" in
  '' | *[!0-9]*) erro "PORT deve ser numérica" ;;
esac
