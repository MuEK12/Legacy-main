<script setup>
import { ref, computed, onMounted, onUnmounted } from "vue";
import { useSettingsStore } from "@stores/settings";
import { useSpawnStore } from "@stores/spawn";
import setTheme from "@utils/setTheme";
import loadTheme from "@utils/loadTheme";
import fetchNui from "@utils/fetchNui";
import CharacterList from "./views/CharacterList.vue";
import CharacterInfo from "./views/CharacterInfo.vue";
import CharacterCreator from "./views/CharacterCreator.vue";
import SpawnLocations from "./views/SpawnLocations.vue";
import SpawnConfirm from "./views/SpawnConfirm.vue";
import Notify from "./views/Notify.vue";
import Scribble from "@icons/Scribble.vue";
import Dollar from "@icons/Dollar.vue";
import LockClosed from "@icons/LockClosed.vue";
import Close from "@icons/Close.vue";
import Shield from "@icons/Shield.vue";

const settings = useSettingsStore();
const spawn = useSpawnStore();
const isDev = import.meta.env.DEV;
const showDecor = ref(true);
const creating = ref(false);

const handleSelectCharacter = (p) => fetchNui("CharacterChosen", { Passport: p });
const handleNewCharacter = async (n, l, g, a) => {
    creating.value = true;
    await fetchNui("NewCharacter", { Name: n, Lastname: l, Gender: g, Age: a });
    creating.value = false;
};
const handleChosen = (i) => fetchNui("Chosen", { Index: i });
const handleSpawn = () => fetchNui("Spawn");
const handlePurchaseSlot = () => fetchNui("PurchaseSlot");

const handleLocationSelect = (index) => {
    spawn.selectLocation(index);
    handleChosen(index);
};
const showRightBg = computed(() => spawn.view === "select" || spawn.view === "spawn");

const handleMessage = (event) => {
  const action = event.data.name || event.data.Action;
  const payload = event.data.Payload || event.data.data || {};
  if (action === "Config") { settings.display = true; spawn.setConfig(payload); }
  else if (action === "Close") { settings.display = false; spawn.close(); }
  else if (action === "Location") { settings.display = true; spawn.setLocations(Array.isArray(payload) ? payload : []); }
  else if (action === "Gemstone") { settings.gemstone = payload; spawn.setGemstone(payload); }
  else if (action === "Request") { spawn.openPopup(payload); }
  else if (action === "Increment") { spawn.incrementLocations(Array.isArray(payload) ? payload : []); }
  else if (action === "Notify") { spawn.addNotification({ type: payload.Type || "verde", title: payload.Title || "", message: payload.Message || "" }); }
};

const confirmPurchase = () => {
  spawn.closePopup();
  handlePurchaseSlot();
};

onMounted(async () => {
  const theme = document.body.getAttribute("theme");
  if (theme) setTheme(theme);
  const td = await loadTheme();
  if (td?.shop?.scribble !== undefined) showDecor.value = td.shop.scribble !== false;
  window.addEventListener("message", handleMessage);

  // Dispara a NUI callback "Config" no Lua — isso finaliza a
  // resource loading screen (ShutdownLoadingScreen / ShutdownLoadingScreenNui)
  // e retorna os dados dos personagens.
  const config = await fetchNui("Config");
  if (config && config.Characters) {
    settings.display = true;
    spawn.setConfig(config);
  }
});
onUnmounted(() => window.removeEventListener("message", handleMessage));
</script>

<template>
<div class="size-full flex items-center justify-center">
  <div v-if="isDev" class="fixed inset-0 pointer-events-none overflow-hidden">
    <div class="absolute inset-0 size-full bg-wallpaper"></div>
  </div>

  <transition name="bg-fade">
    <div v-show="settings.display" class="absolute z-0 top-0 left-0 size-full bg-default pointer-events-none">
      <template v-if="showDecor">
        <Scribble class="absolute -top-[25rem] -left-[17.5rem] w-[50rem] h-[50rem] opacity-5 text-main" />
        <div class="absolute -top-[34.5rem] -left-[30rem] w-[60rem] h-[60rem] opacity-40 bg-shadow-circle"></div>
        <Scribble class="absolute -top-[29.5rem] -left-[25rem] w-[50rem] h-[50rem] text-main" />
        <div class="absolute -top-[17.5rem] -left-[15.5rem] w-[60rem] h-[60rem] opacity-20 bg-shadow-circle"></div>
      </template>
    </div>
  </transition>

  <transition name="bg-fade">
    <div v-show="settings.display && showRightBg" class="absolute z-0 top-0 right-0 size-full bg-default-inverted pointer-events-none">
      <template v-if="showDecor">
        <Scribble class="absolute -bottom-[14.5rem] -right-[12rem] w-[50rem] h-[50rem] opacity-5 text-main" />
        <div class="absolute -bottom-[15rem] -right-[8.25rem] w-[46rem] h-[45rem] opacity-40 bg-shadow-circle"></div>
        <Scribble class="absolute -bottom-[12.5rem] -right-[5.75rem] w-[36rem] h-[35rem] text-main" />
        <div class="absolute -bottom-[20.5rem] -right-[17.5rem] w-[60rem] h-[60rem] opacity-20 bg-shadow-circle"></div>
      </template>
    </div>
  </transition>

  <transition name="fade" mode="out-in">
    <div v-if="settings.display" class="absolute z-0 top-0 left-0 size-full pointer-events-auto">
      <template v-if="spawn.view === 'select'">
        <div class="size-full overflow-hidden flex flex-col justify-center py-32 relative z-10 !duration-200">
          <div class="absolute top-[10%] right-32 -translate-y-full flex items-center gap-2.5">
            <Dollar class="size-5 min-w-5 min-h-5 text-white/75" />
            <div class="text-sm font-medium h-[1.625rem] bg-white/20 px-2.5 rounded flex items-center uppercase tracking-widest whitespace-nowrap">{{ spawn.gemstone.toLocaleString("pt-BR") }}</div>
          </div>
          <div class="w-full max-h-full flex flex-col items-stretch justify-center gap-8">
            <div class="flex items-end justify-between px-32">
              <h1 class="w-80 text-4xl font-extrabold">SELEÇÃO DE PERSONAGEM</h1>
              <div class="w-80 flex flex-col items-end">
                <div class="flex items-center gap-2">
                  <p class="text-white/50 text-2xl leading-3">{{ spawn.selectedCharacter ? '#'+spawn.selectedCharacter.passport : '' }}</p>
                  <span
                    v-if="spawn.selectedCharacter?.admin"
                    class="inline-flex items-center gap-1 bg-reject-background/30 text-reject-letter text-xs font-bold px-2 py-0.5 rounded uppercase tracking-wider"
                  ><Shield class="size-3 min-w-3 min-h-3 -mt-0.5" />Admin</span>
                </div>
                <h3 class="w-full text-right font-extrabold text-4xl">{{ spawn.selectedCharacter?.name || '' }}</h3>
              </div>
            </div>
            <div class="flex-1 overflow-hidden flex items-stretch justify-between px-32">
              <div class="w-80 h-full pt-3 overflow-hidden overflow-y-auto scrollbar-hide flex flex-col items-stretch gap-3">
                <CharacterList :characters="spawn.characters" :selectedIndex="spawn.selectedIndex" :gemstone="spawn.gemstone" :slotPrice="spawn.slotPrice" :lockedSlots="spawn.lockedSlots" @select="spawn.selectCharacter" @create="spawn.goToCreator" @buy-slot="spawn.openPopup(spawn.slotPrice)" />
              </div>
              <div class="flex flex-col items-stretch w-80 pt-3 relative">
                <CharacterInfo :character="spawn.selectedCharacter" :formattedBank="spawn.formattedBank" />
              </div>
            </div>
          </div>
          <button
            @click="handleSelectCharacter(spawn.selectedCharacter?.passport)"
            :disabled="!spawn.selectedCharacter"
            :class="[
                'absolute bottom-32 right-32 w-64 flex items-center justify-center h-14 rounded-lg transition-colors',
                spawn.selectedCharacter
                    ? 'bg-main hover:bg-mainHover cursor-pointer'
                    : 'bg-main/25 text-white/30 cursor-default',
            ]"
          >
            Selecionar
          </button>
        </div>
      </template>
      <template v-else-if="spawn.view === 'creator'">
        <div class="size-full flex items-center gap-40 p-32 relative z-10 !duration-200">           <CharacterCreator :hasCharacters="spawn.characters.length > 0" :minimumAge="spawn.minimumAge" :maximumAge="spawn.maximumAge" :creating="creating" @back="spawn.goToSelect" @create="handleNewCharacter" />
        </div>
      </template>
      <template v-else-if="spawn.view === 'spawn'">
        <div class="size-full relative py-32 flex items-center justify-between z-10 !duration-200">
          <div class="max-h-[90%] flex flex-col gap-8 pl-32">
            <SpawnLocations :locations="spawn.locations" :selectedIndex="spawn.selectedLocation" @select="handleLocationSelect" />
          </div>
          <SpawnConfirm :selectedIndex="spawn.selectedLocation" :hasLocations="spawn.locations.length > 0" @confirm="handleSpawn" />
        </div>
      </template>
    </div>
  </transition>

  <Notify :notifications="spawn.notifications" />

  <Teleport to="body">
    <transition name="overlay">
      <div v-if="spawn.showPopup" class="fixed inset-0 z-[9995]">
        <div class="absolute inset-0 popup-overlay" @click="spawn.closePopup"></div>
      </div>
    </transition>
    <transition name="zoom">
      <div v-if="spawn.showPopup" class="fixed inset-0 flex items-center justify-center p-8 z-[9996] pointer-events-none">
        <div class="relative bg-from/80 p-7 rounded-2xl shadow-sm flex flex-col w-[35rem] pointer-events-auto">
          <div class="overflow-hidden rounded-lg bg-white/[0.025] ring-1 ring-white/5 p-5 px-7 flex items-center justify-between mb-8">
            <div class="flex items-center gap-4">
              <LockClosed class="w-5 h-5 min-w-max text-main" />
              <p class="font-extrabold text-lg">Comprar slot extra</p>
            </div>
            <Close class="w-4 h-4 text-white/20 min-w-max transition-colors hover:text-white/50 cursor-pointer" @click="spawn.closePopup" />
          </div>
          <p class="text-center text-white/50">Deseja confirmar a compra de um slot extra por <span class="font-medium text-white"><Dollar class="size-4 inline -mt-1 mr-1" />{{ spawn.slotPrice.toLocaleString("pt-BR") }}</span>?</p>
          <div class="w-full flex flex-col items-center text-center mt-8">
            <button
              @click="confirmPurchase"
              :disabled="spawn.gemstone < spawn.slotPrice"
              class="rounded-lg py-3 px-16 flex items-center gap-2 transition-colors bg-main hover:bg-mainHover text-mainText disabled:bg-main/50 disabled:hover:bg-main/50 disabled:text-mainText/50"
            ><p>Confirmar</p></button>
          </div>
        </div>
      </div>
    </transition>
  </Teleport>

</div>
</template>
