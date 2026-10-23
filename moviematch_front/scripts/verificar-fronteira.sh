#!/usr/bin/env bash
# Verifica que toda alteração do trabalho está dentro de moviematch_front/.
# Fontes: commits desde a base registrada, staged, unstaged e não rastreados.
# Somente leitura: não altera índice, refs, configuração nem árvore de trabalho.
#
# Saída: 0 = ok · 1 = caminho fora da fronteira · 2 = base inválida
set -euo pipefail

# Impede que o git atualize o índice de forma oportunista durante diff/status.
export GIT_OPTIONAL_LOCKS=0

readonly PREFIXO="moviematch_front/"

raiz="$(git rev-parse --show-toplevel)"
cd "$raiz"

readonly ARQUIVO_BASE="${PREFIXO}.fronteira-base"
if [[ ! -f "$ARQUIVO_BASE" ]]; then
  printf 'base ausente: %s\n' "$ARQUIVO_BASE" >&2
  exit 2
fi

base="$(tr -d '[:space:]' < "$ARQUIVO_BASE")"
if [[ ! "$base" =~ ^[0-9a-f]{40}$ ]]; then
  printf 'base com formato inválido: %s\n' "$base" >&2
  exit 2
fi
if ! git cat-file -e "${base}^{commit}" 2>/dev/null; then
  printf 'base inexistente no repositório: %s\n' "$base" >&2
  exit 2
fi
if ! git merge-base --is-ancestor "$base" HEAD; then
  printf 'base não é ancestral de HEAD: %s\n' "$base" >&2
  exit 2
fi

violacoes=0

# --no-renames: um rename de fora para dentro aparece como deleção + adição,
# então a deleção do caminho externo também é detectada.
verificar() {
  local origem="$1"
  shift
  local caminho
  while IFS= read -r -d '' caminho; do
    if [[ "$caminho" != "$PREFIXO"* ]]; then
      printf '%s: %s\n' "$origem" "$caminho" >&2
      violacoes=$((violacoes + 1))
    fi
  done < <("$@")
}

verificar commits       git diff -z --no-renames --name-only "$base" HEAD
verificar staged        git diff -z --no-renames --name-only --cached
verificar unstaged      git diff -z --no-renames --name-only
verificar nao-rastreado git ls-files -z --others --exclude-standard

if (( violacoes > 0 )); then
  printf 'fronteira violada: %d caminho(s) fora de %s\n' "$violacoes" "$PREFIXO" >&2
  exit 1
fi

printf 'fronteira ok (base %s)\n' "${base:0:12}"
