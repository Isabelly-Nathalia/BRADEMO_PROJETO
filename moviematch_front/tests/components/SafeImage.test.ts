import { describe, expect, it } from 'vitest'
import { mount } from '@vue/test-utils'
import SafeImage from '../../src/components/SafeImage.vue'

const montar = (src: string | null | undefined) => mount(SafeImage, { props: { src, alt: 'Pôster de Exemplo' } })

describe('SafeImage', () => {
  it('exibe URL https com atributos de privacidade e carga tardia', () => {
    const img = montar('https://exemplo.com/poster.jpg').find('img')
    expect(img.attributes('src')).toBe('https://exemplo.com/poster.jpg')
    expect(img.attributes('alt')).toBe('Pôster de Exemplo')
    expect(img.attributes('loading')).toBe('lazy')
    expect(img.attributes('referrerpolicy')).toBe('no-referrer')
  })

  it.each([
    ['http', 'http://exemplo.com/poster.jpg'],
    ['javascript', 'javascript:alert(1)'],
    ['data', 'data:image/png;base64,AAAA'],
    ['relativa', '/poster.jpg'],
    ['protocolo relativo', '//exemplo.com/poster.jpg'],
    ['texto inválido', 'não é url'],
    ['vazia', ''],
    ['nula', null],
    ['indefinida', undefined],
  ])('URL %s vira marcador com o mesmo texto alternativo', (_caso, src) => {
    const wrapper = montar(src)
    expect(wrapper.find('img').exists()).toBe(false)
    const marcador = wrapper.find('[role="img"]')
    expect(marcador.attributes('aria-label')).toBe('Pôster de Exemplo')
  })

  it('troca para o marcador quando a imagem falha ao carregar', async () => {
    const wrapper = montar('https://exemplo.com/quebrada.jpg')
    await wrapper.find('img').trigger('error')
    expect(wrapper.find('img').exists()).toBe(false)
    expect(wrapper.find('[role="img"]').exists()).toBe(true)
  })

  it('volta a tentar quando a URL muda depois de uma falha', async () => {
    const wrapper = montar('https://exemplo.com/quebrada.jpg')
    await wrapper.find('img').trigger('error')
    await wrapper.setProps({ src: 'https://exemplo.com/nova.jpg' })
    expect(wrapper.find('img').attributes('src')).toBe('https://exemplo.com/nova.jpg')
  })
})
