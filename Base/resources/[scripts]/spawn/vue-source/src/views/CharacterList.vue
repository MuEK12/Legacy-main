<!-- CharacterList — Itens da lista de personagens (sem popup, sem wrapper externo) -->
<script setup>
import CirclePlus from "@icons/CirclePlus.vue";
import LockOpen from "@icons/LockOpen.vue";
import LockClosed from "@icons/LockClosed.vue";
import Shield from "@icons/Shield.vue";

const props = defineProps({
    characters: { type: Array, required: true },
    selectedIndex: { type: Number, default: -1 },
    gemstone: { type: Number, default: 0 },
    slotPrice: { type: Number, default: 0 },
    lockedSlots: { type: Array, default: () => [] },
});

const emit = defineEmits(["select", "create", "buy-slot"]);
</script>

<template>
    <!-- Lista de personagens -->
    <template v-for="(char, index) in characters" :key="char.passport">
        <div
            @click="emit('select', index)"
            :class="[
                'w-full font-medium flex items-center justify-between gap-2 rounded-lg py-5 px-4 transition-colors',
                selectedIndex === index
                    ? 'bg-main text-mainText cursor-default'
                    : 'bg-from/60 cursor-pointer hover:bg-from/80',
            ]"
        >
            <p>{{ char.name }}</p>
            <div class="flex items-center gap-1.5 opacity-50">
                <p>#{{ char.passport }}</p>
                <Shield v-if="char.admin" class="size-3.5 min-w-3.5 min-h-3.5 text-reject-letter -mt-0.5" />
            </div>
        </div>
    </template>

    <!-- Criar novo personagem -->
    <div
        @click="emit('create')"
        class="w-full font-medium flex items-center justify-between gap-2 bg-from/40 rounded-lg py-5 px-4 transition cursor-pointer hover:bg-from/80"
    >
        <p>Criar um novo personagem</p>
        <CirclePlus class="size-5 text-main" />
    </div>

    <!-- Slots bloqueados -->
    <template v-for="lockedIndex in lockedSlots" :key="'locked-' + lockedIndex">
        <div
            @click="emit('buy-slot')"
            class="w-full flex items-center justify-between gap-2 bg-from/40 rounded-lg py-5 px-4 group transition cursor-pointer hover:bg-from/80"
        >
            <div class="flex-1 relative text-white/50">
                <p class="absolute top-0 left-0 opacity-0 transition-opacity group-hover:opacity-100">Comprar slot extra</p>
                <p class="transition-opacity group-hover:opacity-0">Slot bloqueado</p>
            </div>
            <div class="relative text-white/50">
                <LockOpen class="size-5 min-w-5 absolute top-0 left-0 opacity-0 transition-opacity group-hover:opacity-100" />
                <LockClosed class="size-5 min-w-5 transition-opacity group-hover:opacity-0" />
            </div>
        </div>
    </template>
</template>
