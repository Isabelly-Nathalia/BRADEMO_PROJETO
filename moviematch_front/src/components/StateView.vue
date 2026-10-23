<script setup lang="ts">
// Estados explícitos de qualquer conteúdo carregado da API.
// Sem retry automático: "Tentar novamente" só emite o evento; quem usa decide o que refazer.
import { computed } from 'vue'
import BaseButton from './BaseButton.vue'
import { mensagemErro } from './mensagemErro'
import { useAvisoLentidao } from '../composables/useAvisoLentidao'

export type EstadoCarga = 'carregando' | 'erro' | 'vazio' | 'sucesso'

const props = withDefaults(
  defineProps<{ estado: EstadoCarga; erro?: unknown; mensagemVazio?: string }>(),
  { erro: undefined, mensagemVazio: 'Nada encontrado.' },
)
const emit = defineEmits<{ tentarNovamente: [] }>()

const carregando = computed(() => props.estado === 'carregando')
const lento = useAvisoLentidao(carregando)
</script>

<template>
  <div
    class="estado"
    aria-live="polite"
  >
    <div
      v-if="estado === 'carregando'"
      class="mensagem"
      role="status"
    >
      <span
        class="indicador"
        aria-hidden="true"
      />
      <p>Carregando…</p>
      <p
        v-if="lento"
        class="secundario"
      >
        O servidor pode estar iniciando. Isso pode levar alguns segundos.
      </p>
    </div>

    <div
      v-else-if="estado === 'erro'"
      class="mensagem"
    >
      <p>{{ mensagemErro(erro) }}</p>
      <BaseButton @click="emit('tentarNovamente')">
        Tentar novamente
      </BaseButton>
    </div>

    <p
      v-else-if="estado === 'vazio'"
      class="mensagem secundario"
    >
      {{ mensagemVazio }}
    </p>

    <slot v-else />
  </div>
</template>

<style scoped>
.mensagem {
  display: grid;
  gap: var(--espaco-3);
  justify-items: center;
  padding: var(--espaco-5) var(--espaco-4);
  text-align: center;
}

.mensagem p {
  margin: 0;
}

.secundario {
  color: var(--cor-texto-secundario);
}

.indicador {
  width: 32px;
  height: 32px;
  border: 3px solid var(--cor-texto-terciario);
  border-top-color: var(--cor-texto);
  border-radius: 50%;
  animation: girar 0.9s linear infinite;
}

@keyframes girar {
  to {
    transform: rotate(360deg);
  }
}
</style>
