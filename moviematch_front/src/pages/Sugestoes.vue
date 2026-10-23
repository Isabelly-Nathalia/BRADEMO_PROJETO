<script setup lang="ts">
// Sugestões (equivale a projeto_brademo/lib/screens/form/sugestao.dart): top 3 do catálogo pela
// regra de recomendação (domain/recomendacao.ts), em zigue-zague. O acesso exige as respostas
// mínimas (guard em router/index.ts).
import { computed } from 'vue'
import { useRouter } from 'vue-router'
import BaseButton from '../components/BaseButton.vue'
import SafeImage from '../components/SafeImage.vue'
import StateView from '../components/StateView.vue'
import { useCatalogo } from '../composables/useCatalogo'
import { useQuestionario } from '../composables/useQuestionario'
import { useRecurso } from '../composables/useRecurso'
import { ordenarSugestoes } from '../domain/recomendacao'

const router = useRouter()
const catalogo = useCatalogo()
const q = useQuestionario()

const filmes = useRecurso(
  () => catalogo.obter(),
  (r) => r.itens.length === 0,
)
const sugestoes = computed(() => ordenarSugestoes(filmes.dados.value?.itens ?? [], q.respostas))

function tentarNovamente() {
  catalogo.invalidar()
  void filmes.recarregar()
}

// Como no Flutter, voltar ao questionário a partir daqui recomeça do zero (form.dart:789-791).
function refazer() {
  q.limpar()
  void router.push({ name: 'questionario', params: { passo: '1' } })
}
</script>

<template>
  <div class="sugestoes">
    <header class="topo">
      <h1>Sugestões com base nas suas respostas</h1>
    </header>

    <StateView
      :estado="filmes.estado.value"
      :erro="filmes.erro.value"
      mensagem-vazio="Nenhum filme no catálogo no momento."
      @tentar-novamente="tentarNovamente"
    >
      <ol class="lista">
        <li
          v-for="(filme, i) in sugestoes"
          :key="filme.id"
          class="sugestao"
          :class="{ invertida: i % 2 === 1 }"
        >
          <RouterLink
            class="poster"
            :to="{ name: 'filme', params: { id: filme.id } }"
          >
            <SafeImage
              :src="filme.imagem"
              :alt="`Pôster de ${filme.titulo}`"
            />
          </RouterLink>
          <div class="info">
            <RouterLink
              class="titulo"
              :to="{ name: 'filme', params: { id: filme.id } }"
            >
              {{ filme.titulo }}
            </RouterLink>
            <p
              v-if="filme.streaming"
              class="onde"
            >
              Disponível em {{ filme.streaming }}
            </p>
          </div>
        </li>
      </ol>
    </StateView>

    <div class="acoes">
      <BaseButton @click="refazer">
        Refazer questionário
      </BaseButton>
    </div>
  </div>
</template>

<style scoped>
.sugestoes {
  display: grid;
  gap: var(--espaco-5);
  max-width: 720px;
  margin: 0 auto;
  padding: var(--espaco-4);
}

h1 {
  margin: 0;
  font-size: var(--tamanho-titulo);
  text-align: center;
}

.lista {
  display: grid;
  gap: var(--espaco-5);
  margin: 0;
  padding: 0;
  list-style: none;
}

.sugestao {
  display: grid;
  grid-template-columns: minmax(120px, 45%) 1fr;
  gap: var(--espaco-4);
  align-items: center;
}

.sugestao.invertida {
  grid-template-columns: 1fr minmax(120px, 45%);
}

.sugestao.invertida .poster {
  order: 2;
}

.sugestao.invertida .info {
  text-align: right;
}

.poster {
  display: block;
  aspect-ratio: 2 / 3;
  overflow: hidden;
  border-radius: 20px;
}

.info {
  display: grid;
  gap: var(--espaco-2);
}

.titulo {
  color: var(--cor-texto);
  font-size: 1.125rem;
  font-weight: 700;
  text-decoration: none;
}

.titulo:hover {
  text-decoration: underline;
}

.onde {
  margin: 0;
  color: var(--cor-texto-secundario);
}

.acoes {
  display: grid;
  justify-items: center;
}
</style>
