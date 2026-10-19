/**
 * Mock de ambiente NUI (FiveM) para rodar a interface no navegador.
 * Segue o padrão da resource Shops.
 */
import isBrowser from "@utils/isBrowser";

if (import.meta.env.DEV && isBrowser()) {
  const RESOURCE = "spawn";
  const THEME = "#66ad43";

  // ==================== STUB DO RESOURCE NAME ====================
  if (typeof window.GetParentResourceName !== "function") {
    window.GetParentResourceName = () => RESOURCE;
  }

  // ==================== INTERCEPTA AS CHAMADAS NUI ====================
  const realFetch = window.fetch.bind(window);
  const json = (data) =>
    new Response(JSON.stringify(data ?? {}), {
      status: 200,
      headers: { "Content-Type": "application/json" },
    });

  const send = (action, data) => window.postMessage({ name: action, Payload: data }, "*");

  // ==================== SEEDS — Dados de teste ====================
  const CHARACTERS = [
    {
      Passport: 4721,
      Name: "Lucas Hen",
      Skin: "mp_m_freemode_01",
      Age: 25,
      Bank: 1442506499,
      Job: "Desempregado(a)",
      JobColor: "",
      Admin: true,
      Ped: null,
      LastLogin: Math.floor(Date.now() / 1000) - 3600,
      CreatedAt: 1723035420,
      Blood: "B-",
      Playing: false,
      Clothes: {},
      Barber: {},
      Tattoos: {},
    },
    {
      Passport: 8356,
      Name: "Maria Santos",
      Skin: "s_m_y_cop_01",
      Age: 32,
      Bank: 850000,
      Job: "Los Santos Police Department",
      JobColor: "#16468b",
      Admin: false,
      Ped: Math.floor(Date.now() / 1000) + 86400 * 90,
      LastLogin: Math.floor(Date.now() / 1000) - 86400 * 3,
      CreatedAt: 1722430620,
      Blood: "O+",
      Playing: false,
      Clothes: {},
      Barber: {},
      Tattoos: {},
    },
  ];

  const LOCATIONS = [
    { Coords: [242.77, -392.07, 45.3], Name: "Última Localização" },
    { Coords: [-2205.92, -370.48, 13.29], Name: "Paleto Bay" },
    { Coords: [-250.35, 6209.71, 31.49], Name: "Sandy Shores" },
    { Coords: [1694.37, 4794.66, 41.92], Name: "Grapeseed" },
    { Coords: [1858.94, 3741.78, 33.09], Name: "Scoops" },
    { Coords: [328.0, 2617.89, 44.48], Name: "Davis" },
    { Coords: [308.33, -232.25, 54.07], Name: "Pillbox Hill" },
    { Coords: [449.71, -659.27, 28.48], Name: "Strawberry" },
  ];

  // ==================== CALLBACKS NUI ====================
  const callbacks = {
    Close: () => { send("Close"); return {}; },
    Config: () => ({
      Characters: CHARACTERS,
      Slots: 4,
      Gemstone: 42,
      SlotPrice: 10000,
      MinimumAge: 18,
      MaximumAge: 75,
    }),
    CharacterChosen: () => {
      setTimeout(() => send("Close"), 500);
      return true;
    },
    NewCharacter: (body) => {
      const newId = Math.floor(Math.random() * 90000) + 10000;
      CHARACTERS.push({
        Passport: newId,
        Name: `${body.Name} ${body.Lastname}`,
        Skin: body.Gender || "mp_m_freemode_01",
        Age: body.Age || 18,
        Bank: 0,
        Job: "Desempregado(a)",
        JobColor: "",
        Admin: false,
        Ped: null,
        LastLogin: null,
        CreatedAt: Math.floor(Date.now() / 1000),
        Blood: ["A+", "A-", "B+", "B-", "O+", "O-"][Math.floor(Math.random() * 6)],
        Playing: false,
        Clothes: {},
        Barber: {},
        Tattoos: {},
      });
      return true;
    },
    SwitchCharacter: () => "Ok",
    Spawn: () => "Ok",
    Chosen: () => "Ok",
    Request: () => false,
    PurchaseSlot: () => {
      send("Notify", { Type: "verde", Title: "Sucesso", Message: "Compra concluída." });
      return true;
    },
    Theme: () => ({ main: THEME, currency: "$" }),
  };

  window.fetch = async (input, init) => {
    const url = typeof input === "string" ? input : (input?.url ?? "");
    const match = new RegExp(`^https?://(?:${RESOURCE}|vrp|nui-fallback)/(.+)$`).exec(url);
    if (!match) return realFetch(input, init);
    const method = match[1];
    let body = {};
    try { if (init?.body) body = JSON.parse(init.body); } catch {}
    const handler = callbacks[method];
    const data = handler ? await handler(body) : {};
    return json(data);
  };

  // ==================== AUTO-OPEN ====================
  setTimeout(() => send("Config", callbacks.Config()), 100);
  setTimeout(() => send("Gemstone", 42), 30);

  // ==================== PAINEL DE TESTE ====================
  // SVG icons inline
  const icons = {
    config: `<svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M12.22 2h-.44a2 2 0 00-2 2v.18a2 2 0 01-1 1.73l-.43.25a2 2 0 01-2 0l-.15-.08a2 2 0 00-2.73.73l-.22.38a2 2 0 00.73 2.73l.15.1a2 2 0 011 1.72v.51a2 2 0 01-1 1.74l-.15.09a2 2 0 00-.73 2.73l.22.38a2 2 0 002.73.73l.15-.08a2 2 0 012 0l.43.25a2 2 0 011 1.73V20a2 2 0 002 2h.44a2 2 0 002-2v-.18a2 2 0 011-1.73l.43-.25a2 2 0 012 0l.15.08a2 2 0 002.73-.73l.22-.39a2 2 0 00-.73-2.73l-.15-.08a2 2 0 01-1-1.74v-.5a2 2 0 011-1.74l.15-.09a2 2 0 00.73-2.73l-.22-.38a2 2 0 00-2.73-.73l-.15.08a2 2 0 01-2 0l-.43-.25a2 2 0 01-1-1.73V4a2 2 0 00-2-2z"/><circle cx="12" cy="12" r="3"/></svg>`,
    location: `<svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M20 10c0 6-8 12-8 12s-8-6-8-12a8 8 0 0116 0Z"/><circle cx="12" cy="10" r="3"/></svg>`,
    check: `<svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M20 6L9 17l-5-5"/></svg>`,
    warn: `<svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M10.29 3.86L1.82 18a2 2 0 001.71 3h16.94a2 2 0 001.71-3L13.71 3.86a2 2 0 00-3.42 0z"/><line x1="12" y1="9" x2="12" y2="13"/><line x1="12" y1="17" x2="12.01" y2="17"/></svg>`,
    gem: `<svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M5.782 4.182C6.43 3.683 6.754 3.434 7.128 3.273C7.297 3.2 7.474 3.142 7.655 3.097C8.054 3 8.477 3 9.323 3H14.677C15.523 3 15.946 3 16.345 3.097C16.526 3.142 16.703 3.2 16.872 3.273C17.246 3.434 17.57 3.683 18.218 4.182C20.364 5.834 21.438 6.661 21.806 7.731C21.969 8.207 22.031 8.707 21.986 9.205C21.885 10.323 21.038 11.346 19.343 13.393L15.35 18.215C13.813 20.072 13.044 21 12 21C10.956 21 10.187 20.072 8.65 18.215L4.657 13.393C2.962 11.346 2.115 10.323 2.014 9.205C1.969 8.707 2.031 8.207 2.194 7.731C2.562 6.661 3.636 5.834 5.782 4.182Z"/><path d="M10 8.5H14"/></svg>`,
    close: `<svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M18 6L6 18M6 6l12 12"/></svg>`,
  };

  const buildPanel = () => {
    const panel = document.createElement("div");
    panel.id = "mock-panel";
    panel.className = "mock-panel";
    Object.assign(panel.style, {
      position: "fixed",
      bottom: "16px",
      left: "50%",
      transform: "translateX(-50%)",
      zIndex: "9999",
      display: "flex",
      flexDirection: "column",
      gap: "8px",
      fontFamily: "Manrope, sans-serif",
      background: "rgba(0,0,0,0.65)",
      backdropFilter: "blur(8px)",
      border: "1px solid rgba(255,255,255,0.08)",
      borderRadius: "8px",
      padding: "10px",
    });

    const mkBtn = (label, icon, action, color) => {
      const btn = document.createElement("button");
      btn.innerHTML = `<span style="display:inline-flex;align-items:center;gap:4px">${icon || ""}<span>${label}</span></span>`;
      Object.assign(btn.style, {
        display: "flex",
        alignItems: "center",
        gap: "4px",
        padding: "4px 8px",
        fontSize: "11px",
        fontWeight: "500",
        background: color ? color + "15" : "rgba(255,255,255,0.06)",
        color: color || "rgba(255,255,255,0.7)",
        border: `1px solid ${color ? color + "30" : "rgba(255,255,255,0.1)"}`,
        borderRadius: "5px",
        cursor: "pointer",
        transition: "all 0.15s ease",
        whiteSpace: "nowrap",
      });
      btn.addEventListener("mouseenter", () => {
        btn.style.background = color ? color + "25" : "rgba(255,255,255,0.12)";
        btn.style.borderColor = color ? color + "50" : "rgba(255,255,255,0.18)";
      });
      btn.addEventListener("mouseleave", () => {
        btn.style.background = color ? color + "15" : "rgba(255,255,255,0.06)";
        btn.style.borderColor = color ? color + "30" : "rgba(255,255,255,0.1)";
      });
      btn.addEventListener("click", action);
      return btn;
    };

    const mkGroup = (label) => {
      const wrap = document.createElement("div");
      wrap.style.cssText = "display:flex;align-items:center;gap:5px;flex-wrap:wrap";
      if (label) {
        const lbl = document.createElement("span");
        lbl.textContent = label;
        lbl.style.cssText = "color:rgba(255,255,255,0.3);font-size:9px;text-transform:uppercase;letter-spacing:.05em;min-width:44px;text-align:right;padding-right:2px";
        wrap.appendChild(lbl);
      }
      return wrap;
    };

    // ── Header ──
    const header = document.createElement("div");
    header.style.cssText = "color:rgba(255,255,255,0.25);font-size:9px;text-transform:uppercase;letter-spacing:.08em;font-weight:700;margin-bottom:2px";
    header.textContent = "Mock — Spawn";
    panel.appendChild(header);

    // ── Row 1: Config ──
    const g1 = mkGroup("NUI");
    g1.appendChild(mkBtn("Config", icons.config, () => send("Config", callbacks.Config()), THEME));
    g1.appendChild(mkBtn("Close", icons.close, () => send("Close")));
    panel.appendChild(g1);

    // ── Row 2: Location ──
    const g2 = mkGroup("View");
    g2.appendChild(mkBtn("Location", icons.location, () => send("Location", LOCATIONS), "#6ac6c5"));
    panel.appendChild(g2);

    // ── Row 3: Notificações ──
    const g3 = mkGroup("Toast");
    g3.appendChild(mkBtn("Sucesso", icons.check, () => send("Notify", { Type: "verde", Title: "Sucesso", Message: "Compra concluída com sucesso." }), "#6bc53d"));
    g3.appendChild(mkBtn("Aviso", icons.warn, () => send("Notify", { Type: "amarelo", Title: "Atenção", Message: "Atenção ao caminho." }), "#ffc832"));
    g3.appendChild(mkBtn("Clima", icons.warn, () => send("Notify", { Type: "clima", Title: "Atenção", Message: "O clima atual na região <b>Sul</b> é <b>Neblina</b>." }), "#38bdf8"));
    panel.appendChild(g3);

    // ── Row 4: Popup ──
    const g4 = mkGroup("Popup");
    g4.appendChild(mkBtn("Comprar Slot", icons.gem, () => send("Request", 10000), "#c6986a"));
    g4.appendChild(mkBtn("Comprar Skin", icons.gem, () => send("Request", 25000), "#986ac6"));
    panel.appendChild(g4);

    document.body.appendChild(panel);
  };

  if (document.body) buildPanel();
  else document.addEventListener("DOMContentLoaded", buildPanel);
}
