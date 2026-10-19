<!-- SpawnConfirm — Botão absoluto bottom-right (study: absolute bottom-32 right-32 w-64) -->
<script setup>
const props = defineProps({
    selectedIndex: { type: Number, default: 0 },
    hasLocations: { type: Boolean, default: false },
});

const emit = defineEmits(["confirm"]);

const handleConfirm = () => {
    if (props.selectedIndex < 0 || !props.hasLocations) return;
    emit("confirm", props.selectedIndex);
};
</script>

<template>
    <button
        @click="handleConfirm"
        :disabled="selectedIndex < 0 || !hasLocations"
        :class="[
            'absolute bottom-32 right-32 w-64 flex items-center justify-center h-14 rounded-lg transition-colors',
            selectedIndex >= 0 && hasLocations
                ? 'bg-main hover:bg-mainHover cursor-pointer'
                : 'bg-main/25 text-white/30 cursor-default',
        ]"
    >
        Selecionar
    </button>
</template>
