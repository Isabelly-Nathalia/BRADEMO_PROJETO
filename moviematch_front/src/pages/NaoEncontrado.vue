<script setup lang="ts">
import BaseButton from '../components/BaseButton.vue'
</script>

<template>
  <section class="nao-encontrado">
    <h1>Página não encontrada</h1>
    <p>O endereço acessado não existe no MovieMatch.</p>
    <BaseButton :para="{ name: 'inicio' }">
      Voltar ao início
    </BaseButton>
  </section>
</template>

<style scoped>
.nao-encontrado {
  display: grid;
  grid-template-columns: minmax(0, 1fr);
  gap: var(--espaco-4);
  justify-items: center;
  padding: var(--espaco-6) var(--espaco-4);
  text-align: center;
}

h1 {
  margin: 0;
  font-size: var(--tamanho-titulo);
}

p {
  margin: 0;
  color: var(--cor-texto-secundario);
}
</style>
