/* ===== GoMeter Desktop · логика мокапа (минимализм LocalSend) ===== */

/* ---------- демо-данные лимитов ---------- */
const WINDOWS = [
  { id: "rolling",  name: "5 часов", icon: "history",        percent: 81, resetIn: 14 * 60 + 32 },
  { id: "weekly",   name: "7 дней",  icon: "date_range",     percent: 32, resetIn: 2 * 86400 + 21 * 3600 + 18 * 60 },
  { id: "monthly",  name: "30 дней", icon: "calendar_month", percent: 16, resetIn: 31 * 86400 + 19 * 3600 + 2 * 60 },
];

const LEVELS = {
  green: { label: "Всё спокойно" },
  amber: { label: "Почти у предела" },
  red:   { label: "Близко к лимиту" },
};

const STATUS_ICONS = { green: "check_circle", amber: "warning", red: "error" };

function levelFor(remainingPct) {
  if (remainingPct > 50) return "green";
  if (remainingPct >= 20) return "amber";
  return "red";
}

/* ---------- акцент-цвета (авто + 5; синий — дефолт) ---------- */
const SEEDS = [
  ["auto",   "Авто"],
  ["blue",   "Синий"],
  ["violet", "Фиолетовый"],
  ["green",  "Зелёный"],
  ["orange", "Оранжевый"],
  ["pink",   "Розовый"],
];

const SEED_COLORS = { blue: "#2196F3", violet: "#7C4DFF", green: "#22C55E", orange: "#FB8C00", pink: "#E91E63" };

/* ---------- состояние (общий профиль с мобильным) ---------- */
const state = { theme: "dark", seed: "blue", interval: 5, keySet: false, autoUpdate: true, autoStart: false, quietStart: false };

function loadState() {
  try {
    state.theme = localStorage.getItem("gometer.theme") || "dark";
    state.seed = localStorage.getItem("gometer.seed") || "blue";
    state.interval = Number(localStorage.getItem("gometer.interval")) || 5;
    state.keySet = localStorage.getItem("gometer.keySet") === "1";
    state.autoUpdate = localStorage.getItem("gometer.autoUpdate") !== "0";
    state.autoStart = localStorage.getItem("gometer.autoStart") === "1";
    state.quietStart = localStorage.getItem("gometer.quietStart") === "1";
  } catch (e) {}
}
function saveState() {
  try {
    localStorage.setItem("gometer.theme", state.theme);
    localStorage.setItem("gometer.seed", state.seed);
    localStorage.setItem("gometer.interval", String(state.interval));
    localStorage.setItem("gometer.keySet", state.keySet ? "1" : "0");
    localStorage.setItem("gometer.autoUpdate", state.autoUpdate ? "1" : "0");
    localStorage.setItem("gometer.autoStart", state.autoStart ? "1" : "0");
    localStorage.setItem("gometer.quietStart", state.quietStart ? "1" : "0");
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
  document.body.style.setProperty("--accent", SEED_COLORS[state.seed] || "");
  document.querySelectorAll(".color-dot").forEach((d) => {
    d.classList.toggle("is-selected", d.dataset.seed === state.seed);
    d.setAttribute("aria-pressed", String(d.dataset.seed === state.seed));
  });
  saveState();
  updateDropdownLabels();
}

const systemMq = window.matchMedia("(prefers-color-scheme: dark)");
const onSystemThemeChange = () => { if (state.theme === "system") applyState(); };
if (systemMq.addEventListener) systemMq.addEventListener("change", onSystemThemeChange);
else systemMq.addListener(onSystemThemeChange);

/* ---------- дропдауны: тема, цвет, интервал ---------- */
const dropdownState = {};

function initDropdown(id, options, onSet) {
  const dd = document.getElementById(id);
  if (!dd) return;
  const menu = dd.querySelector(".dropdown-menu");
  const valueEl = dd.querySelector(".dropdown-value");

  menu.innerHTML = "";
  options.forEach(([value, label]) => {
    const b = document.createElement("button");
    b.type = "button";
    b.dataset.value = value;
    b.textContent = label;
    b.setAttribute("role", "option");
    b.addEventListener("click", () => {
      onSet(value);
      menu.hidden = true;
      btn.setAttribute("aria-expanded", "false");
    });
    menu.appendChild(b);
  });

  dropdownState[id] = { valueEl };
}

function closeDropdowns(except) {
  document.querySelectorAll(".dropdown").forEach((d) => {
    if (d === except) return;
    d.querySelector(".dropdown-menu").hidden = true;
    d.querySelector(".dropdown-btn").setAttribute("aria-expanded", "false");
  });
}

document.addEventListener("click", (e) => {
  const dd = e.target.closest(".dropdown");
  if (!dd) { closeDropdowns(null); return; }
  const menu = dd.querySelector(".dropdown-menu");
  const btn = dd.querySelector(".dropdown-btn");
  const willOpen = menu.hidden;
  closeDropdowns(dd);
  if (willOpen) {
    menu.hidden = false;
    btn.setAttribute("aria-expanded", "true");
  }
});

function updateDropdownLabels() {
  const themeLabel = { light: "Светлая", dark: "Тёмная", system: "Системная" }[state.theme] || "Светлая";
  const intervalLabel = `${state.interval} мин`;
  if (dropdownState["dd-theme"]) dropdownState["dd-theme"].valueEl.textContent = themeLabel;
  if (dropdownState["dd-interval"]) dropdownState["dd-interval"].valueEl.textContent = intervalLabel;
}

/* ---------- цвет акцента: кружочки ---------- */
function renderColorRow() {
  const el = document.getElementById("color-row");
  if (!el) return;
  el.innerHTML = "";
  SEEDS.forEach(([id, label]) => {
    const b = document.createElement("button");
    b.type = "button";
    b.className = "color-dot" + (id === "auto" ? " is-auto" : "") + (id === state.seed ? " is-selected" : "");
    b.dataset.seed = id;
    if (SEED_COLORS[id]) b.style.background = SEED_COLORS[id];
    else b.innerHTML = '<span class="material-symbols-outlined">auto_awesome</span>';
    b.setAttribute("aria-label", label);
    b.setAttribute("aria-pressed", String(id === state.seed));
    b.addEventListener("click", () => { state.seed = id; applyState(); });
    el.appendChild(b);
  });
}

/* ---------- карточки лимитов ---------- */
const cardsEl = document.getElementById("cards");

function renderCards() {
  cardsEl.innerHTML = "";
  WINDOWS.forEach((w) => {
    const level = levelFor(100 - w.percent);
    const card = document.createElement("article");
    card.className = `win-card is-${level}`;
    card.innerHTML = `
      <span class="win-icon" aria-hidden="true"><span class="material-symbols-outlined">${w.icon}</span></span>
      <span class="win-name">${w.name}</span>
      <span class="win-percent">${w.percent}<small>%</small></span>
      <span class="win-sub">осталось ${100 - w.percent}%</span>
      <div class="progress" role="progressbar" aria-valuemin="0" aria-valuemax="100" aria-valuenow="${w.percent}" aria-label="${w.name}: использовано ${w.percent}%"><span style="width:${w.percent}%"></span></div>
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
  if (d > 0) return `${d} дн ${h} ч`;
  if (h > 0) return `${h} ч ${m} мин`;
  if (m > 0) return `${m} мин ${s} сек`;
  return `${s} сек`;
}

function tick() {
  WINDOWS.forEach((w) => {
    w.resetIn = Math.max(0, w.resetIn - 1);
  });
  updateSummary();
}

/* ---------- суммарный статус ---------- */
function updateSummary() {
  const worst = WINDOWS.reduce((a, b) => (b.percent > a.percent ? b : a), WINDOWS[0]);
  const level = levelFor(100 - worst.percent);

  const card = document.getElementById("status-card");
  const icon = document.getElementById("status-icon");
  const title = document.getElementById("summary-text");
  const sub = document.getElementById("status-sub");

  card.className = `status-card is-${level}`;
  icon.textContent = STATUS_ICONS[level];
  title.textContent = LEVELS[level].label;
  sub.innerHTML = `${worst.name} · использовано ${worst.percent}% · сброс через <b>${fmtDuration(worst.resetIn)}</b>`;
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
    dismissed.clear();
    renderPushes();
    document.getElementById("updated-at").textContent =
      "Обновлено только что · проверка каждые " + state.interval + " мин";
    btnRefresh.classList.remove("spinning");
    btnRefresh.setAttribute("aria-busy", "false");
  }, 700);
});

/* ---------- живые уведомления на главном ---------- */
const pushesEl = document.getElementById("notifications");
const PUSH_THRESHOLDS = [80, 95];
const dismissed = new Set();

function pushThresholdEnabled(pct) {
  const master = document.getElementById("switch-notif");
  const sw = document.getElementById(pct === 80 ? "set-80" : "set-95");
  return master && master.checked && sw && sw.checked;
}

function renderPushes() {
  if (!pushesEl) return;
  pushesEl.innerHTML = "";
  let shown = 0;
  PUSH_THRESHOLDS.forEach((pct) => {
    if (!pushThresholdEnabled(pct)) return;
    const worst = WINDOWS.filter((w) => w.percent >= pct).sort((a, b) => b.percent - a.percent)[0];
    if (!worst || worst.percent < pct) return;
    const key = pct + "-" + worst.id;
    if (dismissed.has(key)) return;
    const card = document.createElement("article");
    card.className = "push-card";
    card.innerHTML = `
      <div class="notif-header">
        <span class="notif-appicon" aria-hidden="true"><span class="material-symbols-outlined">speed</span></span>
        <span class="notif-appname">GoMeter</span>
        <span class="notif-time">сейчас</span>
        <button class="push-close" type="button" aria-label="Скрыть"><span class="material-symbols-outlined">close</span></button>
      </div>
      <div class="notif-body">
        <span class="notif-title">Лимит ${pct}% · ${worst.name}</span>
        <span class="notif-text">Осталось ${100 - worst.percent}%. Окно сбросится примерно через ${fmtDuration(worst.resetIn)}.</span>
      </div>`;
    card.querySelector(".push-close").addEventListener("click", () => {
      dismissed.add(key);
      renderPushes();
    });
    pushesEl.appendChild(card);
    shown++;
  });
  pushesEl.hidden = shown === 0;
}

/* ---------- навигация (Rail) ---------- */
const screens = {
  onboarding: document.getElementById("screen-onboarding"),
  usage: document.getElementById("screen-usage"),
  key: document.getElementById("screen-key"),
  settings: document.getElementById("screen-settings"),
  about: document.getElementById("screen-about"),
};
const railItems = document.querySelectorAll(".rail-item");
const rail = document.querySelector(".rail");
const content = document.querySelector(".desktop-content");

function showScreen(name) {
  Object.entries(screens).forEach(([k, el]) => {
    el.hidden = k !== name;
    el.classList.toggle("is-active", k === name);
  });
  railItems.forEach((b) => b.classList.toggle("is-active", b.dataset.screen === name));
  rail.style.display = name === "onboarding" ? "none" : "flex";
  content.classList.toggle("is-onboarding", name === "onboarding");
  content.scrollTop = 0;
}

railItems.forEach((b) => b.addEventListener("click", () => showScreen(b.dataset.screen)));
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

document.getElementById("btn-onb-start").addEventListener("click", () => {
  const ok = setupKeyField("onb-key-input", "onb-key-error", () => {})();
  if (ok) {
    state.keySet = true;
    saveState();
    showScreen("usage");
  }
});

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

/* ---------- настройки: свитчи уведомлений ---------- */
const switchNotif = document.getElementById("switch-notif");
if (switchNotif) {
  document.querySelectorAll("#set-80, #set-95").forEach((s) => {
    const sync = () => {
      s.disabled = !switchNotif.checked;
      renderPushes();
    };
    switchNotif.addEventListener("change", sync);
    s.addEventListener("change", renderPushes);
    sync();
  });
}

/* ---------- обновления: проверка вручную и автоматически ---------- */
function checkUpdates() {
  const sub = document.getElementById("check-sub");
  if (!sub) return;
  sub.textContent = "Проверяю…";
  sub.classList.remove("is-ok", "is-error");
  setTimeout(() => {
    sub.textContent = "Доступно обновление 0.2.0";
    sub.classList.add("is-ok");
  }, 800);
}

document.getElementById("btn-check-updates").addEventListener("click", checkUpdates);

const switchAutoUpdate = document.getElementById("switch-auto-update");
switchAutoUpdate.checked = state.autoUpdate;
switchAutoUpdate.addEventListener("change", () => {
  state.autoUpdate = switchAutoUpdate.checked;
  saveState();
});

/* ---------- автозапуск + тихий старт ---------- */
const switchAutoStart = document.getElementById("switch-autostart");
const rowQuiet = document.getElementById("row-quiet");
switchAutoStart.checked = state.autoStart;
rowQuiet.hidden = !state.autoStart;
switchAutoStart.addEventListener("change", () => {
  state.autoStart = switchAutoStart.checked;
  saveState();
  rowQuiet.hidden = !switchAutoStart.checked;
});

const switchQuietStart = document.getElementById("switch-quiet-start");
switchQuietStart.checked = state.quietStart;
switchQuietStart.addEventListener("change", () => {
  state.quietStart = switchQuietStart.checked;
  saveState();
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

/* ---------- обновление в «О приложении» ---------- */
document.getElementById("btn-update-about").addEventListener("click", () => updateMock());

function updateMock() {
  alert("В мокапе обновление недоступно. В финальной версии здесь откроется страница загрузки.");
}

/* ---------- старт ---------- */
loadState();
applyState();
initDropdown("dd-theme", [["light", "Светлая"], ["dark", "Тёмная"], ["system", "Системная"]], (v) => {
  state.theme = v;
  applyState();
});
initDropdown("dd-interval", [["1", "1 мин"], ["3", "3 мин"], ["5", "5 мин"]], (v) => {
  state.interval = Number(v);
  saveState();
  updateDropdownLabels();
});
updateDropdownLabels();
renderColorRow();
renderCards();
updateSummary();
renderPushes();
if (state.autoUpdate) checkUpdates();

setInterval(tick, 1000);
tick();

/* поддержка ?screen=... (демо/скриншоты) */
const initial = new URLSearchParams(location.search).get("screen");
if (!state.keySet && !initial) {
  showScreen("onboarding");
} else {
  showScreen(initial && screens[initial] ? initial : "usage");
}
