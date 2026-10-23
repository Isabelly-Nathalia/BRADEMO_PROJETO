<script setup lang="ts">
// Filmes por streaming (equivale a projeto_brademo/lib/screens/home/filmeStreaming.dart).
// O slug da URL é traduzido pela tabela da Home (domain/streamings.ts, A-05).
import { computed, watch, watchEffect } from 'vue'
import { useRoute } from 'vue-router'
import BotaoVoltar from '../components/BotaoVoltar.vue'
import MovieCard from '../components/MovieCard.vue'
import StateView from '../components/StateView.vue'
import NaoEncontrado from './NaoEncontrado.vue'
import { useRecurso } from '../composables/useRecurso'
import { streamingPorSlug } from '../domain/streamings'
import { tituloDaPagina } from '../router'
import { outros, porStreaming } from '../services/filmes'

const rota = useRoute()
const streaming = computed(() => streamingPorSlug(String(rota.params.slug)))

const filmes = useRecurso(
  (signal) => {
    const atual = streaming.value
    if (!atual) return Promise.resolve(null)
    return atual.filtro.tipo === 'outros' ? outros({ signal }) : porStreaming(atual.filtro.valor, { signal })
  },
  (r) => r !== null && r.itens.length === 0,
)
watch(() => rota.params.slug, () => void filmes.recarregar())

watchEffect(() => {
  document.title = tituloDaPagina(streaming.value?.rotulo ?? 'Página não encontrada')
})
</script>

<template>
  <NaoEncontrado v-if="!streaming" />
  <div
    v-else
    class="streaming"
  >
    <header class="topo">
      <BotaoVoltar />
      <div>
        <p class="chamada">
          Últimos lançamentos no catálogo
        </p>
        <h1>{{ streaming.rotulo }}</h1>
      </div>
    </header>

    <StateView
      :estado="filmes.estado.value"
      :erro="filmes.erro.value"
      mensagem-vazio="Nenhum filme deste streaming no catálogo."
      @tentar-novamente="filmes.recarregar"
    >
      <ul class="grade">
        <li
          v-for="filme in filmes.dados.value?.itens"
          :key="filme.id"
        >
          <MovieCard :filme="filme" />
        </li>
      </ul>
    </StateView>
  </div>
</template>

<style scoped>
.streaming {
  display: grid;
  gap: var(--espaco-4);
  padding: var(--espaco-4);
}

.topo {
  display: flex;
  gap: var(--espaco-2);
  align-items: center;
}

.chamada {
  margin: 0;
  color: var(--cor-texto-secundario);
  font-size: 0.875rem;
}

h1 {
  margin: 0;
  font-size: var(--tamanho-titulo);
}

.grade {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(150px, 1fr));
  gap: 12px;
  margin: 0;
  padding: 0;
  list-style: none;
}
</style>
