<script setup lang="ts">
// Detalhe do filme (equivale a projeto_brademo/lib/screens/home/detalheFilme.dart).
// Não existe GET /filmes/{id}: o filme vem do catálogo em cache (useCatalogo), o que permite
// abrir a URL direto ou dar F5. Sem "Curtir" e "Minha Lista" (fora do MVP).
import { computed, watch } from 'vue'
import { useRoute } from 'vue-router'
import BotaoVoltar from '../components/BotaoVoltar.vue'
import SafeImage from '../components/SafeImage.vue'
import StateView from '../components/StateView.vue'
import { useCatalogo } from '../composables/useCatalogo'
import { useRecurso } from '../composables/useRecurso'
import { formatarDuracao } from '../domain/duracao'
import { formatarNota } from '../domain/nota'

const rota = useRoute()
const catalogo = useCatalogo()
const id = computed(() => Number(rota.params.id))

const filme = useRecurso(
  () => catalogo.porId(id.value),
  (f) => f === undefined,
)
watch(id, () => void filme.recarregar())

function tentarNovamente() {
  catalogo.invalidar()
  void filme.recarregar()
}
</script>

<template>
  <article class="detalhe">
    <header class="topo">
      <BotaoVoltar />
      <p class="chamada">
        BOA ESCOLHA!
      </p>
    </header>

    <StateView
      :estado="filme.estado.value"
      :erro="filme.erro.value"
      mensagem-vazio="Filme não encontrado no catálogo."
      @tentar-novamente="tentarNovamente"
    >
      <div
        v-if="filme.dados.value"
        class="ficha"
      >
        <div class="poster">
          <SafeImage
            :src="filme.dados.value.imagem"
            :alt="`Pôster de ${filme.dados.value.titulo}`"
          />
        </div>

        <div class="dados">
          <div class="resumo">
            <h1>{{ filme.dados.value.titulo }}</h1>
            <p class="meta">
              <span><span class="visualmente-oculto">Nota</span>★ {{ formatarNota(filme.dados.value.nota) }}</span>
              <span><span class="visualmente-oculto">Duração</span>{{ formatarDuracao(filme.dados.value.duracaoMin) }}</span>
            </p>
          </div>

          <section
            v-if="filme.dados.value.diretor"
            class="bloco direcao"
          >
            <div class="foto-diretor">
              <SafeImage
                :src="filme.dados.value.fotoDiretor"
                :alt="`Foto de ${filme.dados.value.diretor}`"
              />
            </div>
            <div>
              <h2>Direção</h2>
              <p>{{ filme.dados.value.diretor }}</p>
            </div>
          </section>

          <section
            v-if="filme.dados.value.descricao"
            class="bloco"
          >
            <h2>Descrição</h2>
            <p>{{ filme.dados.value.descricao }}</p>
          </section>

          <section
            v-if="filme.dados.value.streaming"
            class="bloco"
          >
            <h2>Disponível em:</h2>
            <p>{{ filme.dados.value.streaming }}</p>
          </section>

          <section
            v-if="filme.dados.value.elenco.length > 0"
            class="bloco"
          >
            <h2>Elenco</h2>
            <ul class="elenco">
              <li
                v-for="(ator, i) in filme.dados.value.elenco"
                :key="`${i}-${ator}`"
              >
                {{ ator }}
              </li>
            </ul>
          </section>
        </div>
      </div>

      <template #vazio>
        <RouterLink :to="{ name: 'inicio' }">
          Voltar ao início
        </RouterLink>
      </template>
    </StateView>
  </article>
</template>

<style scoped>
.detalhe {
  display: grid;
  grid-template-columns: minmax(0, 1fr);
  gap: var(--espaco-4);
  max-width: 960px;
  margin: 0 auto;
  padding: var(--espaco-4);
}

.topo {
  display: flex;
  gap: var(--espaco-2);
  align-items: center;
}

.chamada {
  margin: 0;
  font-weight: 700;
  letter-spacing: 1px;
}

/* Celular: pôster centralizado e informações abaixo. A partir de 768 px: pôster à esquerda e
   informações à direita. O pôster mantém sempre 2:3 (retrato); a imagem usa object-fit: cover. */
.ficha {
  display: grid;
  grid-template-columns: minmax(0, 1fr);
  gap: var(--espaco-5);
}

.poster {
  justify-self: center;
  width: min(100%, 320px);
  aspect-ratio: 2 / 3;
  overflow: hidden;
  border-radius: 20px;
}

.dados {
  min-width: 0;
}

.resumo {
  display: grid;
  gap: var(--espaco-1);
}

@media (min-width: 768px) {
  .ficha {
    grid-template-columns: minmax(220px, 300px) minmax(0, 1fr);
    gap: var(--espaco-6);
    align-items: start;
  }

  .poster {
    width: 100%;
  }
}

h1 {
  margin: 0;
  font-size: var(--tamanho-titulo);
  text-transform: uppercase;
}

.meta {
  display: flex;
  gap: var(--espaco-4);
  margin: 0;
  color: var(--cor-texto-secundario);
}

.meta > span {
  position: relative;
}

.bloco {
  margin-top: var(--espaco-4);
}

h2 {
  margin: 0 0 var(--espaco-1);
  font-size: 1rem;
}

.bloco p {
  margin: 0;
  color: var(--cor-texto-secundario);
}

.direcao {
  display: flex;
  gap: var(--espaco-3);
  align-items: center;
}

.foto-diretor {
  flex: 0 0 56px;
  height: 56px;
  overflow: hidden;
  border-radius: 50%;
}

.elenco {
  margin: 0;
  padding-left: var(--espaco-5);
  color: var(--cor-texto-secundario);
}
</style>
