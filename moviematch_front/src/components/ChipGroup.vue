<script setup lang="ts" generic="T extends string">
// Grupo de opções em "chips" sobre inputs nativos (teclado e leitor de tela sem código extra).
// modo "multiplo": checkboxes · modo "unico": radios. Com `desmarcavel`, clicar de novo na opção
// marcada a desmarca (classificação, formProvider.dart:64-72).
import { useId } from 'vue'

const props = withDefaults(
  defineProps<{
    legenda: string
    opcoes: readonly T[]
    selecionados: readonly T[]
    modo: 'multiplo' | 'unico'
    desmarcavel?: boolean
  }>(),
  { desmarcavel: false },
)
const emit = defineEmits<{ alternar: [valor: T] }>()

const nome = useId()

function aoClicar(valor: T, evento: MouseEvent) {
  if (props.modo === 'unico' && props.selecionados.includes(valor)) {
    // Radio já marcado não dispara "change"; o clique decide se desmarca.
    if (props.desmarcavel) emit('alternar', valor)
    evento.preventDefault()
    return
  }
  emit('alternar', valor)
}
</script>

<template>
  <fieldset class="grupo">
    <legend class="visualmente-oculto">
      {{ legenda }}
    </legend>
    <label
      v-for="opcao in opcoes"
      :key="opcao"
      class="chip"
      :class="{ marcado: selecionados.includes(opcao) }"
    >
      <input
        class="visualmente-oculto"
        :type="modo === 'multiplo' ? 'checkbox' : 'radio'"
        :name="nome"
        :value="opcao"
        :checked="selecionados.includes(opcao)"
        @click="aoClicar(opcao, $event)"
      >
      <span>{{ opcao }}</span>
    </label>
  </fieldset>
</template>

<style scoped>
.grupo {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(140px, 1fr));
  gap: var(--espaco-3);
  margin: 0;
  padding: 0;
  border: none;
}

.chip {
  position: relative;
  display: grid;
  place-items: center;
  min-height: 48px;
  padding: var(--espaco-2) var(--espaco-3);
  border: 1px solid var(--cor-texto-terciario);
  border-radius: var(--raio-grande);
  background: var(--cor-superficie);
  text-align: center;
  cursor: pointer;
}

.chip.marcado {
  border-color: var(--cor-texto);
  background: var(--cor-destaque);
  font-weight: 600;
}

.chip:has(input:focus-visible) {
  outline: 2px solid var(--cor-foco);
  outline-offset: 2px;
}
</style>
