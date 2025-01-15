<script setup lang="ts">
import TheWelcome from '../components/TheWelcome.vue'
import { useNats } from '@/useNats';

let nc = await useNats();
nc.publish('test', 'hello world');
nc.subscribe('test', { callback: (msg) => console.log(msg) });
console.log(nc);
</script>

<template>
  <main>
    <TheWelcome />
  </main>
</template>
