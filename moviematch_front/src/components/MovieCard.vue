<script setup lang="ts">
// Cartão de filme (equivale a projeto_brademo/lib/widgets/cardFilme.dart). O cartão inteiro é
// um link para o detalhe.
import SafeImage from './SafeImage.vue'
import { formatarDuracao } from '../domain/duracao'
import { formatarNota } from '../domain/nota'
import type { Filme } from '../types/modelos'

defineProps<{ filme: Filme }>()
</script>

<template>
  <RouterLink
    class="cartao"
    :to="{ name: 'filme', params: { id: filme.id } }"
  >
    <div class="poster">
      <SafeImage
        :src="filme.imagem"
        :alt="`Pôster de ${filme.titulo}`"
      />
    </div>
    <div class="info">
      <p class="titulo">
        {{ filme.titulo }}
      </p>
      <p class="meta">
        <span>
          <svg
            aria-hidden="true"
            viewBox="0 0 24 24"
            width="12"
            height="12"
          >
            <path
              d="m12 17.3-6.2 3.7 1.7-7L2 9.2l7.1-.6L12 2l2.9 6.6 7.1.6-5.5 4.8 1.7 7z"
              fill="currentColor"
            />
          </svg>
          <span class="visualmente-oculto">Nota</span>
          {{ formatarNota(filme.nota) }}
        </span>
        <span>
          <svg
            aria-hidden="true"
            viewBox="0 0 24 24"
            width="12"
            height="12"
          >
            <path
              d="M12 2a10 10 0 1 0 0 20 10 10 0 0 0 0-20m0 2a8 8 0 1 1 0 16 8 8 0 0 1 0-16m-1 3v6l5 3 1-1.6-4-2.4V7z"
              fill="currentColor"
            />
          </svg>
          <span class="visualmente-oculto">Duração</span>
          {{ formatarDuracao(filme.duracaoMin) }}
        </span>
      </p>
    </div>
  </RouterLink>
</template>

<style scoped>
.cartao {
  display: flex;
  flex-direction: column;
  width: 100%;
  min-width: 0;
  color: var(--cor-texto);
  text-decoration: none;
}

.poster {
  height: 220px;
  overflow: hidden;
  border-radius: 20px 20px 0 0;
  background: var(--cor-superficie);
}

.info {
  display: grid;
  flex: 1;
  gap: var(--espaco-1);
  padding: var(--espaco-2);
  border-radius: 0 0 10px 10px;
  background: var(--cor-azul);
  text-align: center;
}

.titulo {
  margin: 0;
  font-size: 0.75rem;
  overflow-wrap: anywhere;
  text-transform: uppercase;
}

.meta {
  display: flex;
  gap: var(--espaco-3);
  justify-content: center;
  margin: 0;
  font-size: 0.75rem;
}

.meta > span {
  display: inline-flex;
  gap: 3px;
  align-items: center;
}

.cartao:hover .poster {
  filter: brightness(1.1);
}
</style>
