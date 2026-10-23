import { describe, expect, it } from 'vitest'
import { mount } from '@vue/test-utils'
import App from '../../src/App.vue'

describe('App', () => {
  it('monta e exibe o nome do produto', () => {
    const wrapper = mount(App)
    expect(wrapper.text()).toContain('MovieMatch')
  })
})
