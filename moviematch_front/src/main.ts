import { createApp } from 'vue'
import App from './App.vue'
import { criarRouter } from './router'
import './styles/tokens.css'
import './styles/base.css'

createApp(App).use(criarRouter()).mount('#app')
