import { describe, expect, it, vi } from 'vitest'
import { flushPromises, mount } from '@vue/test-utils'
import { createMemoryHistory } from 'vue-router'
import BoasVindas from '../../src/pages/BoasVindas.vue'
import { criarRouter } from '../../src/router'

const marcarVisita = vi.hoisted(() => vi.fn())
vi.mock('../../src/composables/usePrimeiraVisita', () => ({
  usePrimeiraVisita: () => ({ jaVisitou: () => false, marcarVisita }),
}))

async function montar() {
  const router = criarRouter(createMemoryHistory())
  await router.push('/boas-vindas')
  const wrapper = mount(BoasVindas, { global: { plugins: [router] } })
  await flushPromises()
  return wrapper
}

describe('BoasVindas', () => {
  it('mostra os textos do Flutter', async () => {
    const wrapper = await montar()
    expect(wrapper.find('h1').text()).toBe('Bem-vindo(a) ao MovieMatch')
    expect(wrapper.text()).toContain('Descubra novos filmes e conheça o seu próximo favorito para assistir')
  })

  it('oferece questionário e catálogo como links (sem login)', async () => {
    const wrapper = await montar()
    const links = wrapper.findAll('.acoes a').map((a) => [a.text(), a.attributes('href')])
    expect(links).toEqual([
      ['Começar questionário', '/questionario/1'],
      ['Explorar filmes', '/inicio'],
    ])
    expect(wrapper.text().toLowerCase()).not.toContain('login')
  })

  it('registra a visita ao abrir', async () => {
    marcarVisita.mockClear()
    await montar()
    expect(marcarVisita).toHaveBeenCalledTimes(1)
  })

  it('mosaico de pôsteres é decorativo; o logo tem texto alternativo', async () => {
    const wrapper = await montar()
    expect(wrapper.find('.mosaico').attributes('aria-hidden')).toBe('true')
    expect(wrapper.findAll('.mosaico img')).toHaveLength(6)
    expect(wrapper.find('.logo').attributes('alt')).toBe('MovieMatch')
  })
})
