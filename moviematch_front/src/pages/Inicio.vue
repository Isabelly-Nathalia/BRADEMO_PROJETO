<script setup lang="ts">
// Página inicial (equivale a projeto_brademo/lib/screens/home/home.dart).
// Cada seção carrega e falha de forma independente. Sem sino de notificações (A-06).
import MovieCard from '../components/MovieCard.vue'
import SafeImage from '../components/SafeImage.vue'
import StateView from '../components/StateView.vue'
import { useRecurso } from '../composables/useRecurso'
import { STREAMINGS_HOME } from '../domain/streamings'
import { aleatorios } from '../services/filmes'
import { listarPublicidades } from '../services/publicidades'

const logos = import.meta.glob<string>('../assets/streamings/*.webp', { eager: true, import: 'default' })
const logoDe = (nome: string) => logos[`../assets/streamings/${nome}.webp`]

const publicidades = useRecurso(
  (signal) => listarPublicidades({ signal }),
  (r) => r.itens.length === 0,
)
const sugestoes = useRecurso(
  (signal) => aleatorios({ signal }),
  (r) => r.itens.length === 0,
)
</script>

<template>
  <div class="inicio">
    <header class="cabecalho">
      <div>
        <h1>Olá!</h1>
        <p>Encontre o filme perfeito para sua noite</p>
      </div>
      <RouterLink
        class="atalho"
        :to="{ name: 'pesquisa' }"
      >
        <svg
          aria-hidden="true"
          viewBox="0 0 24 24"
          width="22"
          height="22"
        >
          <path
            d="M10 3a7 7 0 0 1 5.6 11.2l5.1 5.1-1.4 1.4-5.1-5.1A7 7 0 1 1 10 3m0 2a5 5 0 1 0 0 10 5 5 0 0 0 0-10"
            fill="currentColor"
          />
        </svg>
        <span class="visualmente-oculto">Pesquisar filmes</span>
      </RouterLink>
    </header>

    <section
      class="secao"
      aria-labelledby="titulo-em-alta"
    >
      <h2
        id="titulo-em-alta"
        class="visualmente-oculto"
      >
        Em alta
      </h2>
      <StateView
        :estado="publicidades.estado.value"
        :erro="publicidades.erro.value"
        mensagem-vazio="Nenhuma novidade no momento."
        @tentar-novamente="publicidades.recarregar"
      >
        <!-- Focável: os slides não têm links, e sem isso o teclado não rola o carrossel. -->
        <ul
          class="carrossel"
          tabindex="0"
          aria-labelledby="titulo-em-alta"
        >
          <li
            v-for="publicidade in publicidades.dados.value?.itens"
            :key="publicidade.id"
            class="slide"
          >
            <SafeImage
              :src="publicidade.imagem"
              :alt="publicidade.descricao || 'Publicidade'"
            />
            <span
              class="rotulo-topo"
              aria-hidden="true"
            >Em alta</span>
            <span class="rotulo-base">Publicidade</span>
          </li>
        </ul>
      </StateView>
    </section>

    <section
      class="secao"
      aria-labelledby="titulo-sugestoes"
    >
      <h2 id="titulo-sugestoes">
        Você pode gostar
      </h2>
      <StateView
        :estado="sugestoes.estado.value"
        :erro="sugestoes.erro.value"
        mensagem-vazio="Nenhum filme disponível no momento."
        @tentar-novamente="sugestoes.recarregar"
      >
        <ul class="filmes">
          <li
            v-for="filme in sugestoes.dados.value?.itens"
            :key="filme.id"
          >
            <MovieCard :filme="filme" />
          </li>
        </ul>
      </StateView>
    </section>

    <section
      class="secao"
      aria-labelledby="titulo-streamings"
    >
      <h2 id="titulo-streamings">
        Descubra novos filmes por streaming
      </h2>
      <ul class="streamings">
        <li
          v-for="streaming in STREAMINGS_HOME"
          :key="streaming.slug"
        >
          <RouterLink
            class="streaming"
            :to="{ name: 'streaming', params: { slug: streaming.slug } }"
          >
            <img
              :src="logoDe(streaming.logo)"
              :alt="streaming.rotulo"
              width="65"
              height="65"
            >
          </RouterLink>
        </li>
      </ul>
    </section>
  </div>
</template>

<style scoped>
/* minmax(0, 1fr): a coluna nunca passa da largura da tela, mesmo que um filho tenha largura
   mínima maior (listas roláveis, campo de pesquisa no Chromium móvel). */
.inicio {
  display: grid;
  grid-template-columns: minmax(0, 1fr);
  gap: var(--espaco-5);
  padding: var(--espaco-4);
}

.cabecalho {
  display: flex;
  gap: var(--espaco-4);
  align-items: center;
  justify-content: space-between;
}

h1 {
  margin: 0;
  font-size: var(--tamanho-titulo);
}

.cabecalho p {
  margin: 0;
  color: var(--cor-texto-secundario);
}

.atalho {
  display: grid;
  place-items: center;
  min-width: 44px;
  min-height: 44px;
  border-radius: 50%;
  background: var(--cor-superficie);
  color: var(--cor-texto);
}

h2 {
  margin: 0 0 var(--espaco-3);
  font-size: 1rem;
}

ul {
  margin: 0;
  padding: 0;
  list-style: none;
}

.carrossel {
  display: flex;
  gap: 10px;
  overflow-x: auto;
  scroll-snap-type: x mandatory;
  overscroll-behavior-x: contain;
}

.slide {
  position: relative;
  flex: 0 0 100%;
  height: 260px;
  overflow: hidden;
  border-radius: 20px;
  scroll-snap-align: start;
}

.slide::after {
  position: absolute;
  inset: 0;
  background: linear-gradient(rgb(0 0 0 / 55%), transparent 30%, transparent 70%, rgb(0 0 0 / 65%));
  content: '';
  pointer-events: none;
}

.rotulo-topo,
.rotulo-base {
  position: absolute;
  z-index: 1;
}

.rotulo-topo {
  top: 10px;
  left: 10px;
  font-weight: 700;
}

.rotulo-base {
  right: 10px;
  bottom: 10px;
  color: var(--cor-texto-secundario);
  font-size: 0.75rem;
}

.filmes {
  display: grid;
  grid-auto-columns: 150px;
  grid-auto-flow: column;
  gap: 12px;
  overflow-x: auto;
  padding-bottom: var(--espaco-2);
}

@media (min-width: 600px) {
  .slide {
    flex-basis: calc(50% - 5px);
  }

  .filmes {
    grid-template-columns: repeat(auto-fill, minmax(150px, 1fr));
    grid-auto-flow: row;
    overflow-x: visible;
  }
}

.streamings {
  display: flex;
  gap: 15px;
  overflow-x: auto;
  padding-bottom: var(--espaco-2);
}

.streaming {
  display: block;
  width: 65px;
  height: 65px;
  overflow: hidden;
  border-radius: 50%;
}

.streaming img {
  width: 100%;
  height: 100%;
  object-fit: cover;
}
</style>
