import './assets/main.css'

import { createApp } from 'vue'
import { createPinia } from 'pinia'
import { wsconnect, type NatsConnection } from '@nats-io/nats-core';


import App from './App.vue'
import router from './router'

const app = createApp(App)

wsconnect({ servers: 'ws://localhost:23223' }).then((nc: NatsConnection) => {
    app.config.globalProperties.$nc = nc;
}).catch((err) => {
    console.error("Error connecting to NATS", err);
})
app.use(createPinia())
app.use(router)

app.mount('#app')
