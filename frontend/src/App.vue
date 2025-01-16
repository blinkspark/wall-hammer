<script setup lang="ts">
import { RouterLink, RouterView } from 'vue-router'
import Navbar from './components/Navbar.vue'
</script>

<template>
  <Navbar />
  <div class="container">
    <Suspense>
      <RouterView />
    </Suspense>
  </div>
</template>
