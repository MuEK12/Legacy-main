<!--
  CharacterCreator — Tela de criação de personagem.
  Segue o layout do study/creator.html: formulário com nome, sobrenome
  e seleção de gênero.
-->
<script setup>
import { ref } from "vue";
import User from "@icons/User.vue";
import Gender from "@icons/Gender.vue";
import CalendarDot from "@icons/CalendarDot.vue";

const props = defineProps({
    hasCharacters: { type: Boolean, default: false },
    minimumAge: { type: Number, default: 18 },
    maximumAge: { type: Number, default: 75 },
    creating: { type: Boolean, default: false },
});

const emit = defineEmits(["back", "create"]);

const name = ref("");
const lastname = ref("");
const age = ref(props.minimumAge);
const gender = ref("mp_m_freemode_01");
const nameError = ref("");

const incrementAge = () => { if (age.value < props.maximumAge) age.value++; };
const decrementAge = () => { if (age.value > props.minimumAge) age.value--; };

const namePattern = /^[a-zA-ZÀ-ÿ\s'-]+$/;

const validateName = (value) => {
    const trimmed = value.trim();
    if (!trimmed) return "";
    if (trimmed.length < 2) return "Mínimo 2 caracteres";
    if (!namePattern.test(trimmed)) return "Apenas letras, espaços e hífens";
    return "";
};

const onNameInput = () => {
    nameError.value = validateName(name.value);
};

const handleCreate = () => {
    const err = validateName(name.value) || validateName(lastname.value);
    if (err) { nameError.value = err; return; }
    if (!name.value.trim() || !lastname.value.trim()) return;
    if (props.creating) return;
    emit("create", name.value.trim(), lastname.value.trim(), gender.value, age.value);
};
</script>

<template>
    <div class="flex flex-col items-stretch gap-8 w-96 relative">
      <!-- Título -->
      <h1 class="text-4xl font-extrabold">CRIAÇÃO DE PERSONAGEM</h1>

      <!-- Formulário -->
      <div class="flex flex-col gap-3">
        <!-- Nome -->
        <div class="flex items-stretch gap-2 relative bg-from/60 rounded-lg">
          <label class="py-4 pl-4 flex items-center justify-center gap-1 pointer-events-none">
            <User class="size-4 min-w-4 text-main" />
            <span class="text-sm text-white/50">Nome:</span>
          </label>
          <input
            v-model="name"
            @input="onNameInput"
            type="text"
            placeholder="Digite seu nome"
            class="flex-1 bg-transparent flex items-center py-4 px-3 pr-4 text-white outline-none ring-0 border-none placeholder:text-white/50"
            maxlength="24"
          />
        </div>

        <!-- Sobrenome -->
        <div class="flex items-stretch gap-2 relative bg-from/60 rounded-lg">
          <label class="py-4 pl-4 flex items-center justify-center gap-1 pointer-events-none">
            <User class="size-4 min-w-4 text-main" />
            <span class="text-sm text-white/50">Sobrenome:</span>
          </label>
          <input
            v-model="lastname"
            @input="onNameInput"
            type="text"
            placeholder="Digite seu sobrenome"
            class="flex-1 bg-transparent flex items-center py-4 px-3 pr-4 text-white outline-none ring-0 border-none placeholder:text-white/50"
            maxlength="24"
          />
        </div>

        <!-- Idade -->
        <div class="relative flex items-stretch gap-2 bg-from/60 rounded-lg">
          <div class="py-4 pl-4 flex items-center justify-center gap-1 pointer-events-none">
            <CalendarDot class="size-4 min-w-4 text-main" />
            <span class="text-sm text-white/50">Idade:</span>
          </div>
          <div class="flex-1">
            <div class="size-full flex items-center justify-between px-3">
              <button
                @click="decrementAge"
                :disabled="age <= minimumAge"
                :class="[
                    'w-8 h-8 flex items-center justify-center rounded transition-colors text-base font-bold',
                    age > minimumAge
                        ? 'bg-main text-mainText hover:bg-mainHover cursor-pointer'
                        : 'bg-white/5 text-white/20 cursor-default',
                ]"
              >
                −
              </button>
              <span class="text-white font-bold text-lg tabular-nums select-none">{{ age }}</span>
              <button
                @click="incrementAge"
                :disabled="age >= maximumAge"
                :class="[
                    'w-8 h-8 flex items-center justify-center rounded transition-colors text-base font-bold',
                    age < maximumAge
                        ? 'bg-main text-mainText hover:bg-mainHover cursor-pointer'
                        : 'bg-white/5 text-white/20 cursor-default',
                ]"
              >
                +
              </button>
            </div>
          </div>
        </div>

        <!-- Gênero -->
        <div class="relative flex items-stretch gap-2 bg-from/60 rounded-lg">
          <div class="py-4 pl-4 flex items-center justify-center gap-1 pointer-events-none">
            <Gender class="size-4 min-w-4 text-main" />
            <span class="text-sm text-white/50">Gênero:</span>
          </div>
          <div class="flex-1 p-1">
            <div class="relative size-full flex items-center">
              <div
                :class="[
                  'absolute top-0 left-0 w-1/2 h-full rounded-md transition-all bg-main',
                  gender === 'mp_f_freemode_01' ? 'translate-x-full' : '',
                ]"
              ></div>
              <p
                @click="gender = 'mp_m_freemode_01'"
                :class="[
                  'h-full cursor-pointer relative flex-1 text-center flex items-center justify-center rounded-md transition-colors',
                  gender === 'mp_m_freemode_01' ? 'text-mainText' : '',
                ]"
              >
                Masculino
              </p>
              <p
                @click="gender = 'mp_f_freemode_01'"
                :class="[
                  'h-full cursor-pointer relative flex-1 text-center flex items-center justify-center rounded-md transition-colors',
                  gender === 'mp_f_freemode_01' ? 'text-mainText' : '',
                ]"
              >
                Feminino
              </p>
            </div>
          </div>
        </div>
      </div>

      <!-- Erro de validação -->
      <p v-if="nameError" class="text-sm text-red-400 -mt-4">{{ nameError }}</p>

      <!-- Botão criar -->
      <button
        @click="handleCreate"
        :disabled="!name.trim() || !lastname.trim() || creating"
        class="flex items-center justify-center h-14 rounded-lg transition-colors"
        :class="name.trim() && lastname.trim() && !creating
          ? 'bg-main hover:bg-mainHover cursor-pointer'
          : 'bg-main/25 text-white/30 cursor-default'"
      >
        {{ creating ? "Criando..." : "Criar" }}
      </button>

      <!-- Link para seleção -->
      <p v-if="hasCharacters" class="text-lg text-white/50">
        Já tem um personagem?
        <a @click.prevent="emit('back')" href="#/" class="text-white font-bold">Selecionar</a>
      </p>
    </div>
</template>
