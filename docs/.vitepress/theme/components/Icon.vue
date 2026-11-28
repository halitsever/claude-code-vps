<script setup lang="ts">
/** Inline icons sized to 1em and drawn in currentColor, so they follow the text they sit in. */
defineProps<{ name: "arrow" | "check" | "spark" | "dot" | "sep" | "plus" }>();
</script>

<template>
  <svg class="ic" viewBox="0 0 16 16" width="1em" height="1em" aria-hidden="true" focusable="false">
    <path v-if="name === 'arrow'" d="M2.5 8h10.5M9 4l4 4-4 4" />
    <path v-else-if="name === 'check'" d="M3 8.5l3.2 3.2L13 4.8" />
    <path v-else-if="name === 'spark'" d="M8 1.5v13M2.4 4.75l11.2 6.5M2.4 11.25l11.2-6.5" />
    <circle v-else-if="name === 'dot'" cx="8" cy="8" r="4.5" class="fill" />
    <path v-else-if="name === 'sep'" d="M8 0.5l1.9 5.6L15.5 8l-5.6 1.9L8 15.5l-1.9-5.6L0.5 8l5.6-1.9z" class="fill" />
    <path v-else d="M8 1.5v13M1.5 8h13" />
  </svg>
</template>

<style scoped>
.ic {
  display: inline-block;
  vertical-align: -0.125em;
  fill: none;
  stroke: currentColor;
  stroke-width: 1.8;
  stroke-linecap: round;
  stroke-linejoin: round;
}
.fill {
  fill: currentColor;
  stroke: none;
}
</style>
