<script setup lang="ts">
// Imagem cuja URL vem da API. Só exibe URLs https; qualquer outra coisa
// (http, javascript:, data:, relativa, vazia) ou falha de carga vira um marcador neutro.
// Imagens locais do projeto usam <img> comum, não este componente.
import { computed, ref, watch } from 'vue'

const props = defineProps<{ src: string | null | undefined; alt: string }>()

const falhou = ref(false)
watch(
  () => props.src,
  () => {
    falhou.value = false
  },
)

const urlSegura = computed(() => {
  if (!props.src) return null
  try {
    const url = new URL(props.src)
    return url.protocol === 'https:' ? url.href : null
  } catch {
    return null
  }
})

const exibirImagem = computed(() => urlSegura.value !== null && !falhou.value)
</script>

<template>
  <img
    v-if="exibirImagem"
    class="imagem"
    :src="urlSegura!"
    :alt="alt"
    loading="lazy"
    decoding="async"
    referrerpolicy="no-referrer"
    @error="falhou = true"
  >
  <div
    v-else
    class="imagem marcador"
    role="img"
    :aria-label="alt"
  >
    <svg
      aria-hidden="true"
      viewBox="0 0 24 24"
      width="32"
      height="32"
    >
      <path
        d="M4 5h16v14H4zm2 2v10h12V7zm2 8 2.5-3 2 2.5 1.5-2 2 2.5z"
        fill="currentColor"
      />
    </svg>
  </div>
</template>

<style scoped>
.imagem {
  width: 100%;
  height: 100%;
  object-fit: cover;
}

.marcador {
  display: grid;
  place-items: center;
  background: var(--cor-superficie);
  color: var(--cor-texto-terciario);
}
</style>
