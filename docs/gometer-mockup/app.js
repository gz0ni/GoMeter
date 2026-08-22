/* ===== GoMeter · логика мокапа (Material 3) ===== */

/* ---------- демо-данные лимитов ---------- */
const WINDOWS = [
  { id: "rolling",  name: "5 часов",  sub: "Скользящее окно", percent: 81, resetIn: 14 * 60 + 32 },
  { id: "weekly",   name: "7 дней",   sub: "Неделя",           percent: 32, resetIn: 2 * 86400 + 21 * 3600 + 18 * 60 },
  { id: "monthly",  name: "30 дней",  sub: "Месяц",            percent: 16, resetIn: 31 * 86400 + 19 * 3600 + 2 * 60 },
];

const LEVELS = {
  green: { label: "Всё спокойно",    note: "Запас прочности большой — можно работать спокойно." },
  amber: { label: "Почти у предела", note: "Осталось немного. Скоро окно обновится." },
  red:   { label: "Близко к лимиту", note: "Осталось совсем чуть-чуть — побереги лимит." },
};

function levelFor(remainingPct) {
  if (remainingPct > 50) return "green";
  if (remainingPct >= 20) return "amber";
  return "red";
}

/* ---------- акцент-цвета (Авто — по умолчанию можно выбрать; синий — дефолт) ---------- */
const SEEDS = [
  { id: "auto",   label: "Авто",      color: "" },
  { id: "blue",   label: "Синий",     color: "#2196F3" },
  { id: "violet", label: "Фиолетовый", color: "#7C4DFF" },
  { id: "green",  label: "Зелёный",   color: "#22C55E" },
  { id: "orange", label: "Оранжевый", color: "#FB8C00" },
  { id: "pink",   label: "Розовый",   color: "#E91E63" },
];

/* ---------- состояние (localStorage) ---------- */
const state = { theme: "dark", seed: "blue", keySet: false };

function loadState() {
  try {
    state.theme = localStorage.getItem("gometer.theme") || "dark";
    state.seed = localStorage.getItem("gometer.seed") || "blue";
    state.keySet = localStorage.getItem("gometer.keySet") === "1";
  } catch (e) { /* мокап: без сохранения */ }
}
function saveState() {
  try {
    localStorage.setItem("gometer.theme", state.theme);
    localStorage.setItem("gometer.seed", state.seed);
    localStorage.setItem("gometer.keySet", state.keySet ? "1" : "0");
  } catch (e) {}
}

/* ---------- применение темы/цвета ---------- */
function resolvedTheme() {
  if (state.theme === "system") {
    return window.matchMedia("(prefers-color-scheme: dark)").matches ? "dark" : "light";
  }
  return state.theme;
}

function applyState() {
  const resolved = resolvedTheme();
  document.body.classList.toggle("theme-light", resolved === "light");
  SEEDS.forEach((s) => document.body.classList.remove("seed-" + s.id));
  if (state.seed !== "blue") document.body.classList.add("seed-" + state.seed);

  document.querySelectorAll("[data-theme]").forEach((c) => {
    c.classList.toggle("is-selected", c.dataset.theme === state.theme);
  });
  document.querySelectorAll(".color-dot").forEach((d) => {
    d.classList.toggle("is-selected", d.dataset.seed === state.seed);
    d.setAttribute("aria-pressed", String(d.dataset.seed === state.seed));
  });
  saveState();
}

/* следим за системной темой, если выбрано «Системная» */
const systemMq = window.matchMedia("(prefers-color-scheme: dark)");
const onSystemThemeChange = () => { if (state.theme === "system") applyState(); };
if (systemMq.addEventListener) systemMq.addEventListener("change", onSystemThemeChange);
else systemMq.addListener(onSystemThemeChange);

function renderColorRows() {
  ["onb-colors", "settings-colors"].forEach((id) => {
    const el = document.getElementById(id);
    if (!el) return;
    el.innerHTML = "";
    SEEDS.forEach((s) => {
      const b = document.createElement("button");
      b.type = "button";
      b.className = "color-dot" + (s.id === "auto" ? " is-auto" : "") + (s.id === state.seed ? " is-selected" : "");
      b.dataset.seed = s.id;
      if (s.color) {
        b.style.background = s.color;
        b.style.setProperty("--color", s.color);
      } else {
        b.innerHTML = '<span class="material-symbols-outlined">auto_awesome</span>';
      }
      b.setAttribute("aria-label", s.label);
      b.setAttribute("aria-pressed", String(s.id === state.seed));
      b.addEventListener("click", () => { state.seed = s.id; applyState(); });
      el.appendChild(b);
    });
  });
}

/* тема: чипы в онбординге и настройках */
document.querySelectorAll("[data-theme]").forEach((chip) => {
  chip.addEventListener("click", () => {
    state.theme = chip.dataset.theme;
    applyState();
  });
});

/* ---------- карточки ---------- */
const cardsEl = document.getElementById("cards");

function renderCards() {
  cardsEl.innerHTML = "";
  WINDOWS.forEach((w) => {
    const level = levelFor(100 - w.percent);
    const meta = LEVELS[level];
    const card = document.createElement("article");
    card.className = `card is-${level}`;
    card.innerHTML = `
      <div class="card-top">
        <span class="card-name">${w.name}</span>
        <span class="card-window">${w.sub}</span>
      </div>
      <div class="card-metric">
        <span class="card-percent">${w.percent}<small>%</small></span>
        <span class="card-used">использовано · осталось ${100 - w.percent}%</span>
      </div>
      <div class="progress"><span style="width:${w.percent}%"></span></div>
      <div class="card-foot">
        <span class="card-countdown"><span class="material-symbols-outlined">schedule</span><span>Сброс через <b data-timer="${w.id}">–</b></span></span>
        <span class="status-pill"><span class="dot"></span>${meta.label}</span>
      </div>
      <div class="card-note"><span class="material-symbols-outlined">sentiment_satisfied_alt</span><span>${meta.note}</span></div>
    `;
    cardsEl.appendChild(card);
  });
}

/* ---------- живой обратный отсчёт ---------- */
function fmtDuration(sec) {
  if (sec < 0) sec = 0;
  const d = Math.floor(sec / 86400);
  const h = Math.floor((sec % 86400) / 3600);
  const m = Math.floor((sec % 3600) / 60);
  const s = Math.floor(sec % 60);
  if (d > 0) return `${d} дн ${h}:${String(m).padStart(2, "0")}`;
  if (h > 0) return `${h} ч ${String(m).padStart(2, "0")} мин`;
  if (m > 0) return `${m} мин ${String(s).padStart(2, "0")} сек`;
  return `${s} сек`;
}

function tick() {
  WINDOWS.forEach((w) => {
    const el = document.querySelector(`[data-timer="${w.id}"]`);
    if (el) el.textContent = fmtDuration(w.resetIn);
    w.resetIn = Math.max(0, w.resetIn - 1);
  });
  updateSummary();
}

/* ---------- суммарный статус ---------- */
function updateSummary() {
  const worst = WINDOWS.reduce((a, b) => (b.percent > a.percent ? b : a), WINDOWS[0]);
  const level = levelFor(100 - worst.percent);
  const chip = document.getElementById("summary-chip");
  const txt = document.getElementById("summary-text");
  chip.className = `status-chip is-${level}`;
  txt.textContent = LEVELS[level].label;
}

/* ---------- имитация обновления ---------- */
const btnRefresh = document.getElementById("btn-refresh");
btnRefresh.addEventListener("click", () => {
  btnRefresh.classList.add("spinning");
  btnRefresh.setAttribute("aria-busy", "true");
  setTimeout(() => {
    WINDOWS.forEach((w) => {
      const drift = Math.max(-3, Math.min(3, Math.round((Math.random() - 0.5) * 6)));
      w.percent = Math.max(2, Math.min(98, w.percent + drift));
    });
    renderCards();
    updateSummary();
    document.getElementById("updated-at").textContent =
      "Обновлено только что · проверка каждые " + intervalLabel() + " мин";
    btnRefresh.classList.remove("spinning");
    btnRefresh.setAttribute("aria-busy", "false");
  }, 700);
});

function intervalLabel() {
  const sel = document.querySelector(".filter-chip.is-selected[data-interval]");
  return sel ? sel.dataset.interval : 5;
}

/* ---------- навигация ---------- */
const screens = {
  onboarding: document.getElementById("screen-onboarding"),
  usage: document.getElementById("screen-usage"),
  key: document.getElementById("screen-key"),
  notification: document.getElementById("screen-notification"),
  settings: document.getElementById("screen-settings"),
  about: document.getElementById("screen-about"),
};
const navButtons = document.querySelectorAll(".nav-item");
const navBar = document.querySelector(".navigation-bar");
const tabFor = { usage: "usage", key: "usage", notification: "notification", settings: "settings", about: "settings" };

function showScreen(name) {
  Object.entries(screens).forEach(([k, el]) => {
    el.hidden = k !== name;
    el.classList.toggle("is-active", k === name);
  });
  navButtons.forEach((b) => {
    b.classList.toggle("is-active", b.dataset.screen === tabFor[name]);
  });
  navBar.style.display = name === "onboarding" ? "none" : "flex";
  window.scrollTo({ top: 0, behavior: "smooth" });
}

navButtons.forEach((b) => b.addEventListener("click", () => showScreen(b.dataset.screen)));
document.getElementById("btn-key").addEventListener("click", () => showScreen("key"));
document.getElementById("btn-back-key").addEventListener("click", () => showScreen("usage"));
document.getElementById("go-key-settings").addEventListener("click", () => showScreen("key"));
document.getElementById("go-about").addEventListener("click", () => showScreen("about"));
document.getElementById("btn-back-about").addEventListener("click", () => showScreen("settings"));

/* ---------- ключ: валидация + сохранение ---------- */
function validateKey(v) {
  const t = v.trim();
  if (!t) return "Введи ключ — он начинается с sk-.";
  if (!/^sk-/.test(t)) return "Похоже, это не ключ OpenCode Go — он начинается с «sk-».";
  if (t.length < 10) return "Ключ слишком короткий. Проверь, что скопировал его целиком.";
  return "";
}

function setupKeyField(inputId, errorId, onSuccess) {
  const input = document.getElementById(inputId);
  const errorEl = document.getElementById(errorId);
  input.addEventListener("input", () => { errorEl.textContent = ""; });
  return function save() {
    const err = validateKey(input.value);
    if (err) {
      errorEl.textContent = err;
      input.focus();
      return false;
    }
    input.value = "";
    input.type = "password";
    errorEl.textContent = "";
    if (onSuccess) onSuccess();
    return true;
  };
}

/* экран «Ключ доступа» */
const keyEye = document.getElementById("btn-eye");
keyEye.addEventListener("click", () => {
  const input = document.getElementById("key-input");
  const show = input.type === "password";
  input.type = show ? "text" : "password";
  keyEye.innerHTML = `<span class="material-symbols-outlined">${show ? "visibility_off" : "visibility"}</span>`;
  keyEye.setAttribute("aria-label", show ? "Скрыть ключ" : "Показать ключ");
});

document.getElementById("btn-save").addEventListener("click", () => {
  const ok = setupKeyField("key-input", "key-error", () => {
    state.keySet = true;
    saveState();
  })();
  if (ok) {
    const btn = document.getElementById("btn-save");
    const original = btn.innerHTML;
    btn.innerHTML = '<span class="material-symbols-outlined">check</span> Сохранено!';
    setTimeout(() => { btn.innerHTML = original; }, 1600);
  }
});

/* онбординг: старт без ключа невозможно — нужен ключ */
const onbStart = document.getElementById("btn-onb-start");
onbStart.addEventListener("click", () => {
  const ok = setupKeyField("onb-key-input", "onb-key-error", () => {})();
  if (ok) {
    state.keySet = true;
    saveState();
    showScreen("usage");
  }
});

/* импорт из CLI (Linux) — в обоих полях */
function importInto(inputId, errorId) {
  const input = document.getElementById(inputId);
  const errorEl = document.getElementById(errorId);
  input.value = "sk-•••••••••••••••••• (импортировано из auth.json)";
  errorEl.classList.add("is-ok");
  errorEl.textContent = "Импортировано с устройства. Ключ сохранён в защищённом хранилище.";
  setTimeout(() => { errorEl.classList.remove("is-ok"); }, 3000);
}
document.getElementById("btn-import").addEventListener("click", () => importInto("key-input", "key-error"));
document.getElementById("btn-import-settings").addEventListener("click", () => importInto("key-input", "key-error"));
document.getElementById("btn-onb-import").addEventListener("click", () => importInto("onb-key-input", "onb-key-error"));

/* ---------- настройки: интервал, свитчи ---------- */
document.querySelectorAll(".filter-chip[data-interval]").forEach((chip) => {
  chip.addEventListener("click", () => {
    document.querySelectorAll(".filter-chip[data-interval]").forEach((c) => c.classList.remove("is-selected"));
    chip.classList.add("is-selected");
  });
});

const switchNotif = document.getElementById("switch-notif");
document.querySelectorAll("#set-80, #set-95").forEach((s) => {
  const sync = () => { s.disabled = !switchNotif.checked; };
  switchNotif.addEventListener("change", sync);
  sync();
});

/* очистить данные → возврат на онбординг */
document.getElementById("btn-clear").addEventListener("click", () => {
  WINDOWS.forEach((w) => { w.percent = 10; w.resetIn = 3600; });
  renderCards();
  updateSummary();
  state.keySet = false;
  saveState();
  showScreen("onboarding");
});

/* ---------- баннер обновления ---------- */
const banner = document.getElementById("update-banner");
if (localStorage.getItem("gometer.banner") === "1") banner.hidden = true;

document.getElementById("btn-update-close").addEventListener("click", () => {
  banner.hidden = true;
  try { localStorage.setItem("gometer.banner", "1"); } catch (e) {}
});
document.getElementById("btn-update-banner").addEventListener("click", () => updateMock());
document.getElementById("btn-update-about").addEventListener("click", () => updateMock());

function updateMock() {
  alert("В мокапе обновление недоступно. В финальной версии здесь откроется страница загрузки.");
}

/* ---------- старт ---------- */
loadState();
applyState();
renderCards();
updateSummary();
renderColorRows();

setInterval(tick, 1000);
tick();

/* поддержка ?screen=... (демо/скриншоты) */
const initial = new URLSearchParams(location.search).get("screen");
if (!state.keySet && !initial) {
  showScreen("onboarding");
} else {
  showScreen(initial && screens[initial] ? initial : "usage");
}
