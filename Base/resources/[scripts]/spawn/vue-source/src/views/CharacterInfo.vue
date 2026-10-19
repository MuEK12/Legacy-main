<!-- CharacterInfo — Painel direito: informações do personagem selecionado -->
<script setup>

import BloodDrop from "@icons/BloodDrop.vue";
import Wallet from "@icons/Wallet.vue";
import Calendar from "@icons/Calendar.vue";
import CalendarDot from "@icons/CalendarDot.vue";
import PedFace from "@icons/PedFace.vue";
import BirthdayCake from "@icons/BirthdayCake.vue";
import Briefcase from "@icons/Briefcase.vue";

const props = defineProps({
    character: { type: Object, default: null },
    formattedBank: { type: String, default: "$0" },
});

const formatDate = (unix) => {
    if (!unix) return "—";
    return new Date(Number(unix) * 1000).toLocaleDateString("pt-BR", {
        day: "2-digit", month: "2-digit", year: "numeric", hour: "2-digit", minute: "2-digit",
    });
};

const defaultSkins = ["mp_m_freemode_01", "mp_f_freemode_01"];
const hasCustomSkin = (skin) => skin && !defaultSkins.includes(skin);

const lightenHex = (hex, amount = 80) => {
    if (!hex || hex.length < 7) return "";
    const r = Math.min(255, parseInt(hex.slice(1, 3), 16) + amount);
    const g = Math.min(255, parseInt(hex.slice(3, 5), 16) + amount);
    const b = Math.min(255, parseInt(hex.slice(5, 7), 16) + amount);
    return `#${r.toString(16).padStart(2, "0")}${g.toString(16).padStart(2, "0")}${b.toString(16).padStart(2, "0")}`;
};
</script>

<template>
    <div v-if="character" class="flex flex-col gap-3">
        <div class="bg-from/60 rounded-lg p-4 space-y-2">
            <p class="font-medium">
                <span class="font-normal text-white/50">
                    <BirthdayCake class="size-4 inline -mt-1 mr-2 text-main" />
                    Idade:
                </span>
                {{ character.age }}
            </p>
            <p class="font-medium">
                <span class="font-normal text-white/50">
                    <BloodDrop class="size-4 inline -mt-1 mr-2 text-main" />
                    Típo sanguíneo:
                </span>
                {{ character.blood }}
            </p>
            <p class="font-medium">
                <span class="font-normal text-white/50">
                    <Wallet class="size-4 inline -mt-1 mr-2 text-main" />
                    Banco:
                </span>
                {{ formattedBank }}
            </p>
            <p class="font-medium">
                <span class="font-normal text-white/50">
                    <Calendar class="size-4 inline -mt-1 mr-2 text-main" />
                    Último login:
                </span>
                {{ formatDate(character.lastLogin) }}
            </p>
            <p class="font-medium">
                <span class="font-normal text-white/50">
                    <CalendarDot class="size-4 inline -mt-1 mr-2 text-main" />
                    Criado em:
                </span>
                {{ formatDate(character.createdAt) }}
            </p>
        </div>

        <div v-if="hasCustomSkin(character.skin)" class="bg-from/60 rounded-lg p-4 space-y-2">
            <p class="font-medium">
                <span class="font-normal text-white/50">
                    <PedFace class="size-4 inline -mt-1 mr-2 text-main" />
                    Ped até:
                </span>
                {{ character.ped ? formatDate(character.ped) : "—" }}
            </p>
        </div>

        <div
            class="rounded-lg p-4 space-y-2"
            :style="character.jobColor
                ? { backgroundColor: character.jobColor + '80' }
                : { backgroundColor: 'rgb(var(--from) / 0.6)' }"
        >
            <p class="font-medium">
                <span class="font-normal text-white/50">
                    <Briefcase
                        class="size-4 inline -mt-1 mr-2"
                        :class="character.jobColor ? '' : 'text-main'"
                        :style="character.jobColor ? { color: lightenHex(character.jobColor) } : {}"
                    />
                    Profissão:
                </span>
                {{ character.job }}
            </p>
        </div>

    </div>
</template>
