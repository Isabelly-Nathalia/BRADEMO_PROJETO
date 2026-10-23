<script setup lang="ts">
import { computed } from 'vue'
import { useRoute } from 'vue-router'
import NavegacaoPrincipal from './NavegacaoPrincipal.vue'

// Telas de fluxo próprio, sem navegação principal (como no Flutter).
const ROTAS_SEM_NAVEGACAO = new Set(['boas-vindas', 'questionario'])

const rota = useRoute()
// Antes da primeira rota ser resolvida (matched vazio), a navegação fica oculta: evita piscar
// nas telas que não a exibem.
const comNavegacao = computed(() => rota.matched.length > 0 && !ROTAS_SEM_NAVEGACAO.has(String(rota.name)))
</script>

<template>
  <a
    class="pular visualmente-oculto"
    href="#conteudo"
  >Pular para o conteúdo</a>
  <NavegacaoPrincipal v-if="comNavegacao" />
  <main
    id="conteudo"
    class="conteudo"
    :class="{ 'com-navegacao': comNavegacao }"
    tabindex="-1"
  >
    <slot />
  </main>
</template>

<style scoped>
.conteudo {
  max-width: var(--largura-maxima);
  margin: 0 auto;
  outline: none;
}

/* Abaixo de 900 px a navegação é fixa no rodapé: reserva o espaço dela no fim da página. */
@media (max-width: 899.98px) {
  .com-navegacao {
    padding-bottom: var(--altura-navegacao);
  }
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
