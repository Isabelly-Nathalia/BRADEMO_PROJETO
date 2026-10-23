#!/usr/bin/env bash
# Executa um perfil de teste do frontend (docs/PLANO_IMPLEMENTACAO.md, seção 7).
#
#   scripts/perfil.sh a    testes rápidos: npm ci, lint, typecheck, unitários,
#                          regras de lint, build e testes dos scripts
#
# Os perfis b, c, d e e são adicionados nas tarefas F5-T04 em diante.
set -euo pipefail

front="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

perfil_a() {
  local inicio=$SECONDS
  "$front/scripts/npm.sh" sh -c 'npm ci --no-audit --no-fund && npm run verificar'
  bash "$front/tests/scripts/verificar-fronteira.test.sh"
  printf 'perfil A ok em %ds\n' "$((SECONDS - inicio))"
}

case "${1:-}" in
  a) perfil_a ;;
  *)
    printf 'uso: scripts/perfil.sh a\n' >&2
    exit 2
    ;;
esac
