#!/usr/bin/env bash
# Testes de scripts/verificar-fronteira.sh.
# Cada caso roda num repositório git temporário (mktemp -d), fora do projeto.
# Ao final, confere que o repositório real não mudou.
set -euo pipefail

aqui="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly SCRIPT="$aqui/../../scripts/verificar-fronteira.sh"
repo_real="$(git -C "$aqui" rev-parse --show-toplevel)"

estado_real() {
  GIT_OPTIONAL_LOCKS=0 git -C "$repo_real" rev-parse HEAD
  GIT_OPTIONAL_LOCKS=0 git -C "$repo_real" status --porcelain --untracked-files=all
}
readonly ANTES="$(estado_real)"

temporarios=()
limpar() { local d; for d in "${temporarios[@]}"; do rm -rf "$d"; done; }
trap limpar EXIT

# Identidade só nos commits sintéticos; nenhuma configuração é gravada.
git_t() { git -c user.name=teste -c user.email=teste@exemplo.invalid -c commit.gpgsign=false "$@"; }

# Cria repositório com base registrada; imprime o caminho.
novo_repo() {
  local d
  d="$(mktemp -d)"
  temporarios+=("$d")
  git_t -C "$d" init -q
  mkdir -p "$d/moviematch_front/scripts" "$d/backend"
  echo "original" > "$d/backend/app.txt"
  git_t -C "$d" add -A
  git_t -C "$d" commit -q -m base
  git -C "$d" rev-parse HEAD > "$d/moviematch_front/.fronteira-base"
  cp "$SCRIPT" "$d/moviematch_front/scripts/verificar-fronteira.sh"
  git_t -C "$d" add moviematch_front
  git_t -C "$d" commit -q -m "front: base e script"
  printf '%s' "$d"
}

falhas=0
caso() {
  local nome="$1" esperado="$2" trecho="$3" dir="$4"
  local saida codigo=0
  saida="$(cd "$dir" && bash moviematch_front/scripts/verificar-fronteira.sh 2>&1)" || codigo=$?
  if [[ "$codigo" -ne "$esperado" ]] || [[ -n "$trecho" && "$saida" != *"$trecho"* ]]; then
    printf 'FALHOU  %s (esperado %s, obtido %s)\n%s\n' "$nome" "$esperado" "$codigo" "$saida"
    falhas=$((falhas + 1))
  else
    printf 'ok      %s\n' "$nome"
  fi
}

r="$(novo_repo)"
caso "limpo" 0 "fronteira ok" "$r"

r="$(novo_repo)"
echo "x" > "$r/moviematch_front/novo.txt"
git_t -C "$r" add moviematch_front/novo.txt && git_t -C "$r" commit -q -m ok
caso "commit dentro da fronteira" 0 "fronteira ok" "$r"

r="$(novo_repo)"
echo "mudou" > "$r/backend/app.txt"
git_t -C "$r" commit -q -am fora
caso "commit fora" 1 "commits: backend/app.txt" "$r"

r="$(novo_repo)"
echo "mudou" > "$r/backend/app.txt"
git_t -C "$r" add backend/app.txt
caso "staged fora" 1 "staged: backend/app.txt" "$r"

r="$(novo_repo)"
echo "mudou" > "$r/backend/app.txt"
caso "unstaged fora" 1 "unstaged: backend/app.txt" "$r"

r="$(novo_repo)"
echo "x" > "$r/raiz-nova.txt"
caso "não rastreado fora" 1 "nao-rastreado: raiz-nova.txt" "$r"

r="$(novo_repo)"
echo "x" > "$r/nome com espaço.txt"
caso "nome com espaço fora" 1 "nao-rastreado: nome com espaço.txt" "$r"

r="$(novo_repo)"
git_t -C "$r" mv backend/app.txt moviematch_front/app.txt
git_t -C "$r" commit -q -m rename
caso "rename de fora para dentro" 1 "commits: backend/app.txt" "$r"

r="$(novo_repo)"
echo "0000000000000000000000000000000000000000" > "$r/moviematch_front/.fronteira-base"
caso "base inexistente" 2 "base inexistente" "$r"

r="$(novo_repo)"
arvore_vazia="$(git -C "$r" hash-object -t tree -w /dev/null)"
git_t -C "$r" commit-tree "$arvore_vazia" -m solto > "$r/moviematch_front/.fronteira-base"
caso "base não ancestral" 2 "não é ancestral" "$r"

r="$(novo_repo)"
echo "abc" > "$r/moviematch_front/.fronteira-base"
caso "base com formato inválido" 2 "formato inválido" "$r"

r="$(novo_repo)"
rm "$r/moviematch_front/.fronteira-base"
caso "base ausente" 2 "base ausente" "$r"

r="$(novo_repo)"
antes_idx="$(sha256sum "$r/.git/index")"
echo "mudou" > "$r/backend/app.txt"
(cd "$r" && bash moviematch_front/scripts/verificar-fronteira.sh >/dev/null 2>&1) || true
depois_idx="$(sha256sum "$r/.git/index")"
if [[ "$antes_idx" == "$depois_idx" ]]; then
  printf 'ok      %s\n' "índice não é reescrito"
else
  printf 'FALHOU  %s\n' "índice não é reescrito"
  falhas=$((falhas + 1))
fi

if [[ "$(estado_real)" == "$ANTES" ]]; then
  printf 'ok      %s\n' "repositório real inalterado"
else
  printf 'FALHOU  %s\n' "repositório real inalterado"
  falhas=$((falhas + 1))
fi

if (( falhas > 0 )); then
  printf '%d falha(s)\n' "$falhas"
  exit 1
fi
printf 'todos os casos passaram\n'
