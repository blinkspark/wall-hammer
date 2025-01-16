<script setup lang="ts">
import { RouterLink } from 'vue-router'
import { useTemplateRef } from 'vue'
const burger = useTemplateRef('burger')
function burgerClick(e: MouseEvent) {
  burger.value!.classList.toggle('is-active')
}
</script>
<template>
  <nav class="navbar">
    <div class="container">
      <div class="navbar-brand">
        <RouterLink to="/" class="navbar-item">
          <img class="icon" src="/favicon.ico" alt="" />
          <span class="has-text-weight-bold has-text-light">Logo</span>
        </RouterLink>

        <a
          class="navbar-burger"
          role="button"
          aria-label="menu"
          aria-expanded="false"
          @click="burgerClick"
          ref="burger"
        >
          <span aria-hidden="true"></span>
          <span aria-hidden="true"></span>
          <span aria-hidden="true"></span>
          <span aria-hidden="true"></span>
        </a>
      </div>
    </div>
  </nav>
</template>
<style scoped>
.icon {
  margin-top: 0.2rem;
  height: 2rem;
  width: 2rem;
}
.navbar {
  margin-bottom: 1rem;
}
</style>
