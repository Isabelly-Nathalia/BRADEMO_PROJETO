<script setup lang="ts">
// Questionário de 8 passos (equivale a projeto_brademo/lib/screens/form/form.dart).
// Passo na URL (/questionario/1..8): "voltar" do navegador volta um passo; F5 mantém o passo.
// Como no Flutter, só o FINALIZAR valida (gênero, duração e streaming obrigatórios).
// A-03: sem os campos livres "Outro streaming" e "Outro país".
import { computed, nextTick, ref, watch } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import BaseButton from '../components/BaseButton.vue'
import ChipGroup from '../components/ChipGroup.vue'
import { useQuestionario } from '../composables/useQuestionario'
import { CLASSIFICACOES, DURACOES, GENEROS, PAISES, STREAMINGS } from '../domain/questionario'

const TOTAL = 8

const rota = useRoute()
const router = useRouter()
const q = useQuestionario()

const passo = computed(() => Number(rota.params.passo || 1))
const erro = ref<string | null>(null)
const titulo = ref<HTMLElement | null>(null)

function irPara(destino: number) {
  erro.value = null
  void router.push({ name: 'questionario', params: { passo: String(destino) } })
}

// Leva o foco ao título do passo novo (leitores de tela anunciam a mudança).
watch(passo, async () => {
  erro.value = null
  await nextTick()
  titulo.value?.focus()
})

function finalizar() {
  erro.value = q.validar()
  if (erro.value === null) void router.push({ name: 'sugestoes' })
}

function limpar() {
  q.limpar()
  irPara(1)
}

const NAVEGACAO = new Set([2, 3, 4, 6, 7])
</script>

<template>
  <div class="questionario">
    <header class="topo">
      <RouterLink
        v-if="passo > 1"
        class="fechar"
        :to="{ name: 'inicio' }"
      >
        <svg
          aria-hidden="true"
          viewBox="0 0 24 24"
          width="24"
          height="24"
        >
          <path
            d="m6.4 5 5.6 5.6L17.6 5 19 6.4 13.4 12l5.6 5.6-1.4 1.4-5.6-5.6L6.4 19 5 17.6l5.6-5.6L5 6.4z"
            fill="currentColor"
          />
        </svg>
        <span class="visualmente-oculto">Sair do questionário</span>
      </RouterLink>
      <progress
        class="progresso"
        :value="passo"
        :max="TOTAL"
        :aria-label="`Passo ${passo} de ${TOTAL}`"
      />
    </header>

    <section class="passo">
      <template v-if="passo === 1">
        <h1
          ref="titulo"
          tabindex="-1"
        >
          Descubra filmes perfeitos para você
        </h1>
        <p class="apoio">
          Responda algumas perguntas rápidas e encontraremos filmes do seu jeito.
        </p>
        <div class="acoes">
          <BaseButton @click="irPara(2)">
            COMEÇAR
          </BaseButton>
          <BaseButton :para="{ name: 'inicio' }">
            PÁGINA INICIAL
          </BaseButton>
        </div>
      </template>

      <template v-else-if="passo === 2">
        <h1
          ref="titulo"
          tabindex="-1"
        >
          Quais gêneros você gosta?
        </h1>
        <ChipGroup
          legenda="Gêneros"
          :opcoes="GENEROS"
          :selecionados="q.respostas.generos"
          modo="multiplo"
          @alternar="q.alternarGenero"
        />
      </template>

      <template v-else-if="passo === 3">
        <h1
          ref="titulo"
          tabindex="-1"
        >
          Qual a duração de filme ideal pra você?
        </h1>
        <ChipGroup
          legenda="Duração"
          :opcoes="DURACOES"
          :selecionados="q.respostas.duracao ? [q.respostas.duracao] : []"
          modo="unico"
          @alternar="q.definirDuracao"
        />
      </template>

      <template v-else-if="passo === 4">
        <h1
          ref="titulo"
          tabindex="-1"
        >
          Onde você costuma assistir?
        </h1>
        <ChipGroup
          legenda="Streamings"
          :opcoes="STREAMINGS"
          :selecionados="q.respostas.streamings"
          modo="multiplo"
          @alternar="q.alternarStreaming"
        />
      </template>

      <template v-else-if="passo === 5">
        <h1
          ref="titulo"
          tabindex="-1"
        >
          Falta pouco!
        </h1>
        <p class="apoio">
          As próximas perguntas são opcionais e ajudam a personalizar ainda mais suas recomendações.
        </p>
        <div class="acoes">
          <BaseButton @click="irPara(6)">
            CONTINUAR
          </BaseButton>
          <BaseButton @click="finalizar">
            FINALIZAR
          </BaseButton>
        </div>
      </template>

      <template v-else-if="passo === 6">
        <h1
          ref="titulo"
          tabindex="-1"
        >
          Qual classificação indicativa você prefere?
        </h1>
        <ChipGroup
          legenda="Classificação indicativa"
          :opcoes="CLASSIFICACOES"
          :selecionados="q.respostas.classificacao ? [q.respostas.classificacao] : []"
          modo="unico"
          desmarcavel
          @alternar="q.alternarClassificacao"
        />
      </template>

      <template v-else-if="passo === 7">
        <h1
          ref="titulo"
          tabindex="-1"
        >
          Tem preferência por algum país?
        </h1>
        <ChipGroup
          legenda="Países"
          :opcoes="PAISES"
          :selecionados="q.respostas.paises"
          modo="multiplo"
          @alternar="q.alternarPais"
        />
      </template>

      <template v-else>
        <h1
          ref="titulo"
          tabindex="-1"
        >
          Algum ator ou diretor favorito?
        </h1>
        <p class="apoio">
          Isso ajuda a personalizar ainda mais suas recomendações.
        </p>
        <label
          class="visualmente-oculto"
          for="campo-ator"
        >Ator ou diretor favorito</label>
        <input
          id="campo-ator"
          class="campo"
          type="text"
          placeholder="Ex: Fernanda Montenegro"
          autocomplete="off"
          :value="q.respostas.ator"
          @input="q.definirAtor(($event.target as HTMLInputElement).value)"
        >
        <div class="acoes">
          <BaseButton @click="limpar">
            LIMPAR
          </BaseButton>
          <BaseButton @click="finalizar">
            FINALIZAR
          </BaseButton>
        </div>
      </template>

      <p
        v-if="erro"
        class="erro"
        role="alert"
      >
        {{ erro }}
      </p>
    </section>

    <nav
      v-if="passo > 1"
      class="passos"
      aria-label="Passos do questionário"
    >
      <button
        class="seta"
        type="button"
        @click="irPara(passo - 1)"
      >
        <span aria-hidden="true">‹</span>
        <span class="visualmente-oculto">Passo anterior</span>
      </button>
      <button
        v-if="NAVEGACAO.has(passo)"
        class="seta"
        type="button"
        @click="irPara(passo + 1)"
      >
        <span aria-hidden="true">›</span>
        <span class="visualmente-oculto">Próximo passo</span>
      </button>
    </nav>
  </div>
</template>

<style scoped>
.questionario {
  display: grid;
  grid-template-columns: minmax(0, 1fr);
  grid-template-rows: auto 1fr auto;
  gap: var(--espaco-5);
  max-width: 720px;
  min-height: 100vh;
  margin: 0 auto;
  padding: var(--espaco-4);
}

.topo {
  display: flex;
  gap: var(--espaco-3);
  align-items: center;
  min-height: 44px;
}

.fechar {
  position: relative;
  display: grid;
  place-items: center;
  min-width: 44px;
  min-height: 44px;
  color: var(--cor-texto);
}

.progresso {
  flex: 1;
  height: 6px;
  overflow: hidden;
  border: none;
  border-radius: 3px;
  background: var(--cor-superficie);
  accent-color: var(--cor-texto);
  appearance: none;
}

.progresso::-webkit-progress-bar {
  background: var(--cor-superficie);
}

.progresso::-webkit-progress-value {
  background: var(--cor-texto);
}

.progresso::-moz-progress-bar {
  background: var(--cor-texto);
}

.passo {
  display: grid;
  align-content: center;
  gap: var(--espaco-4);
  text-align: center;
}

h1 {
  margin: 0;
  font-size: var(--tamanho-titulo);
  outline: none;
}

.apoio {
  margin: 0;
  color: var(--cor-texto-secundario);
}

.acoes {
  display: grid;
  gap: var(--espaco-3);
  justify-items: center;
}

.campo {
  min-height: 48px;
  padding: 0 var(--espaco-4);
  border: 1px solid var(--cor-texto-terciario);
  border-radius: var(--raio-grande);
  background: var(--cor-superficie);
}

.erro {
  margin: 0;
  padding: var(--espaco-3);
  border-radius: var(--raio-pequeno);
  background: var(--cor-vermelho-escuro);
}

.passos {
  display: flex;
  justify-content: space-between;
}

.seta {
  position: relative;
  min-width: 48px;
  min-height: 48px;
  border: none;
  border-radius: 50%;
  background: var(--cor-superficie);
  font-size: 1.75rem;
  line-height: 1;
  cursor: pointer;
}

.seta:only-child {
  margin-right: auto;
}
</style>
