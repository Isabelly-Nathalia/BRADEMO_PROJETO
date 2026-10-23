import { beforeEach, describe, expect, it, vi } from 'vitest'
import { flushPromises, mount } from '@vue/test-utils'
import { createMemoryHistory } from 'vue-router'
import App from '../../src/App.vue'
import { criarRouter } from '../../src/router'
import { pesquisar } from '../../src/services/filmes'
import { FalhaApi } from '../../src/services/http'
import { mapearFilme, mapearLista } from '../../src/services/mapeadores'
import validos from '../fixtures/filmes-validos.json'

vi.mock('../../src/services/filmes', () => ({ pesquisar: vi.fn() }))
const pesquisarMock = vi.mocked(pesquisar)

beforeEach(() => {
  pesquisarMock.mockReset().mockImplementation((termo: string) =>
    Promise.resolve(
      mapearLista(
        validos.filter((f) => f.titulo_filme.toLowerCase().includes(termo.toLowerCase())),
        mapearFilme,
      ),
    ),
  )
})

async function abrir(caminho: string) {
  const router = criarRouter(createMemoryHistory())
  await router.push(caminho)
  const wrapper = mount(App, { global: { plugins: [router] } })
  await flushPromises()
  return { wrapper, router }
}

async function buscar(wrapper: Awaited<ReturnType<typeof abrir>>['wrapper'], termo: string) {
  await wrapper.find('input[type="search"]').setValue(termo)
  await wrapper.find('form').trigger('submit')
  await vi.waitFor(() => expect(pesquisarMock.mock.calls.length + wrapper.findAll('.aviso').length).toBeGreaterThan(0))
  await flushPromises()
}

describe('Pesquisa', () => {
  it('estado inicial: pede um termo e não chama a API', async () => {
    const { wrapper } = await abrir('/pesquisa')
    expect(wrapper.text()).toContain('Digite o título de um filme para pesquisar.')
    expect(pesquisarMock).not.toHaveBeenCalled()
  })

  it('tem um título de página (h1) para leitores de tela', async () => {
    const { wrapper } = await abrir('/pesquisa')
    expect(wrapper.findAll('h1').map((h) => h.text())).toEqual(['Pesquisar filmes'])
  })

  it('enviar pesquisa coloca o termo na URL e mostra resultados', async () => {
    const { wrapper, router } = await abrir('/pesquisa')
    await buscar(wrapper, 'ação')
    expect(router.currentRoute.value.query.q).toBe('ação')
    expect(pesquisarMock).toHaveBeenCalledWith('ação', expect.anything())
    // Substring, como o LIKE %termo% do backend: "Coração" também contém "ação".
    expect(wrapper.findAll('.resultados .titulo').map((t) => t.text())).toEqual(['Coração em Seul', 'Ação e Reação'])
    expect(wrapper.findAll('.resultados a').map((a) => a.attributes('href'))).toEqual(['/filmes/11', '/filmes/12'])
  })

  it('abrir com ?q= (F5 ou link) refaz a busca e preenche o campo', async () => {
    const { wrapper } = await abrir('/pesquisa?q=noites')
    expect((wrapper.find('input').element as HTMLInputElement).value).toBe('noites')
    expect(wrapper.findAll('.resultados li')).toHaveLength(1)
  })

  it('sem resultados: mensagem do Flutter', async () => {
    const { wrapper } = await abrir('/pesquisa?q=inexistente')
    expect(wrapper.text()).toContain('Filme não localizado no catálogo')
  })

  it('termo com "/" é recusado sem chamar a API', async () => {
    const { wrapper } = await abrir('/pesquisa?q=a%2Fb')
    expect(wrapper.find('[role="alert"]').text()).toBe('A pesquisa não pode conter "/".')
    expect(pesquisarMock).not.toHaveBeenCalled()
  })

  it('só espaços não pesquisa', async () => {
    const { wrapper, router } = await abrir('/pesquisa')
    await wrapper.find('input').setValue('   ')
    await wrapper.find('form').trigger('submit')
    await flushPromises()
    expect(router.currentRoute.value.query.q).toBeUndefined()
    expect(pesquisarMock).not.toHaveBeenCalled()
  })

  it('o termo vai à API como digitado (sem trim, paridade com o Flutter)', async () => {
    await abrir('/pesquisa?q=%20dia')
    expect(pesquisarMock).toHaveBeenCalledWith(' dia', expect.anything())
  })

  it('erro mostra mensagem e "Tentar novamente" refaz a busca', async () => {
    pesquisarMock.mockRejectedValueOnce(new FalhaApi({ tipo: 'http', status: 502 }))
    const { wrapper } = await abrir('/pesquisa?q=riso')
    expect(wrapper.text()).toContain('O servidor encontrou um erro.')
    await wrapper.find('.pesquisa .estado button').trigger('click')
    await flushPromises()
    expect(wrapper.findAll('.resultados li')).toHaveLength(1)
  })

  it('voltar no navegador restaura o termo anterior', async () => {
    const { wrapper, router } = await abrir('/pesquisa?q=riso')
    await buscar(wrapper, 'noites')
    router.back()
    await vi.waitFor(() => expect(router.currentRoute.value.query.q).toBe('riso'))
    await flushPromises()
    expect((wrapper.find('input').element as HTMLInputElement).value).toBe('riso')
    expect(wrapper.find('.resultados .titulo').text()).toBe('Riso Solto')
  })
})
