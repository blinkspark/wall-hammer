import './assets/main.css'

import { createApp } from 'vue'
import { createPinia } from 'pinia'
import { wsconnect, type NatsConnection } from '@nats-io/nats-core';


import App from './App.vue'
import router from './router'

const app = createApp(App)

app.use(createPinia())
app.use(router)
wsconnect({ servers: 'ws://localhost:23222' }).then((nc: NatsConnection) => {
    app.config.globalProperties.$nats = nc;
    console.log('Connected to NATS')
})


app.mount('#app')
