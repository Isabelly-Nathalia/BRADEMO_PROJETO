import { createRouter, createWebHistory, type RouteRecordRaw, type RouterHistory } from 'vue-router'
import NaoEncontrado from '../pages/NaoEncontrado.vue'
import { usePrimeiraVisita } from '../composables/usePrimeiraVisita'

declare module 'vue-router' {
  interface RouteMeta {
    titulo: string
  }
}

const SUFIXO_TITULO = 'MovieMatch'

export const rotas: RouteRecordRaw[] = [
  // A-04: boas-vindas só na primeira visita; depois, direto para o início.
  {
    path: '/',
    redirect: () => (usePrimeiraVisita().jaVisitou() ? { name: 'inicio' } : { name: 'boas-vindas' }),
    meta: { titulo: SUFIXO_TITULO },
  },
  {
    path: '/boas-vindas',
    name: 'boas-vindas',
    component: () => import('../pages/BoasVindas.vue'),
    meta: { titulo: 'Boas-vindas' },
  },
  {
    path: '/inicio',
    name: 'inicio',
    component: () => import('../pages/Inicio.vue'),
    meta: { titulo: 'Início' },
  },
  {
    path: '/pesquisa',
    name: 'pesquisa',
    component: () => import('../pages/Pesquisa.vue'),
    meta: { titulo: 'Pesquisa' },
  },
  {
    path: '/streaming/:slug',
    name: 'streaming',
    component: () => import('../pages/Streaming.vue'),
    meta: { titulo: 'Streaming' },
  },
  {
    path: '/filmes/:id(\\d+)',
    name: 'filme',
    component: () => import('../pages/FilmeDetalhe.vue'),
    meta: { titulo: 'Filme' },
  },
  {
    path: '/questionario/:passo([1-8])?',
    name: 'questionario',
    component: () => import('../pages/Questionario.vue'),
    meta: { titulo: 'Questionário' },
  },
  {
    path: '/sugestoes',
    name: 'sugestoes',
    component: () => import('../pages/Sugestoes.vue'),
    meta: { titulo: 'Sugestões' },
  },
  {
    path: '/:caminho(.*)*',
    name: 'nao-encontrado',
    component: NaoEncontrado,
    meta: { titulo: 'Página não encontrada' },
  },
]

export function tituloDaPagina(titulo: string): string {
  return titulo === SUFIXO_TITULO ? titulo : `${titulo} · ${SUFIXO_TITULO}`
}

export function criarRouter(history: RouterHistory = createWebHistory()) {
  const router = createRouter({
    history,
    routes: rotas,
    scrollBehavior: (_para, _de, posicaoSalva) => posicaoSalva ?? { top: 0 },
  })
  router.afterEach((para) => {
    document.title = tituloDaPagina(para.meta.titulo)
  })
  return router
}
