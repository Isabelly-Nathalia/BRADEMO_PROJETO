import { describe, expect, it } from 'vitest'
import { mount } from '@vue/test-utils'
import { createMemoryHistory } from 'vue-router'
import App from '../../src/App.vue'
import { criarRouter } from '../../src/router'

describe('App', () => {
  it('renderiza a página da rota atual', async () => {
    const router = criarRouter(createMemoryHistory())
    await router.push('/rota/inexistente')
    const wrapper = mount(App, { global: { plugins: [router] } })
    expect(wrapper.text()).toContain('Página não encontrada')
    expect(wrapper.find('.nao-encontrado a').attributes('href')).toBe('/inicio')
  })
})
