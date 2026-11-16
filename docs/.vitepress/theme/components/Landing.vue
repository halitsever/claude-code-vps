<script setup lang="ts">
import { computed, onBeforeUnmount, onMounted, ref } from "vue";
import { useData, withBase } from "vitepress";
import AuroraCanvas from "./AuroraCanvas.vue";
import BootScreen from "./BootScreen.vue";
import { FAQ, type Lang } from "../faq";

const props = defineProps<{ lang?: Lang }>();
const { isDark } = useData();

const INSTALL = "curl -fsSL https://raw.githubusercontent.com/halitsever/claude-code-vps/main/install.sh | sudo bash";
const REPO = "https://github.com/halitsever/claude-code-vps";
const STEP_NAMES = ["base", "user", "ssh", "firewall", "desktop", "rdp", "apps", "claude", "dotfiles"];
const STEP_OUT = [
  "base system ready",
  "created dev, copied your SSH keys",
  "SSH accepts keys only",
  "firewall on: 22, 53389",
  "KDE Plasma installed",
  "xrdp listening on 53389",
  "Docker, gh and Chrome ready",
  "Claude Code installed to ~/.local/bin/claude",
  "31 files updated",
];
const STACK = ["Ubuntu 26.04", "KDE Plasma 6", "xrdp", "tmux", "Claude Code", "Docker", "GitHub CLI", "Chrome", "ntfy.sh", "ufw", "systemd timers", "VitePress"];

const STRINGS = {
  en: {
    badge: "New: the step-by-step Claude Code VPS guide",
    title1: "A blank server in.",
    title2: "Your Claude workstation out.",
    lead: "One command installs Claude Code, a full KDE Plasma desktop over RDP, hardened SSH and the exact config I use every day. Change your setup at home, and the server follows.",
    start: "Read the VPS guide",
    github: "Star on GitHub",
    copy: "Copy",
    copied: "Copied",
    stats: [["1", "command"], ["9", "setup steps"], ["~10", "minutes"], ["4", "languages"]],
    toast: "Claude is waiting for your input",
    stepsKicker: "Under the hood",
    stepsTitle: "Nine steps. All readable bash.",
    stepDesc: [
      "apt upgrade, core tools, swap and unattended security updates.",
      "A sudo user with your SSH keys copied over.",
      "Key-only login, no root passwords. Written so it wins over cloud-init.",
      "ufw with only SSH and RDP open.",
      "KDE Plasma with the X11 session. No login screen on a headless box.",
      "xrdp on port 53389, starting Plasma, without the colord prompts.",
      "Docker, GitHub CLI and Chrome.",
      "Claude Code native install, plus your ntfy topic.",
      "Your KDE layout, Claude settings, hooks and tmux config.",
    ],
    stepsLink: "Read every step in detail",
    bentoKicker: "What you get",
    bentoTitle: "Everything a long-running agent needs.",
    bento: [
      { t: "Claude Code, always on", d: "tmux sessions that survive a dropped SSH, with your settings, hooks and status line already in place.", tag: "claude" },
      { t: "Your KDE, not a default one", d: "Panels, shortcuts, tiling and Konsole profiles, captured at home and replayed on the server.", tag: "plasma" },
      { t: "Locked down", d: "Key-only SSH, no root password login, ufw, unattended upgrades.", tag: "security" },
      { t: "Pings your phone", d: "A Notification hook sends Claude's questions to ntfy.sh. Walk away.", tag: "ntfy" },
      { t: "Dev stack", d: "Docker, GitHub CLI, Node, ripgrep, build tools and Chrome.", tag: "tools" },
      { t: "Re-runnable", d: "Every step checks what is there first. Run it again any time, or just --only what you need.", tag: "idempotent" },
    ],
    flowKicker: "Stay in sync",
    flowTitle: "Tweak at home. It shows up on the server.",
    flowText: "The repo is the source of truth. Publish from your machine, the server pulls on a timer.",
    flow: [
      { cmd: "claude-vps publish", t: "Your machine", d: "Captures KDE and Claude config, scrubs home paths, commits and pushes." },
      { cmd: "git push", t: "GitHub", d: "Plain files in dotfiles/home. Easy to diff, easy to review." },
      { cmd: "claude-vps sync", t: "Server", d: "Pulls and applies, backing up what it replaces. Or autosync every 30 minutes." },
    ],
    ctaTitle: "Your next server is ten minutes away.",
    ctaText: "Hetzner, DigitalOcean, a spare box at home: anything on Ubuntu 24.04 or newer.",
    base: "",
  },
  fr: {
    badge: "Nouveau : le guide pas à pas Claude Code sur VPS",
    title1: "Un serveur vide en entrée.",
    title2: "Votre poste Claude en sortie.",
    lead: "Une seule commande installe Claude Code, un bureau KDE Plasma complet via RDP, un SSH durci et exactement la configuration que j'utilise au quotidien. Modifiez votre setup chez vous, le serveur suit.",
    start: "Lire le guide VPS",
    github: "Étoile sur GitHub",
    copy: "Copier",
    copied: "Copié",
    stats: [["1", "commande"], ["9", "étapes"], ["~10", "minutes"], ["4", "langues"]],
    toast: "Claude attend votre réponse",
    stepsKicker: "Sous le capot",
    stepsTitle: "Neuf étapes. Tout en bash lisible.",
    stepDesc: [
      "apt upgrade, outils de base, swap et mises à jour de sécurité automatiques.",
      "Un utilisateur sudo avec vos clés SSH.",
      "Connexion par clé uniquement, pas de mot de passe root. Prioritaire sur cloud-init.",
      "ufw avec seulement SSH et RDP ouverts.",
      "KDE Plasma en session X11. Pas d'écran de connexion sur un serveur.",
      "xrdp sur le port 53389, qui lance Plasma, sans les invites colord.",
      "Docker, GitHub CLI et Chrome.",
      "Installation native de Claude Code et votre sujet ntfy.",
      "Votre disposition KDE, vos réglages Claude, hooks et config tmux.",
    ],
    stepsLink: "Lire chaque étape en détail",
    bentoKicker: "Ce que vous obtenez",
    bentoTitle: "Tout ce dont un agent qui tourne longtemps a besoin.",
    bento: [
      { t: "Claude Code, toujours actif", d: "Des sessions tmux qui survivent à une coupure SSH, avec vos réglages, vos hooks et votre barre d'état.", tag: "claude" },
      { t: "Votre KDE, pas celui par défaut", d: "Panneaux, raccourcis, tiling et profils Konsole, capturés chez vous et rejoués sur le serveur.", tag: "plasma" },
      { t: "Verrouillé", d: "SSH par clé, pas de connexion root par mot de passe, ufw, mises à jour automatiques.", tag: "security" },
      { t: "Prévient votre téléphone", d: "Un hook Notification envoie les questions de Claude sur ntfy.sh. Éloignez-vous.", tag: "ntfy" },
      { t: "Outils de dev", d: "Docker, GitHub CLI, Node, ripgrep, outils de compilation et Chrome.", tag: "tools" },
      { t: "Relançable", d: "Chaque étape vérifie d'abord l'existant. Relancez quand vous voulez, ou seulement --only ce qu'il faut.", tag: "idempotent" },
    ],
    flowKicker: "Restez synchronisé",
    flowTitle: "Réglez chez vous. Ça apparaît sur le serveur.",
    flowText: "Le dépôt fait foi. Publiez depuis votre machine, le serveur récupère à intervalles réguliers.",
    flow: [
      { cmd: "claude-vps publish", t: "Votre machine", d: "Capture la config KDE et Claude, nettoie les chemins personnels, commit et push." },
      { cmd: "git push", t: "GitHub", d: "Des fichiers simples dans dotfiles/home. Faciles à comparer et à relire." },
      { cmd: "claude-vps sync", t: "Serveur", d: "Récupère et applique, avec sauvegarde. Ou autosync toutes les 30 minutes." },
    ],
    ctaTitle: "Votre prochain serveur est à dix minutes.",
    ctaText: "Hetzner, DigitalOcean, une machine qui traîne à la maison : tout ce qui tourne sous Ubuntu 24.04 ou plus récent.",
    base: "/fr",
  },
  it: {
    badge: "Novità: la guida passo passo a Claude Code su VPS",
    title1: "Entra un server vuoto.",
    title2: "Esce la tua postazione Claude.",
    lead: "Un solo comando installa Claude Code, un desktop KDE Plasma completo via RDP, un SSH blindato ed esattamente la configurazione che uso ogni giorno. Cambi il setup a casa, il server si adegua.",
    start: "Leggi la guida VPS",
    github: "Stella su GitHub",
    copy: "Copia",
    copied: "Copiato",
    stats: [["1", "comando"], ["9", "passaggi"], ["~10", "minuti"], ["4", "lingue"]],
    toast: "Claude sta aspettando una tua risposta",
    stepsKicker: "Sotto il cofano",
    stepsTitle: "Nove passaggi. Tutto bash leggibile.",
    stepDesc: [
      "apt upgrade, strumenti di base, swap e aggiornamenti di sicurezza automatici.",
      "Un utente sudo con le tue chiavi SSH.",
      "Accesso solo con chiave, niente password per root. Ha la precedenza su cloud-init.",
      "ufw con solo SSH e RDP aperti.",
      "KDE Plasma con sessione X11. Nessuna schermata di login su un server.",
      "xrdp sulla porta 53389 che avvia Plasma, senza le richieste di colord.",
      "Docker, GitHub CLI e Chrome.",
      "Installazione nativa di Claude Code e il tuo topic ntfy.",
      "Il tuo layout KDE, le impostazioni di Claude, gli hook e la config di tmux.",
    ],
    stepsLink: "Leggi ogni passaggio nel dettaglio",
    bentoKicker: "Cosa ottieni",
    bentoTitle: "Tutto ciò che serve a un agente che lavora a lungo.",
    bento: [
      { t: "Claude Code, sempre acceso", d: "Sessioni tmux che sopravvivono a un SSH caduto, con le tue impostazioni, gli hook e la status line già pronti.", tag: "claude" },
      { t: "Il tuo KDE, non quello di default", d: "Pannelli, scorciatoie, tiling e profili Konsole, catturati a casa e riapplicati sul server.", tag: "plasma" },
      { t: "Blindato", d: "SSH solo con chiave, niente login root con password, ufw, aggiornamenti automatici.", tag: "security" },
      { t: "Avvisa il tuo telefono", d: "Un hook Notification manda le domande di Claude a ntfy.sh. Puoi allontanarti.", tag: "ntfy" },
      { t: "Strumenti di sviluppo", d: "Docker, GitHub CLI, Node, ripgrep, strumenti di build e Chrome.", tag: "tools" },
      { t: "Rieseguibile", d: "Ogni passaggio controlla prima cosa c'è già. Rilancialo quando vuoi, o solo --only quello che serve.", tag: "idempotent" },
    ],
    flowKicker: "Resta sincronizzato",
    flowTitle: "Modifica a casa. Compare sul server.",
    flowText: "Il repository è la fonte di verità. Pubblica dalla tua macchina, il server scarica a intervalli regolari.",
    flow: [
      { cmd: "claude-vps publish", t: "La tua macchina", d: "Cattura la config di KDE e Claude, ripulisce i percorsi personali, fa commit e push." },
      { cmd: "git push", t: "GitHub", d: "File semplici in dotfiles/home. Facili da confrontare e da rivedere." },
      { cmd: "claude-vps sync", t: "Server", d: "Scarica e applica, con backup. Oppure autosync ogni 30 minuti." },
    ],
    ctaTitle: "Il tuo prossimo server è a dieci minuti.",
    ctaText: "Hetzner, DigitalOcean, una macchina inutilizzata a casa: qualsiasi cosa con Ubuntu 24.04 o successivo.",
    base: "/it",
  },
  tr: {
    badge: "Yeni: adım adım Claude Code VPS rehberi",
    title1: "Boş bir sunucu girer.",
    title2: "Claude iş istasyonun çıkar.",
    lead: "Tek komut Claude Code'u, RDP üzerinden tam bir KDE Plasma masaüstünü, sıkılaştırılmış SSH'ı ve her gün kullandığım ayarların birebir aynısını kurar. Evde ayarını değiştir, sunucu da takip etsin.",
    start: "VPS rehberini oku",
    github: "GitHub'da yıldızla",
    copy: "Kopyala",
    copied: "Kopyalandı",
    stats: [["1", "komut"], ["9", "kurulum adımı"], ["~10", "dakika"], ["4", "dil"]],
    toast: "Claude senden yanıt bekliyor",
    stepsKicker: "Kaputun altı",
    stepsTitle: "Dokuz adım. Hepsi okunabilir bash.",
    stepDesc: [
      "apt upgrade, temel araçlar, swap ve otomatik güvenlik güncellemeleri.",
      "SSH anahtarların kopyalanmış bir sudo kullanıcısı.",
      "Sadece anahtarla giriş, root'a parola yok. cloud-init ayarlarını ezecek şekilde yazılır.",
      "Sadece SSH ve RDP açık bir ufw.",
      "X11 oturumuyla KDE Plasma. Ekransız sunucuda giriş ekranı yok.",
      "53389 portunda Plasma başlatan xrdp, colord parola soruları olmadan.",
      "Docker, GitHub CLI ve Chrome.",
      "Claude Code native kurulum ve ntfy topic'in.",
      "KDE düzenin, Claude ayarların, hook'ların ve tmux config'in.",
    ],
    stepsLink: "Her adımı detaylı oku",
    bentoKicker: "Neler geliyor",
    bentoTitle: "Uzun süre çalışan bir ajanın ihtiyacı olan her şey.",
    bento: [
      { t: "Claude Code, hep açık", d: "SSH kopsa da yaşayan tmux oturumları; ayarların, hook'lar ve status line hazır.", tag: "claude" },
      { t: "Varsayılan değil, senin KDE'n", d: "Paneller, kısayollar, tiling ve Konsole profilleri evden alınıp sunucuda aynen kurulur.", tag: "plasma" },
      { t: "Kilitli", d: "Sadece anahtarla SSH, root'a parolayla giriş yok, ufw, otomatik güncellemeler.", tag: "security" },
      { t: "Telefonuna haber verir", d: "Bir Notification hook'u Claude'un sorularını ntfy.sh'e yollar. Başından kalkabilirsin.", tag: "ntfy" },
      { t: "Geliştirici araçları", d: "Docker, GitHub CLI, Node, ripgrep, derleme araçları ve Chrome.", tag: "tools" },
      { t: "Tekrar çalıştırılabilir", d: "Her adım önce neyin kurulu olduğuna bakar. İstediğin zaman tekrar çalıştır ya da --only ile sadece gerekeni.", tag: "idempotent" },
    ],
    flowKicker: "Senkron kal",
    flowTitle: "Evde ayarla, sunucuda görün.",
    flowText: "Doğruluğun kaynağı repo. Kendi makinenden yayınla, sunucu belli aralıklarla çeksin.",
    flow: [
      { cmd: "claude-vps publish", t: "Senin makinen", d: "KDE ve Claude ayarlarını toplar, ev dizini yollarını temizler, commit edip push'lar." },
      { cmd: "git push", t: "GitHub", d: "dotfiles/home altında düz dosyalar. Diff'i de incelemesi de kolay." },
      { cmd: "claude-vps sync", t: "Sunucu", d: "Çeker ve yedek alarak uygular. İstersen autosync 30 dakikada bir yapar." },
    ],
    ctaTitle: "Bir sonraki sunucun on dakika uzağında.",
    ctaText: "Hetzner, DigitalOcean, evdeki boş bir makine: Ubuntu 24.04 ve üstünü çalıştıran her şey.",
    base: "/tr",
  },
} as const;

const s = computed(() => STRINGS[props.lang ?? "en"]);
const faq = computed(() => FAQ[props.lang ?? "en"]);
const link = (p: string) => withBase(s.value.base + p);

const copied = ref(false);
async function copy() {
  try {
    await navigator.clipboard.writeText(INSTALL);
    copied.value = true;
    setTimeout(() => (copied.value = false), 1600);
  } catch {
    /* clipboard can be blocked, the command stays selectable */
  }
}

/** Monitor tilts flat as the hero scrolls away, steps light up as they cross the middle. */
const stage = ref<HTMLElement | null>(null);
const tilt = ref(0);
const activeStep = ref(0);
const stepEls = ref<HTMLElement[]>([]);
let io: IntersectionObserver | null = null;
let revealIo: IntersectionObserver | null = null;
let ticking = false;

function onScroll() {
  if (ticking) return;
  ticking = true;
  requestAnimationFrame(() => {
    ticking = false;
    const el = stage.value;
    if (!el) return;
    const r = el.getBoundingClientRect();
    const vh = window.innerHeight;
    tilt.value = Math.min(1, Math.max(0, 1 - (r.top - vh * 0.12) / (vh * 0.55)));
  });
}

function spotlight(e: PointerEvent) {
  const el = e.currentTarget as HTMLElement;
  const b = el.getBoundingClientRect();
  el.style.setProperty("--mx", `${e.clientX - b.left}px`);
  el.style.setProperty("--my", `${e.clientY - b.top}px`);
}

onMounted(() => {
  onScroll();
  window.addEventListener("scroll", onScroll, { passive: true });
  window.addEventListener("resize", onScroll, { passive: true });
  io = new IntersectionObserver(
    (entries) => {
      for (const e of entries) {
        if (e.isIntersecting) activeStep.value = Number((e.target as HTMLElement).dataset.i);
      }
    },
    { rootMargin: "-45% 0px -45% 0px" },
  );
  stepEls.value.forEach((el) => io!.observe(el));
  revealIo = new IntersectionObserver(
    (entries) => {
      for (const e of entries) {
        if (e.isIntersecting) {
          e.target.classList.add("seen");
          revealIo!.unobserve(e.target);
        }
      }
    },
    { rootMargin: "0px 0px -12% 0px" },
  );
  document.querySelectorAll(".lx [data-reveal]").forEach((el) => revealIo!.observe(el));
});

onBeforeUnmount(() => {
  window.removeEventListener("scroll", onScroll);
  window.removeEventListener("resize", onScroll);
  io?.disconnect();
  revealIo?.disconnect();
});
</script>

<template>
  <div class="lx">
    <!-- Hero -->
    <section class="lx-hero">
      <AuroraCanvas class="lx-aurora" :dark="isDark" />
      <div class="lx-grain" aria-hidden="true" />

      <div class="lx-hero-inner">
        <a class="lx-badge" :href="link('/guide/claude-code-vps')">
          <span class="spark" />{{ s.badge }}<span class="arr">→</span>
        </a>

        <h1 class="lx-title">
          <span class="l1">
            <span v-for="(w, i) in s.title1.split(' ')" :key="'a' + i" class="w" :style="{ '--d': i * 70 + 'ms' }">{{ w }}&nbsp;</span>
          </span>
          <span class="l2 grad">{{ s.title2 }}</span>
        </h1>

        <p class="lx-lead">{{ s.lead }}</p>

        <div class="lx-beam" @click="copy">
          <div class="lx-beam-in">
            <span class="ps">$</span>
            <code>{{ INSTALL }}</code>
            <button type="button" class="lx-copy" :class="{ done: copied }">{{ copied ? s.copied : s.copy }}</button>
          </div>
        </div>

        <div class="lx-actions">
          <a class="lx-btn primary" :href="link('/guide/claude-code-vps')">{{ s.start }}<span class="arr">→</span></a>
          <a class="lx-btn ghost" :href="REPO" target="_blank" rel="noreferrer">
            <svg viewBox="0 0 16 16" width="16" height="16" aria-hidden="true"><path fill="currentColor" d="M8 .2a8 8 0 0 0-2.5 15.6c.4 0 .5-.2.5-.4v-1.5c-2.2.5-2.7-1-2.7-1-.4-.9-.9-1.2-.9-1.2-.7-.5.1-.5.1-.5.8.1 1.2.8 1.2.8.7 1.3 1.9.9 2.3.7.1-.5.3-.9.5-1.1-1.8-.2-3.6-.9-3.6-4 0-.9.3-1.6.8-2.1-.1-.2-.4-1 .1-2.1 0 0 .7-.2 2.2.8a7.5 7.5 0 0 1 4 0c1.5-1 2.2-.8 2.2-.8.4 1.1.2 1.9.1 2.1.5.6.8 1.3.8 2.1 0 3.1-1.9 3.8-3.6 4 .3.3.6.8.6 1.5v2.2c0 .2.1.5.6.4A8 8 0 0 0 8 .2Z" /></svg>
            {{ s.github }}
          </a>
        </div>
      </div>

      <div ref="stage" class="lx-stage" :style="{ '--p': tilt }">
        <div class="lx-monitor">
          <div class="lx-monitor-glow" aria-hidden="true" />
          <div class="lx-screen"><BootScreen :toast="s.toast" /></div>
        </div>
      </div>
    </section>

    <!-- Stack marquee -->
    <section class="lx-marquee" aria-label="Stack">
      <div class="track mono">
        <span v-for="(t, i) in [...STACK, ...STACK]" :key="i">{{ t }}<i>✦</i></span>
      </div>
    </section>

    <!-- Numbers -->
    <section class="lx-numbers" data-reveal>
      <div v-for="[n, l] in s.stats" :key="l" class="num">
        <strong>{{ n }}</strong>
        <span>{{ l }}</span>
      </div>
    </section>

    <!-- Sticky steps -->
    <section class="lx-steps">
      <div class="lx-steps-sticky">
        <span class="lx-kicker">{{ s.stepsKicker }}</span>
        <h2 class="lx-h2">{{ s.stepsTitle }}</h2>
        <div class="lx-dial">
          <svg viewBox="0 0 120 120" aria-hidden="true">
            <circle cx="60" cy="60" r="52" class="track" />
            <circle cx="60" cy="60" r="52" class="fill" :style="{ strokeDashoffset: 327 - (327 * (activeStep + 1)) / 9 }" />
          </svg>
          <div class="dial-num mono">{{ String(activeStep + 1).padStart(2, "0") }}<small>/09</small></div>
        </div>
        <div class="lx-steps-term mono">
          <span class="arrow">==&gt;</span> {{ STEP_NAMES[activeStep] }}<br />
          <span class="ok">✓</span> {{ STEP_OUT[activeStep] }}
        </div>
        <a class="lx-link" :href="link('/guide/what-it-installs')">{{ s.stepsLink }} →</a>
      </div>
      <ol class="lx-steps-list">
        <li
          v-for="(name, i) in STEP_NAMES"
          :key="name"
          ref="stepEls"
          :data-i="i"
          :class="{ active: i === activeStep, past: i < activeStep }"
        >
          <span class="idx mono">{{ String(i + 1).padStart(2, "0") }}</span>
          <div>
            <h3 class="mono">{{ name }}</h3>
            <p>{{ s.stepDesc[i] }}</p>
          </div>
        </li>
      </ol>
    </section>

    <!-- Bento -->
    <section class="lx-section">
      <div class="lx-head" data-reveal>
        <span class="lx-kicker">{{ s.bentoKicker }}</span>
        <h2 class="lx-h2">{{ s.bentoTitle }}</h2>
      </div>
      <div class="lx-bento">
        <article v-for="(b, i) in s.bento" :key="b.tag" :class="['card', `c${i}`]" data-reveal :style="{ '--d': i * 60 + 'ms' }" @pointermove="spotlight">
          <div class="viz" aria-hidden="true">
            <div v-if="i === 0" class="v-tmux mono">
              <div class="v-line"><span class="spark">✻</span> refactoring auth module<span class="caret" /></div>
              <div class="v-bar"><span class="on">0:claude*</span><span>1:tests</span><span>2:logs</span><em>up 14d 3h</em></div>
            </div>
            <div v-else-if="i === 1" class="v-swatch">
              <span v-for="c in 5" :key="c" :style="{ '--c': c }" />
            </div>
            <div v-else-if="i === 2" class="v-lock">
              <svg viewBox="0 0 48 48"><path class="shackle" d="M15 21v-6a9 9 0 0 1 18 0v6" /><rect x="10" y="21" width="28" height="20" rx="5" /><circle cx="24" cy="31" r="2.6" /></svg>
            </div>
            <div v-else-if="i === 3" class="v-phone">
              <div class="v-note"><b>Claude Code</b><span>{{ s.toast }}</span></div>
            </div>
            <div v-else-if="i === 4" class="v-chips mono">
              <span v-for="t in ['docker', 'gh', 'node', 'rg', 'chrome', 'tmux']" :key="t">{{ t }}</span>
            </div>
            <div v-else class="v-rerun mono">
              <span>sudo claude-vps setup --only desktop,rdp</span>
              <svg viewBox="0 0 24 24"><path d="M20 12a8 8 0 1 1-2.3-5.7M20 4v5h-5" /></svg>
            </div>
          </div>
          <span class="tag mono">{{ b.tag }}</span>
          <h3>{{ b.t }}</h3>
          <p>{{ b.d }}</p>
        </article>
      </div>
    </section>

    <!-- Flow -->
    <section class="lx-section">
      <div class="lx-head" data-reveal>
        <span class="lx-kicker">{{ s.flowKicker }}</span>
        <h2 class="lx-h2">{{ s.flowTitle }}</h2>
        <p>{{ s.flowText }}</p>
      </div>
      <div class="lx-flow" data-reveal>
        <template v-for="(f, i) in s.flow" :key="f.t">
          <div class="node" @pointermove="spotlight">
            <span class="idx mono">0{{ i + 1 }}</span>
            <h3>{{ f.t }}</h3>
            <code>{{ f.cmd }}</code>
            <p>{{ f.d }}</p>
          </div>
          <div v-if="i < s.flow.length - 1" class="wire" aria-hidden="true">
            <svg viewBox="0 0 100 10" preserveAspectRatio="none"><line x1="0" y1="5" x2="100" y2="5" class="base" /><line x1="0" y1="5" x2="100" y2="5" class="pulse" /></svg>
          </div>
        </template>
      </div>
    </section>

    <!-- FAQ -->
    <section class="lx-section">
      <div class="lx-head" data-reveal>
        <span class="lx-kicker">FAQ</span>
        <h2 class="lx-h2">{{ faq.title }}</h2>
      </div>
      <div class="lx-faq" data-reveal>
        <details v-for="(f, i) in faq.items" :key="f.q" :open="i === 0">
          <summary>{{ f.q }}</summary>
          <p>{{ f.a }}</p>
        </details>
      </div>
    </section>

    <!-- CTA -->
    <section class="lx-cta" data-reveal>
      <div class="lx-cta-glow" aria-hidden="true" />
      <h2>{{ s.ctaTitle }}</h2>
      <p>{{ s.ctaText }}</p>
      <div class="lx-beam" @click="copy">
        <div class="lx-beam-in">
          <span class="ps">$</span>
          <code>{{ INSTALL }}</code>
          <button type="button" class="lx-copy" :class="{ done: copied }">{{ copied ? s.copied : s.copy }}</button>
        </div>
      </div>
    </section>
  </div>
</template>
