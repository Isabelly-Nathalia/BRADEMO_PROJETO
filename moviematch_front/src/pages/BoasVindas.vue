<script setup lang="ts">
// Boas-vindas (equivale a projeto_brademo/lib/screens/inicio/inicial.dart).
// Sem login (fora do MVP). A visita é registrada ao abrir a página (A-04).
import { onMounted } from 'vue'
import BaseButton from '../components/BaseButton.vue'
import { usePrimeiraVisita } from '../composables/usePrimeiraVisita'
import logo from '../assets/marca/moviematch-vertical.webp'
import filme1 from '../assets/posteres/filme1.webp'
import filme2 from '../assets/posteres/filme2.webp'
import filme3 from '../assets/posteres/filme3.webp'
import filme4 from '../assets/posteres/filme4.webp'
import filme5 from '../assets/posteres/filme5.webp'
import filme6 from '../assets/posteres/filme6.webp'

const posteres = [filme1, filme2, filme3, filme4, filme5, filme6]

onMounted(() => usePrimeiraVisita().marcarVisita())
</script>

<template>
  <section class="boas-vindas">
    <img
      class="logo"
      :src="logo"
      alt="MovieMatch"
      width="160"
      height="200"
    >
    <div
      class="mosaico"
      aria-hidden="true"
    >
      <img
        v-for="poster in posteres"
        :key="poster"
        :src="poster"
        alt=""
      >
    </div>
    <div class="texto">
      <h1>Bem-vindo(a) ao MovieMatch</h1>
      <p>Descubra novos filmes e conheça o seu próximo favorito para assistir</p>
    </div>
    <div class="acoes">
      <BaseButton :para="{ name: 'questionario', params: { passo: '1' } }">
        Começar questionário
      </BaseButton>
      <BaseButton :para="{ name: 'inicio' }">
        Explorar filmes
      </BaseButton>
    </div>
  </section>
</template>

<style scoped>
.boas-vindas {
  display: grid;
  gap: var(--espaco-5);
  justify-items: center;
  max-width: 480px;
  margin: 0 auto;
  padding: var(--espaco-5) var(--espaco-4);
  text-align: center;
}

.logo {
  width: 120px;
  height: auto;
}

/* 3 colunas × 2 linhas (o Flutter usa 2 × 3): mantém os botões visíveis sem rolar no celular. */
.mosaico {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 10px;
  width: 100%;
  max-width: 360px;
}

.mosaico img {
  width: 100%;
  aspect-ratio: 34 / 49;
  border-radius: var(--raio-pequeno);
  object-fit: cover;
}

h1 {
  margin: 0;
  font-size: var(--tamanho-titulo);
}

.texto p {
  margin: var(--espaco-2) 0 0;
  color: var(--cor-texto-secundario);
}

.acoes {
  display: grid;
  gap: var(--espaco-3);
}
</style>
