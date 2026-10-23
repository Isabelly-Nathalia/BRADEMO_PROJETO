import { describe, expect, it } from 'vitest'
import { mount } from '@vue/test-utils'
import { defineComponent, h } from 'vue'
import ChipGroup from '../../src/components/ChipGroup.vue'

const OPCOES = ['Ação', 'Drama', 'Terror'] as const

function montar(props: Record<string, unknown>) {
  return mount(ChipGroup, {
    props: { legenda: 'Gêneros', opcoes: OPCOES, selecionados: [], modo: 'multiplo', ...props },
  })
}

describe('ChipGroup', () => {
  it('múltiplo: checkboxes nativos dentro de um fieldset com legenda', () => {
    const wrapper = montar({ selecionados: ['Drama'] })
    expect(wrapper.find('fieldset legend').text()).toBe('Gêneros')
    const inputs = wrapper.findAll('input')
    expect(inputs.map((i) => i.attributes('type'))).toEqual(['checkbox', 'checkbox', 'checkbox'])
    expect(inputs.map((i) => (i.element as HTMLInputElement).checked)).toEqual([false, true, false])
    expect(wrapper.findAll('label').map((l) => l.text())).toEqual(['Ação', 'Drama', 'Terror'])
  })

  it('múltiplo: clicar emite alternar com o valor', async () => {
    const wrapper = montar({})
    await wrapper.findAll('input')[2]!.trigger('click')
    expect(wrapper.emitted('alternar')).toEqual([['Terror']])
  })

  it('único: radios do mesmo grupo', () => {
    const wrapper = montar({ modo: 'unico' })
    const inputs = wrapper.findAll('input')
    expect(inputs.every((i) => i.attributes('type') === 'radio')).toBe(true)
    expect(new Set(inputs.map((i) => i.attributes('name'))).size).toBe(1)
  })

  it('único não desmarcável: clicar na opção marcada não emite', async () => {
    const wrapper = montar({ modo: 'unico', selecionados: ['Drama'] })
    await wrapper.findAll('input')[1]!.trigger('click')
    expect(wrapper.emitted('alternar')).toBeUndefined()
  })

  it('único desmarcável: clicar na opção marcada emite para desmarcar', async () => {
    const wrapper = montar({ modo: 'unico', selecionados: ['Drama'], desmarcavel: true })
    await wrapper.findAll('input')[1]!.trigger('click')
    expect(wrapper.emitted('alternar')).toEqual([['Drama']])
  })

  it('o chip marcado tem destaque visual', () => {
    const wrapper = montar({ selecionados: ['Ação'] })
    expect(wrapper.findAll('label')[0]!.classes()).toContain('marcado')
    expect(wrapper.findAll('label')[1]!.classes()).not.toContain('marcado')
  })

  it('dois grupos na mesma tela não compartilham o name dos radios', () => {
    const props = { legenda: 'x', opcoes: OPCOES, selecionados: [], modo: 'unico' as const }
    const Tela = defineComponent(() => () => [h(ChipGroup, props), h(ChipGroup, props)])
    const nomes = mount(Tela).findAll('fieldset').map((f) => f.find('input').attributes('name'))
    expect(nomes[0]).not.toBe(nomes[1])
  })
})
