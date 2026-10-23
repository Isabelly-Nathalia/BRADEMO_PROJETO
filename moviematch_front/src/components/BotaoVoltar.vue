<script setup lang="ts">
// Voltar como no Flutter (Navigator.pop). Se a página foi aberta direto pela URL (sem
// histórico dentro do app), vai ao início em vez de sair do site.
import { useRouter } from 'vue-router'

const router = useRouter()

function voltar() {
  // Estado do histórico do próprio router (funciona no histórico do navegador e em memória).
  if (router.options.history.state.back) router.back()
  else void router.push({ name: 'inicio' })
}
</script>

<template>
  <button
    class="voltar"
    type="button"
    @click="voltar"
  >
    <svg
      aria-hidden="true"
      viewBox="0 0 24 24"
      width="24"
      height="24"
    >
      <path
        d="M20 11H7.8l5.6-5.6L12 4l-8 8 8 8 1.4-1.4L7.8 13H20z"
        fill="currentColor"
      />
    </svg>
    <span class="visualmente-oculto">Voltar</span>
  </button>
</template>

<style scoped>
.voltar {
  position: relative;
  display: grid;
  place-items: center;
  min-width: 44px;
  min-height: 44px;
  padding: 0;
  border: none;
  border-radius: 50%;
  background: transparent;
  cursor: pointer;
}

.voltar:hover {
  background: var(--cor-superficie);
}
</style>
