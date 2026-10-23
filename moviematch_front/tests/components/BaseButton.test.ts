import { describe, expect, it } from 'vitest'
import { mount } from '@vue/test-utils'
import BaseButton from '../../src/components/BaseButton.vue'

describe('BaseButton', () => {
  it('é type="button" por padrão (não envia formulários sem querer)', () => {
    const wrapper = mount(BaseButton, { slots: { default: 'Começar' } })
    expect(wrapper.attributes('type')).toBe('button')
    expect(wrapper.text()).toBe('Começar')
  })

  it('aceita type="submit"', () => {
    expect(mount(BaseButton, { props: { tipo: 'submit' } }).attributes('type')).toBe('submit')
  })

  it('emite clique quando habilitado', async () => {
    const wrapper = mount(BaseButton)
    await wrapper.trigger('click')
    expect(wrapper.emitted('click')).toHaveLength(1)
  })

  it('fica desabilitado e não emite clique', async () => {
    const wrapper = mount(BaseButton, { props: { desabilitado: true } })
    expect(wrapper.attributes('disabled')).toBeDefined()
    await wrapper.trigger('click')
    expect(wrapper.emitted('click')).toBeUndefined()
  })
})
