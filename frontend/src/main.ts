import './assets/main.css'

import { createApp } from 'vue'
import { createPinia } from 'pinia'
import { wsconnect, type NatsConnection } from '@nats-io/nats-core'
import { useNats } from './useNats'

import App from './App.vue'
import router from './router'

const app = createApp(App)

app.use(createPinia())
app.use(router)
useNats() // init nats connection.

app.mount('#app')
