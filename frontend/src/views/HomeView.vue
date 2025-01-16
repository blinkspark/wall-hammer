<script setup lang="ts">
import { useNats } from '@/useNats'

let nc = await useNats()
</script>

<template>
  <main>
    <h1>Home</h1>
  </main>
</template>
