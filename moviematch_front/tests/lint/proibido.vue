<script setup lang="ts">
const salvo = localStorage.getItem('x')
const outro = window.sessionStorage.getItem('y')
const html = `${salvo}${outro}`
</script>

<template>
  <div v-html="html" />
</template>
