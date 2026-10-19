<!--
  Notify — Sistema de notificações toast.
  Segue o estilo do study/notify.html: cards no topo central com
  transition top-center e barra de progresso que vai de 100% → 0%.
-->
<script setup>
import Check from "@icons/Check.vue";
import Warning from "@icons/Warning.vue";
import Cloud from "@icons/Cloud.vue";

const props = defineProps({
  notifications: { type: Array, default: () => [] },
});

const getColor = (type) => {
  if (type === "amarelo") return "rgb(255, 200, 50)";
  if (type === "vermelho") return "rgb(220, 80, 80)";
  if (type === "clima") return "rgb(56, 189, 248)";
  return "rgb(107, 197, 61)"; // verde
};

const getIcon = (type) => {
  if (type === "amarelo") return "warning";
  if (type === "clima") return "cloud";
  return "check";
};
</script>

<template>
  <ul class="absolute top-6 left-1/2 -translate-x-1/2 flex flex-col items-center gap-4 z-[9999] pointer-events-none">
    <TransitionGroup name="top-center">
      <li
        v-for="n in notifications"
        :key="n.id"
        class="flex items-center gap-4 bg-from/60 px-4 pt-4 pb-5 rounded-lg w-96 min-w-96 max-w-96 relative overflow-hidden pointer-events-auto"
      >
        <!-- Ícone -->
        <div
          class="size-9 min-w-9 min-h-9 bg-from/50 rounded-md flex items-center justify-center"
          :style="{ color: getColor(n.type) }"
        >
          <Check v-if="getIcon(n.type) === 'check'" class="size-6 min-w-max" />
          <Warning v-else-if="getIcon(n.type) === 'warning'" class="size-6 min-w-max" />
          <Cloud v-else class="size-6 min-w-max" />
        </div>

        <!-- Texto -->
        <div>
          <h1 class="font-bold">{{ n.title }}</h1>
          <p
            class="text-sm text-white/50"
            :style="{ '--highlight': getColor(n.type) }"
            v-html="n.message"
          ></p>
        </div>

        <!-- Barra de progresso: 100% → 0% -->
        <div class="absolute bottom-0 left-0 w-full h-1 bg-from/20">
          <div
            class="w-full h-full animate-progress"
            :style="{
              backgroundColor: getColor(n.type),
              '--timeout': '5050ms',
            }"
          ></div>
        </div>
      </li>
    </TransitionGroup>
  </ul>
</template>

<style scoped>
:deep(b) {
  font-weight: 700;
  color: var(--highlight, rgb(255, 200, 50));
}
</style>
