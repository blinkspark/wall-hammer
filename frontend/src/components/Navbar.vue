<script setup lang="ts">
import { RouterLink } from 'vue-router'
import { useTemplateRef } from 'vue'
const burger = useTemplateRef('burger')
const navbarMenu = useTemplateRef('navbarMenu')
function burgerClick(e: MouseEvent) {
  burger.value!.classList.toggle('is-active')
  navbarMenu.value!.classList.toggle('is-active')
}
</script>
<template>
  <nav class="navbar">
    <div class="container">
      <div class="navbar-brand">
        <RouterLink to="/" class="navbar-item">
          <img class="icon" src="/favicon.ico" alt="" />
          <span class="has-text-weight-bold has-text-light">Wall Hammer</span>
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
      
      <div class="navbar-menu" ref="navbarMenu">
        <div class="navbar-start">
          <RouterLink to="/about" class="navbar-item">About</RouterLink>
        </div>
        <div class="navbar-end">
          <RouterLink to="/login" class="navbar-item">Login</RouterLink>
          <RouterLink to="/register" class="navbar-item">Register</RouterLink>
        </div>
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
