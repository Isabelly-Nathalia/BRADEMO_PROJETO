import { describe, expect, it } from 'vitest'
import { mount } from '@vue/test-utils'
import { createMemoryHistory } from 'vue-router'
import MovieCard from '../../src/components/MovieCard.vue'
import { criarRouter } from '../../src/router'
import { mapearFilme } from '../../src/services/mapeadores'
import { formatarNota } from '../../src/domain/nota'
import validos from '../fixtures/filmes-validos.json'

function montar(indice = 0, alteracao: Record<string, unknown> = {}) {
  const filme = mapearFilme({ ...validos[indice], ...alteracao })!
  return mount(MovieCard, { props: { filme }, global: { plugins: [criarRouter(createMemoryHistory())] } })
}

describe('MovieCard', () => {
  it('é um link para o detalhe do filme', () => {
    expect(montar(3).attributes('href')).toBe('/filmes/4')
  })

  it('mostra título, nota e duração no formato do Flutter', () => {
    const wrapper = montar(0)
    expect(wrapper.find('.titulo').text()).toBe('Cidade Partida')
    expect(wrapper.text()).toContain('4.5')
    expect(wrapper.text()).toContain('2h10min')
  })

  it('pôster com texto alternativo e URL https', () => {
    const img = montar(0).find('img')
    expect(img.attributes('alt')).toBe('Pôster de Cidade Partida')
    expect(img.attributes('src')).toBe('https://img.exemplo.invalid/filmes/1.jpg')
  })

  it('sem imagem válida mostra o marcador, mantendo o texto alternativo', () => {
    const wrapper = montar(0, { linkImagemFilme_filme: null })
    expect(wrapper.find('img').exists()).toBe(false)
    expect(wrapper.find('[role="img"]').attributes('aria-label')).toBe('Pôster de Cidade Partida')
  })

  it('nota e duração são anunciadas com rótulo (texto oculto, não aria-label em span)', () => {
    const wrapper = montar(0)
    const [nota, duracao] = wrapper.findAll('.meta > span')
    expect(nota!.text().replace(/\s+/g, ' ')).toBe('Nota 4.5')
    expect(duracao!.text().replace(/\s+/g, ' ')).toBe('Duração 2h10min')
    expect(wrapper.find('.meta [aria-label]').exists()).toBe(false)
  })

  it('título com HTML é exibido como texto', () => {
    const wrapper = montar(0, { titulo_filme: '<img src=x onerror=alert(1)>' })
    expect(wrapper.find('.titulo').text()).toBe('<img src=x onerror=alert(1)>')
    expect(wrapper.find('.titulo img').exists()).toBe(false)
  })
})

describe('formatarNota (double.toString do Dart)', () => {
  it.each([
    [4, '4.0'],
    [4.5, '4.5'],
    [3.75, '3.75'],
    [0, '0.0'],
  ])('%d → %s', (nota, texto) => {
    expect(formatarNota(nota)).toBe(texto)
  })
})
