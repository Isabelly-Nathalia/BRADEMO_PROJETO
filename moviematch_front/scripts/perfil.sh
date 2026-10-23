#!/usr/bin/env bash
# Executa um perfil de teste do frontend (docs/PLANO_IMPLEMENTACAO.md, seção 7).
#
#   scripts/perfil.sh a              testes rápidos (sem pilha): npm ci, check da allowlist, lint,
#                                    typecheck, unitários, regras de lint, scripts e build
#   scripts/perfil.sh smoke          pilha mínima (front + mock) sobe, conversa e é removida
#   scripts/perfil.sh b              E2E com Playwright contra a imagem de produção e o mock
#                                    (MMF_E2E_ARGS repassa opções, ex.: --repeat-each=3)
#   scripts/perfil.sh c              backend ORIGINAL + MySQL descartável (autorizado na F6-T01):
#                                    egresso → evidências → seed → contrato → E2E
#   scripts/perfil.sh d              proxy e segurança (tests/proxy)
#   scripts/perfil.sh limpar <id>    remove só os recursos de uma execução interrompida
#
# Perfis com containers: projeto Compose e label únicos por execução, rede `internal`, nenhuma
# porta publicada, espera por healthcheck e limpeza no fim (inclusive em erro ou Ctrl+C).
# Nunca usa `docker system prune` nem toca em recursos sem a label da execução.
set -euo pipefail

front="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
readonly COMPOSE="$front/docker/compose.yml"
readonly LABEL=br.moviematch.front.teste

perfil_a() {
  local inicio=$SECONDS
  "$front/scripts/npm.sh" sh -c 'npm ci --no-audit --no-fund && npm run verificar'
  bash "$front/tests/scripts/verificar-fronteira.test.sh"
  printf 'perfil A ok em %ds\n' "$((SECONDS - inicio))"
}

# Recursos Docker sem a label de teste: precisam estar idênticos antes e depois.
estado_externo() {
  {
    docker ps -a --format '{{.ID}} {{.Names}} {{.Label "'"$LABEL"'"}}' | awk '$3 == ""'
    docker network ls --format '{{.ID}} {{.Name}} {{.Label "'"$LABEL"'"}}' | awk '$3 == ""'
    docker volume ls --format '{{.Name}} {{.Label "'"$LABEL"'"}}' | awk '$2 == ""'
  } | sort
}

restantes() {
  local id="$1"
  {
    docker ps -aq --filter "label=$LABEL=$id"
    docker network ls -q --filter "label=$LABEL=$id"
    docker volume ls -q --filter "label=$LABEL=$id"
  } | wc -l
}

limpar() {
  local id="$1"
  MMF_RUN_ID="$id" docker compose -f "$COMPOSE" -p "$id" --profile '*' down -v --remove-orphans --timeout 5 >/dev/null 2>&1 || true
  local sobra
  sobra="$(restantes "$id")"
  if [[ "$sobra" -ne 0 ]]; then
    printf 'ATENÇÃO: %s recurso(s) com %s=%s não foram removidos\n' "$sobra" "$LABEL" "$id" >&2
    printf 'Se o Docker negar parar containers (snap/AppArmor), rode: sudo snap restart docker\n' >&2
    return 1
  fi
  printf 'limpeza ok (%s)\n' "$id"
}

perfil_compose() {
  local perfil="$1" servico="$2"
  local id
  id="mmf-${perfil}-$(date -u +%Y%m%dt%H%M%S)-${RANDOM}"
  local inicio=$SECONDS
  local antes
  antes="$(estado_externo)"

  printf 'construindo moviematch-front:teste…\n'
  docker build -q -f "$front/docker/Dockerfile" -t moviematch-front:teste --label "$LABEL=imagem" "$front" >/dev/null

  # A limpeza roda em qualquer saída e preserva o código de saída dos testes.
  # Arquivos gerados pelos testes (test-results/) ficam com o usuário do host.
  export MMF_UID MMF_GID
  MMF_UID="$(id -u)"
  MMF_GID="$(id -g)"

  local codigo=0
  trap 'limpar "'"$id"'" || codigo=1' EXIT
  printf 'subindo %s…\n' "$id"
  MMF_RUN_ID="$id" docker compose -f "$COMPOSE" -p "$id" --profile "$perfil" up \
    --quiet-pull --no-color --exit-code-from "$servico" --attach "$servico" || codigo=$?

  trap - EXIT
  limpar "$id" || codigo=1
  if [[ "$(estado_externo)" != "$antes" ]]; then
    printf 'ATENÇÃO: recursos Docker de fora dos testes mudaram durante a execução\n' >&2
    codigo=1
  fi
  if [[ "$codigo" -eq 0 ]]; then
    printf 'perfil %s ok em %ds\n' "$perfil" "$((SECONDS - inicio))"
  else
    printf 'perfil %s FALHOU (código %s) em %ds\n' "$perfil" "$codigo" "$((SECONDS - inicio))" >&2
  fi
  return "$codigo"
}

segredo() {
  head -c 32 /dev/urandom | base64 | tr -dc 'A-Za-z0-9' | head -c 24
}

etapas_c() {
  local id="$1"
  local -a dc=(docker compose -f "$COMPOSE" -p "$id" --profile c)

  printf '1/6 subindo MySQL descartável e backend original…\n'
  "${dc[@]}" up -d --wait --quiet-pull mysql backend >/dev/null || return 1

  printf '2/6 controle de egresso no namespace do backend (antes de qualquer dado)…\n'
  "${dc[@]}" run --rm --no-deps egresso || { printf 'egresso REPROVADO: seed e testes não serão executados\n' >&2; return 1; }

  printf '3/6 evidências de conexão local…\n'
  local ip_backend menciona_aiven conexoes
  ip_backend="$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' "$("${dc[@]}" ps -q backend)")" || return 1
  menciona_aiven="$("${dc[@]}" logs backend 2>&1 | grep -ci aivencloud || true)"
  conexoes="$("${dc[@]}" exec -T -e MYSQL_PWD="$MMF_DB_SENHA" mysql mysql -u mm -N -e \
    "SELECT COUNT(*) FROM information_schema.processlist WHERE user='mm' AND db='moviematch' AND host LIKE '${ip_backend}:%'")" || return 1
  printf '    backend %s: %s conexões no MySQL local; menções a aivencloud no log: %s\n' "$ip_backend" "$conexoes" "$menciona_aiven"
  if [[ "$conexoes" -lt 1 || "$menciona_aiven" -ne 0 ]]; then
    printf 'evidência de conexão local REPROVADA\n' >&2
    return 1
  fi

  printf '4/6 seed sintético…\n'
  "$front/scripts/npm.sh" node scripts/seed-perfil-c.mjs |
    "${dc[@]}" exec -T -e MYSQL_PWD="$MMF_DB_SENHA" mysql mysql --default-character-set=utf8mb4 -u mm moviematch || return 1

  printf '5/6 contrato contra o backend original…\n'
  "${dc[@]}" run --rm --no-deps contrato || return 1

  printf '6/6 E2E pelo front contra o backend original…\n'
  "${dc[@]}" up -d --wait --no-deps front-c >/dev/null || return 1
  "${dc[@]}" run --rm --no-deps e2e-c || return 1
}

# Perfil C: sequência em etapas; qualquer falha interrompe antes da etapa seguinte.
perfil_c() {
  local id
  id="mmf-c-$(date -u +%Y%m%dt%H%M%S)-${RANDOM}"
  local inicio=$SECONDS
  local antes
  antes="$(estado_externo)"
  printf 'construindo moviematch-front:teste…\n'
  docker build -q -f "$front/docker/Dockerfile" -t moviematch-front:teste --label "$LABEL=imagem" "$front" >/dev/null

  export MMF_RUN_ID="$id" MMF_UID MMF_GID MMF_DB_SENHA MMF_DB_SENHA_ROOT
  MMF_UID="$(id -u)"
  MMF_GID="$(id -g)"
  MMF_DB_SENHA="$(segredo)"
  MMF_DB_SENHA_ROOT="$(segredo)"

  local codigo=0
  trap 'limpar "'"$id"'" || true' EXIT
  # Sem `set -e` aqui (o bash o ignora em funções chamadas com ||): cada etapa falha explicitamente,
  # para que nada (em especial o seed) rode depois de um controle reprovado.
  etapas_c "$id" || codigo=$?

  trap - EXIT
  limpar "$id" || codigo=1
  if [[ "$(estado_externo)" != "$antes" ]]; then
    printf 'ATENÇÃO: recursos Docker de fora dos testes mudaram durante a execução\n' >&2
    codigo=1
  fi
  if [[ "$codigo" -eq 0 ]]; then
    printf 'perfil c ok em %ds\n' "$((SECONDS - inicio))"
  else
    printf 'perfil c FALHOU (código %s) em %ds\n' "$codigo" "$((SECONDS - inicio))" >&2
  fi
  return "$codigo"
}

case "${1:-}" in
  a) perfil_a ;;
  smoke) perfil_compose smoke smoke ;;
  b) perfil_compose b e2e ;;
  c) perfil_c ;;
  d)
    # Os testes não rodam no perfil A: dependem da pilha. Lint/sintaxe são cobertos pelo ESLint.
    perfil_compose d sonda
    ;;
  limpar)
    [[ -n "${2:-}" ]] || { printf 'uso: scripts/perfil.sh limpar <id-da-execucao>\n' >&2; exit 2; }
    limpar "$2"
    ;;
  *)
    printf 'uso: scripts/perfil.sh a|smoke|b|c|d|limpar <id>\n' >&2
    exit 2
    ;;
esac
