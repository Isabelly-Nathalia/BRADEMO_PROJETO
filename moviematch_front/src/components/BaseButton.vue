<script setup lang="ts">
// Botão padrão do produto (equivale a projeto_brademo/lib/widgets/button.dart).
// Com `para`, renderiza um link com o mesmo visual: navegação é link, ação é botão.
import type { RouteLocationRaw } from 'vue-router'

withDefaults(
  defineProps<{ tipo?: 'button' | 'submit'; desabilitado?: boolean; para?: RouteLocationRaw }>(),
  { tipo: 'button', desabilitado: false, para: undefined },
)
</script>

<template>
  <RouterLink
    v-if="para"
    class="botao"
    :to="para"
  >
    <slot />
  </RouterLink>
  <button
    v-else
    class="botao"
    :type="tipo"
    :disabled="desabilitado"
  >
    <slot />
  </button>
</template>

<style scoped>
.botao {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  min-width: 180px;
  min-height: 45px;
  padding: 0 var(--espaco-5);
  border: none;
  border-radius: 25px;
  background: var(--cor-destaque);
  color: var(--cor-texto);
  font-size: 1rem;
  text-decoration: none;
  cursor: pointer;
}

.botao:hover:not(:disabled) {
  filter: brightness(1.15);
}

.botao:disabled {
  cursor: not-allowed;
  opacity: 0.6;
}
</style>
