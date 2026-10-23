<script setup lang="ts">
// Botão padrão do produto (equivale a projeto_brademo/lib/widgets/button.dart).
withDefaults(defineProps<{ tipo?: 'button' | 'submit'; desabilitado?: boolean }>(), {
  tipo: 'button',
  desabilitado: false,
})
</script>

<template>
  <button
    class="botao"
    :type="tipo"
    :disabled="desabilitado"
  >
    <slot />
  </button>
</template>

<style scoped>
.botao {
  min-width: 180px;
  min-height: 45px;
  padding: 0 var(--espaco-5);
  border: none;
  border-radius: 25px;
  background: var(--cor-destaque);
  color: var(--cor-texto);
  font-size: 1rem;
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
