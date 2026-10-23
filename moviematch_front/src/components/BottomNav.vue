<template>
  <nav
    class="navegacao"
    aria-label="Navegação principal"
  >
    <RouterLink
      :to="{ name: 'inicio' }"
      class="item"
    >
      <svg
        aria-hidden="true"
        viewBox="0 0 24 24"
        width="24"
        height="24"
      >
        <path
          d="M3 11.5 12 4l9 7.5V20a1 1 0 0 1-1 1h-5v-6H9v6H4a1 1 0 0 1-1-1z"
          fill="currentColor"
        />
      </svg>
      <span>Início</span>
    </RouterLink>
    <RouterLink
      :to="{ name: 'questionario' }"
      class="item"
    >
      <svg
        aria-hidden="true"
        viewBox="0 0 24 24"
        width="24"
        height="24"
      >
        <path
          d="M5 4h14v2H5zm0 5h14v2H5zm0 5h9v2H5zm0 5h9v2H5zm12-2 2 2 3-4 1.4 1.1L19 21.5l-3.4-3.4z"
          fill="currentColor"
        />
      </svg>
      <span>Questionário</span>
    </RouterLink>
  </nav>
</template>

<style scoped>
.navegacao {
  position: fixed;
  inset: auto 0 0;
  display: flex;
  justify-content: center;
  gap: var(--espaco-6);
  height: var(--altura-navegacao);
  padding: 0 var(--espaco-4);
  background: var(--cor-azul);
}

.item {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  min-width: 64px;
  min-height: 44px;
  color: var(--cor-texto-secundario);
  font-size: 0.75rem;
  text-decoration: none;
}

.item[aria-current='page'] {
  color: var(--cor-texto);
  font-weight: 600;
}
</style>
