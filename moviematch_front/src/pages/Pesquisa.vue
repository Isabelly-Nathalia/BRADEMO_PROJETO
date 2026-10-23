<script setup lang="ts">
// Pesquisa (equivale a projeto_brademo/lib/screens/home/pesquisa.dart).
// O termo fica na URL (?q=): F5, link compartilhado e "voltar" refazem a mesma busca.
// O termo vai à API como digitado (paridade); só espaços não pesquisa; "/" é recusado
// porque a API recebe o termo no caminho (GET /filmes/pesquisa/{termo}).
import { computed, ref, watch } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import BaseButton from '../components/BaseButton.vue'
import BotaoVoltar from '../components/BotaoVoltar.vue'
import SafeImage from '../components/SafeImage.vue'
import StateView from '../components/StateView.vue'
import { useRecurso } from '../composables/useRecurso'
import { formatarDuracao } from '../domain/duracao'
import { formatarNota } from '../domain/nota'
import { pesquisar } from '../services/filmes'

const rota = useRoute()
const router = useRouter()

const termoDaUrl = computed(() => (typeof rota.query.q === 'string' ? rota.query.q : ''))
const temTermo = computed(() => termoDaUrl.value.trim() !== '')
const termoInvalido = computed(() => termoDaUrl.value.includes('/'))

const campo = ref(termoDaUrl.value)
watch(termoDaUrl, (termo) => (campo.value = termo))

const resultado = useRecurso(
  (signal) => (temTermo.value && !termoInvalido.value ? pesquisar(termoDaUrl.value, { signal }) : Promise.resolve(null)),
  (r) => r !== null && r.itens.length === 0,
)
watch(termoDaUrl, () => void resultado.recarregar())

function enviar() {
  if (campo.value === termoDaUrl.value) void resultado.recarregar()
  else void router.push({ name: 'pesquisa', query: campo.value.trim() === '' ? {} : { q: campo.value } })
}
</script>

<template>
  <div class="pesquisa">
    <form
      class="busca"
      role="search"
      @submit.prevent="enviar"
    >
      <BotaoVoltar />
      <label
        class="visualmente-oculto"
        for="campo-pesquisa"
      >Pesquisar filmes por título</label>
      <input
        id="campo-pesquisa"
        v-model="campo"
        type="search"
        placeholder="Pesquisar"
        autocomplete="off"
        enterkeyhint="search"
      >
      <BaseButton tipo="submit">
        Buscar
      </BaseButton>
    </form>

    <p
      v-if="termoInvalido"
      class="aviso"
      role="alert"
    >
      A pesquisa não pode conter "/".
    </p>
    <p
      v-else-if="!temTermo"
      class="aviso"
    >
      Digite o título de um filme para pesquisar.
    </p>
    <StateView
      v-else
      :estado="resultado.estado.value"
      :erro="resultado.erro.value"
      mensagem-vazio="Filme não localizado no catálogo"
      @tentar-novamente="resultado.recarregar"
    >
      <ul class="resultados">
        <li
          v-for="filme in resultado.dados.value?.itens"
          :key="filme.id"
        >
          <RouterLink
            class="item"
            :to="{ name: 'filme', params: { id: filme.id } }"
          >
            <div class="miniatura">
              <SafeImage
                :src="filme.imagem"
                :alt="`Pôster de ${filme.titulo}`"
              />
            </div>
            <div class="texto">
              <p class="titulo">
                {{ filme.titulo }}
              </p>
              <p class="meta">
                <span><span class="visualmente-oculto">Nota</span>★ {{ formatarNota(filme.nota) }}</span>
                <span><span class="visualmente-oculto">Duração</span>{{ formatarDuracao(filme.duracaoMin) }}</span>
              </p>
              <p class="descricao">
                {{ filme.descricao }}
              </p>
            </div>
          </RouterLink>
        </li>
      </ul>
    </StateView>
  </div>
</template>

<style scoped>
.pesquisa {
  display: grid;
  gap: var(--espaco-4);
  max-width: 720px;
  margin: 0 auto;
  padding: var(--espaco-4);
}

.busca {
  display: flex;
  gap: var(--espaco-2);
  align-items: center;
}

.busca .botao {
  min-width: auto;
}

input {
  flex: 1;
  min-width: 0;
  min-height: 45px;
  padding: 0 var(--espaco-4);
  border: 1px solid var(--cor-texto-terciario);
  border-radius: var(--raio-grande);
  background: var(--cor-superficie);
}

.aviso {
  margin: 0;
  color: var(--cor-texto-secundario);
  text-align: center;
}

.resultados {
  display: grid;
  gap: var(--espaco-3);
  margin: 0;
  padding: 0;
  list-style: none;
}

.item {
  position: relative;
  display: flex;
  gap: var(--espaco-3);
  overflow: hidden;
  border-radius: 12px;
  background: var(--cor-azul);
  color: var(--cor-texto);
  text-decoration: none;
}

.miniatura {
  flex: 0 0 90px;
  height: 130px;
}

.texto {
  display: grid;
  align-content: start;
  gap: var(--espaco-1);
  min-width: 0;
  padding: var(--espaco-2) var(--espaco-3) var(--espaco-2) 0;
}

.texto p {
  margin: 0;
}

.titulo {
  font-weight: 700;
}

.meta {
  display: flex;
  gap: var(--espaco-3);
  color: var(--cor-texto-secundario);
  font-size: 0.875rem;
}

.descricao {
  display: -webkit-box;
  overflow: hidden;
  color: var(--cor-texto-secundario);
  font-size: 0.875rem;
  -webkit-box-orient: vertical;
  -webkit-line-clamp: 3;
}
</style>
