import { defineStore, acceptHMRUpdate } from "pinia";

/**
 * Spawn store — gerencia personagens, slots, localizações e estado da interface.
 *
 * Fluxo NUI:
 *   1. Client envia "Config" com { Characters, Slots, Gemstone, SlotPrice }
 *   2. Interface mostra seleção de personagem (CharacterSelect)
 *   3. Usuário seleciona ou cria personagem → NUI callbacks
 *   4. Client envia "Location" com { Payload = [{ Coords, Name }] }
 *   5. Interface mostra seleção de localização (SpawnLocation)
 *   6. Client envia "Close" → fecha interface
 *   7. Client envia "Request" com { Payload = SkinMontlyPrice } → popup de compra
 *   8. Client envia "Notify" com { Payload = { Type, Title, Message } } → toast
 *   9. Client envia "Increment" com { Payload = [{ Coords, Name }] } → adiciona locations
 */

/**
 * Normaliza um personagem recebido do Lua para o formato da interface.
 */
export const normalizeCharacter = (char) => ({
  passport: char.Passport,
  name: char.Name || "",
  skin: char.Skin || "mp_m_freemode_01",
  age: char.Age || 18,
  bank: char.Bank || 0,
  job: char.Job || "Desempregado(a)",
  jobColor: char.JobColor || "",
  admin: char.Admin || false,
  ped: char.Ped || null,
  lastLogin: char.LastLogin || null,
  createdAt: char.CreatedAt || null,
  blood: char.Blood || "",
  playing: char.Playing || false,
  clothes: char.Clothes || {},
  barber: char.Barber || {},
  tattoos: char.Tattoos || {},
});

export const useSpawnStore = defineStore("spawn", {
  state: () => ({
    // Dados recebidos do Config
    characters: [],
    slots: 0,
    slotPrice: 0,
    gemstone: 0,

    // Personagem selecionado na lista
    selectedIndex: -1,

    // Localizações (recebidas via "Location" e "Increment")
    locations: [],
    selectedLocation: -1,

    // Idade min/máx
    minimumAge: 18,
    maximumAge: 75,

    // View atual: "select" | "creator" | "spawn"
    view: "select",
    // View anterior (para direção da transição)
    previousView: null,

    // Popup de compra de slot
    showPopup: false,
    popupPrice: 0,

    // Notificações (toast)
    notifications: [],
  }),

  getters: {
    /** Personagem selecionado (null se nenhum) */
    selectedCharacter(state) {
      if (state.selectedIndex < 0 || state.selectedIndex >= state.characters.length) {
        return null;
      }
      return state.characters[state.selectedIndex];
    },

    /** Slots ocupados */
    usedSlots(state) {
      return state.characters.length;
    },

    /** Slots bloqueados (pra comprar) */
    lockedSlots(state) {
      const locked = [];
      for (let i = state.characters.length; i < state.slots; i++) {
        locked.push(i);
      }
      // Sempre mostrar pelo menos 2 slots bloqueados extras para compra
      const minExtra = 2;
      const extra = Math.max(0, minExtra - locked.length);
      for (let i = 0; i < extra; i++) {
        locked.push(state.slots + i);
      }
      return locked;
    },

    /** Formata bank para exibição */
    formattedBank(state) {
      if (!state.selectedCharacter) return "$0";
      return `$${state.selectedCharacter.bank.toLocaleString("pt-BR")}`;
    },
  },

  actions: {
    /**
     * Recebe dados do Config NUI callback e popula o store.
     */
    setConfig(data) {
      this.characters = (data.Characters || []).map(normalizeCharacter);
      this.slots = data.Slots || 0;
      this.slotPrice = data.SlotPrice || 0;
      this.gemstone = data.Gemstone || 0;
      this.minimumAge = data.MinimumAge || 18;
      this.maximumAge = data.MaximumAge || 75;
      this.view = "select";

      // Seleciona o primeiro personagem automaticamente
      if (this.characters.length > 0) {
        this.selectedIndex = 0;
      } else {
        this.selectedIndex = -1;
      }
    },

    /**
     * Seleciona um personagem da lista.
     */
    selectCharacter(index) {
      this.selectedIndex = index;
    },

    /**
     * Vai para a tela de criação.
     */
    goToCreator() {
      this.previousView = this.view;
      this.view = "creator";
    },

    goToSelect() {
      this.previousView = this.view;
      this.view = "select";
    },

    /**
     * Define localizações e muda para view de spawn.
     * Chamado pelo evento "Location" do client Lua.
     */
    setLocations(locations) {
      this.previousView = this.view;
      this.locations = locations || [];
      this.selectedLocation = 0;
      this.view = "spawn";
    },

    /**
     * Adiciona novas localizações às existentes.
     * Chamado pelo evento "Increment" do client Lua.
     */
    incrementLocations(newLocations) {
      if (!newLocations || !newLocations.length) return;
      for (const loc of newLocations) {
        this.locations.push(loc);
      }
    },

    /**
     * Seleciona uma localização.
     */
    selectLocation(index) {
      this.selectedLocation = index;
    },

    /**
     * Fecha a interface e reseta o estado.
     */
    close() {
      this.previousView = this.view;
      this.view = "select";
      this.locations = [];
      this.selectedLocation = -1;
    },

    /**
     * Abre o popup de compra de slot.
     */
    openPopup(price) {
      this.popupPrice = price || this.slotPrice;
      this.showPopup = true;
    },

    /**
     * Fecha o popup de compra.
     */
    closePopup() {
      this.showPopup = false;
    },

    /**
     * Atualiza as gemas.
     */
    setGemstone(value) {
      this.gemstone = value;
    },

    /**
     * Adiciona uma notificação toast.
     */
    addNotification({ type, title, message }) {
      const id = Date.now() + Math.random();
      this.notifications.push({ id, type, title, message });

      // Remove automaticamente após 5 segundos
      setTimeout(() => {
        this.removeNotification(id);
      }, 5050);
    },

    /**
     * Remove uma notificação.
     */
    removeNotification(id) {
      this.notifications = this.notifications.filter((n) => n.id !== id);
    },
  },
});

if (import.meta.hot) {
  import.meta.hot.accept(acceptHMRUpdate(useSpawnStore, import.meta.hot));
}
