<script setup lang="ts">
import { computed } from 'vue'
import { useRoute } from 'vue-router'
import BottomNav from './BottomNav.vue'

// Telas de fluxo próprio, sem navegação inferior (como no Flutter).
const ROTAS_SEM_NAVEGACAO = new Set(['boas-vindas', 'questionario'])

const rota = useRoute()
const comNavegacao = computed(() => !ROTAS_SEM_NAVEGACAO.has(String(rota.name)))
</script>

<template>
  <a
    class="pular visualmente-oculto"
    href="#conteudo"
  >Pular para o conteúdo</a>
  <main
    id="conteudo"
    class="conteudo"
    :class="{ 'com-navegacao': comNavegacao }"
    tabindex="-1"
  >
    <slot />
  </main>
  <BottomNav v-if="comNavegacao" />
</template>

<style scoped>
.conteudo {
  max-width: var(--largura-maxima);
  margin: 0 auto;
  outline: none;
}

.com-navegacao {
  padding-bottom: var(--altura-navegacao);
}

.pular:focus {
  position: fixed;
  top: var(--espaco-2);
  left: var(--espaco-2);
  z-index: 10;
  width: auto;
  height: auto;
  padding: var(--espaco-2) var(--espaco-4);
  margin: 0;
  clip: auto;
  background: var(--cor-destaque);
  color: var(--cor-texto);
}
</style>
