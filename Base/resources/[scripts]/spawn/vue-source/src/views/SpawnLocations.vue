<!-- SpawnLocations — Painel esquerdo: lista de localizações (study: pl-32, w-80 list) -->
<script setup>
const props = defineProps({
    locations: { type: Array, default: () => [] },
    selectedIndex: { type: Number, default: 0 },
});

const emit = defineEmits(["select"]);
</script>

<template>
    <h1 class="w-80 text-4xl font-extrabold">SELEÇÃO DE LOCALIZAÇÃO</h1>
    <div class="w-80 overflow-hidden overflow-y-auto scrollbar-hide space-y-3">
        <div
            v-for="(loc, index) in locations"
            :key="index"
            @click="emit('select', index)"
            :class="[
                'w-full font-medium flex items-center justify-between gap-2 bg-from/60 rounded-lg py-5 px-4 transition-colors',
                selectedIndex === index
                    ? 'bg-main text-mainText cursor-default'
                    : 'cursor-pointer hover:bg-from/80',
            ]"
        >
            {{ loc.Name || 'Última Localização' }}
        </div>
        <div v-if="!locations.length" class="w-full text-center py-8 text-white/50">
            Nenhuma localização disponível.
        </div>
    </div>
</template>
