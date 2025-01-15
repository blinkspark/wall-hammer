<script setup lang="ts">
import { ref, onMounted, getCurrentInstance } from 'vue';
import type { NatsConnection } from '@nats-io/nats-core';
let app = getCurrentInstance()!.appContext.app;
let nc = ref<NatsConnection | null>(null);
defineProps<{
  msg: string
}>()
let ii = setInterval(() => {
  nc.value = app.config.globalProperties.$nc;
  if (nc.value) {
    clearInterval(ii);
  }
}, 100)
</script>

<template>
  <div class="greetings">
    <h1 class="green" v-if="nc">NNNCCC</h1>
    <h1 class="green">{{ msg }}</h1>
    <h3>
      You’ve successfully created a project with
      <a href="https://vite.dev/" target="_blank" rel="noopener">Vite</a> +
      <a href="https://vuejs.org/" target="_blank" rel="noopener">Vue 3</a>. What's next?
    </h3>
  </div>
</template>

<style scoped>
h1 {
  font-weight: 500;
  font-size: 2.6rem;
  position: relative;
  top: -10px;
}

h3 {
  font-size: 1.2rem;
}

.greetings h1,
.greetings h3 {
  text-align: center;
}

@media (min-width: 1024px) {

  .greetings h1,
  .greetings h3 {
    text-align: left;
  }
}
</style>
