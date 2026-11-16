<script setup lang="ts">
import { computed, ref } from "vue";
import { withBase } from "vitepress";
import TerminalDemo from "./TerminalDemo.vue";
import { FAQ } from "../faq";

const props = defineProps<{ lang?: "en" | "fr" | "it" | "tr" }>();

const INSTALL = "curl -fsSL https://raw.githubusercontent.com/halitsever/claude-code-vps/main/install.sh | sudo bash";
const REPO = "https://github.com/halitsever/claude-code-vps";

const STRINGS = {
  en: {
    eyebrow: "Ubuntu 24.04 / 26.04 · KDE Plasma 6 · Claude Code",
    title1: "A blank server in.",
    title2: "Your Claude workstation out.",
    lead: "One command installs Claude Code, a full KDE Plasma desktop over RDP, a hardened SSH setup and the exact config I use every day. Change your setup at home, and the server follows.",
    start: "Read the guide",
    github: "View on GitHub",
    copy: "Copy",
    copied: "Copied",
    stats: [
      ["1", "command"],
      ["9", "setup steps"],
      ["~10", "minutes"],
      ["0", "manual config"],
    ],
    desktopKicker: "The desktop",
    desktopTitle: "Plasma, one RDP connection away.",
    desktopText: "Connect with any RDP client, from a laptop, a tablet or a phone. Konsole, Dolphin and Chrome are already there, themed the way you left them.",
    bentoKicker: "What you get",
    bentoTitle: "Everything a long-running agent needs.",
    bento: [
      { t: "Claude Code, always on", d: "Native install for your user, tmux for sessions that survive a dropped SSH, and your global CLAUDE.md, hooks and status line already in place.", tag: "claude" },
      { t: "Your KDE, not a default one", d: "Panels, shortcuts, tiling, color scheme and Konsole profiles are captured from your machine and replayed on the server.", tag: "plasma" },
      { t: "Locked down", d: "Key-only SSH, no root password login, ufw, unattended security updates.", tag: "security" },
      { t: "Pings your phone", d: "A Notification hook sends “Claude is waiting” to ntfy.sh, so you can walk away.", tag: "ntfy" },
      { t: "Dev stack", d: "Docker, GitHub CLI, Node, ripgrep, build tools and Chrome for browser tasks.", tag: "tools" },
      { t: "Re-runnable", d: "Every step checks what is already there. Run it again after an upgrade or with --only.", tag: "idempotent" },
    ],
    flowKicker: "Stay in sync",
    flowTitle: "Tweak at home. It shows up on the server.",
    flowText: "The repo is the source of truth. Publish from your machine, the server pulls on a timer.",
    flow: [
      { cmd: "claude-vps publish", t: "Your machine", d: "Captures KDE and Claude config, scrubs home paths, commits and pushes." },
      { cmd: "git push", t: "GitHub", d: "Plain files in dotfiles/home. Easy to diff, easy to review." },
      { cmd: "claude-vps sync", t: "Server", d: "Pulls and applies, backing up anything it replaces. Or let autosync do it every 30 minutes." },
    ],
    stepsKicker: "Under the hood",
    stepsTitle: "Nine steps, all readable bash.",
    steps: ["base", "user", "ssh", "firewall", "desktop", "rdp", "apps", "claude", "dotfiles"],
    stepsLink: "See what each step does",
    ctaTitle: "Grab a fresh Ubuntu box and paste this.",
    ctaText: "Hetzner, DigitalOcean, a spare machine at home: anything that runs Ubuntu 24.04 or newer.",
    base: "",
  },
  tr: {
    eyebrow: "Ubuntu 24.04 / 26.04 · KDE Plasma 6 · Claude Code",
    title1: "Boş bir sunucu girer.",
    title2: "Claude iş istasyonun çıkar.",
    lead: "Tek komut Claude Code'u, RDP üzerinden tam bir KDE Plasma masaüstünü, sıkılaştırılmış SSH'ı ve her gün kullandığım ayarların birebir aynısını kurar. Evde ayarını değiştir, sunucu da takip etsin.",
    start: "Rehbere göz at",
    github: "GitHub'da gör",
    copy: "Kopyala",
    copied: "Kopyalandı",
    stats: [
      ["1", "komut"],
      ["9", "kurulum adımı"],
      ["~10", "dakika"],
      ["0", "elle ayar"],
    ],
    desktopKicker: "Masaüstü",
    desktopTitle: "Plasma, bir RDP bağlantısı uzağında.",
    desktopText: "Laptoptan, tabletten ya da telefondan herhangi bir RDP istemcisiyle bağlan. Konsole, Dolphin ve Chrome hazır, bıraktığın temayla.",
    bentoKicker: "Neler geliyor",
    bentoTitle: "Uzun süre çalışan bir ajanın ihtiyacı olan her şey.",
    bento: [
      { t: "Claude Code, hep açık", d: "Kullanıcına native kurulum, SSH kopsa da yaşayan tmux oturumları, global CLAUDE.md, hook'lar ve status line yerinde.", tag: "claude" },
      { t: "Varsayılan değil, senin KDE'n", d: "Paneller, kısayollar, tiling, renk şeması ve Konsole profilleri kendi makinenden alınıp sunucuya uygulanır.", tag: "plasma" },
      { t: "Kilitli", d: "Sadece anahtarla SSH, root'a parola ile giriş yok, ufw, otomatik güvenlik güncellemeleri.", tag: "security" },
      { t: "Telefonuna haber verir", d: "Bir Notification hook'u “Claude seni bekliyor” mesajını ntfy.sh'e yollar, başından kalkabilirsin.", tag: "ntfy" },
      { t: "Geliştirici araçları", d: "Docker, GitHub CLI, Node, ripgrep, derleme araçları ve tarayıcı işleri için Chrome.", tag: "tools" },
      { t: "Tekrar çalıştırılabilir", d: "Her adım önce neyin kurulu olduğuna bakar. Güncellemeden sonra tekrar ya da --only ile çalıştır.", tag: "idempotent" },
    ],
    flowKicker: "Senkron kal",
    flowTitle: "Evde ayarla, sunucuda görün.",
    flowText: "Doğruluğun kaynağı repo. Kendi makinenden yayınla, sunucu belli aralıklarla çeksin.",
    flow: [
      { cmd: "claude-vps publish", t: "Senin makinen", d: "KDE ve Claude ayarlarını toplar, ev dizini yollarını temizler, commit edip push'lar." },
      { cmd: "git push", t: "GitHub", d: "dotfiles/home altında düz dosyalar. Diff'i de incelemesi de kolay." },
      { cmd: "claude-vps sync", t: "Sunucu", d: "Çeker ve uygular, değiştirdiği her şeyin yedeğini alır. İstersen autosync 30 dakikada bir yapar." },
    ],
    stepsKicker: "Kaputun altı",
    stepsTitle: "Dokuz adım, hepsi okunabilir bash.",
    steps: ["base", "user", "ssh", "firewall", "desktop", "rdp", "apps", "claude", "dotfiles"],
    stepsLink: "Her adım ne yapıyor",
    ctaTitle: "Temiz bir Ubuntu makine al ve şunu yapıştır.",
    ctaText: "Hetzner, DigitalOcean, evdeki boş bir makine: Ubuntu 24.04 ve üstünü çalıştıran her şey.",
    base: "/tr",
  },
  fr: {
    eyebrow: "Ubuntu 24.04 / 26.04 · KDE Plasma 6 · Claude Code",
    title1: "Un serveur vide en entrée.",
    title2: "Votre poste Claude en sortie.",
    lead: "Une seule commande installe Claude Code, un bureau KDE Plasma complet via RDP, un SSH durci et exactement la configuration que j'utilise au quotidien. Modifiez votre setup chez vous, le serveur suit.",
    start: "Lire le guide",
    github: "Voir sur GitHub",
    copy: "Copier",
    copied: "Copié",
    stats: [
      ["1", "commande"],
      ["9", "étapes"],
      ["~10", "minutes"],
      ["0", "config manuelle"],
    ],
    desktopKicker: "Le bureau",
    desktopTitle: "Plasma, à une connexion RDP.",
    desktopText: "Connectez-vous avec n'importe quel client RDP, depuis un portable, une tablette ou un téléphone. Konsole, Dolphin et Chrome sont déjà là, avec le thème que vous avez laissé.",
    bentoKicker: "Ce que vous obtenez",
    bentoTitle: "Tout ce dont un agent qui tourne longtemps a besoin.",
    bento: [
      { t: "Claude Code, toujours actif", d: "Installation native pour votre utilisateur, tmux pour des sessions qui survivent à une coupure SSH, et votre CLAUDE.md global, vos hooks et votre barre d'état déjà en place.", tag: "claude" },
      { t: "Votre KDE, pas celui par défaut", d: "Panneaux, raccourcis, tiling, palette de couleurs et profils Konsole sont capturés sur votre machine et rejoués sur le serveur.", tag: "plasma" },
      { t: "Verrouillé", d: "SSH par clé uniquement, pas de connexion root par mot de passe, ufw, mises à jour de sécurité automatiques.", tag: "security" },
      { t: "Prévient votre téléphone", d: "Un hook Notification envoie « Claude vous attend » sur ntfy.sh, vous pouvez vous éloigner.", tag: "ntfy" },
      { t: "Outils de dev", d: "Docker, GitHub CLI, Node, ripgrep, outils de compilation et Chrome pour les tâches dans le navigateur.", tag: "tools" },
      { t: "Relançable", d: "Chaque étape vérifie d'abord ce qui est déjà installé. Relancez après une mise à niveau ou avec --only.", tag: "idempotent" },
    ],
    flowKicker: "Restez synchronisé",
    flowTitle: "Réglez chez vous. Ça apparaît sur le serveur.",
    flowText: "Le dépôt fait foi. Publiez depuis votre machine, le serveur récupère à intervalles réguliers.",
    flow: [
      { cmd: "claude-vps publish", t: "Votre machine", d: "Capture la config KDE et Claude, nettoie les chemins personnels, commit et push." },
      { cmd: "git push", t: "GitHub", d: "Des fichiers simples dans dotfiles/home. Faciles à comparer, faciles à relire." },
      { cmd: "claude-vps sync", t: "Serveur", d: "Récupère et applique, en sauvegardant tout ce qu'il remplace. Ou laissez autosync le faire toutes les 30 minutes." },
    ],
    stepsKicker: "Sous le capot",
    stepsTitle: "Neuf étapes, tout en bash lisible.",
    steps: ["base", "user", "ssh", "firewall", "desktop", "rdp", "apps", "claude", "dotfiles"],
    stepsLink: "Voir ce que fait chaque étape",
    ctaTitle: "Prenez un Ubuntu tout neuf et collez ceci.",
    ctaText: "Hetzner, DigitalOcean, une machine qui traîne à la maison : tout ce qui tourne sous Ubuntu 24.04 ou plus récent.",
    base: "/fr",
  },
  it: {
    eyebrow: "Ubuntu 24.04 / 26.04 · KDE Plasma 6 · Claude Code",
    title1: "Entra un server vuoto.",
    title2: "Esce la tua postazione Claude.",
    lead: "Un solo comando installa Claude Code, un desktop KDE Plasma completo via RDP, un SSH blindato ed esattamente la configurazione che uso ogni giorno. Cambi il setup a casa, il server si adegua.",
    start: "Leggi la guida",
    github: "Vedi su GitHub",
    copy: "Copia",
    copied: "Copiato",
    stats: [
      ["1", "comando"],
      ["9", "passaggi"],
      ["~10", "minuti"],
      ["0", "config manuale"],
    ],
    desktopKicker: "Il desktop",
    desktopTitle: "Plasma, a una connessione RDP di distanza.",
    desktopText: "Collegati con qualsiasi client RDP, da un portatile, un tablet o un telefono. Konsole, Dolphin e Chrome sono già lì, con il tema che hai lasciato.",
    bentoKicker: "Cosa ottieni",
    bentoTitle: "Tutto ciò che serve a un agente che lavora a lungo.",
    bento: [
      { t: "Claude Code, sempre acceso", d: "Installazione nativa per il tuo utente, tmux per sessioni che sopravvivono a un SSH caduto, e il tuo CLAUDE.md globale, gli hook e la status line già al loro posto.", tag: "claude" },
      { t: "Il tuo KDE, non quello di default", d: "Pannelli, scorciatoie, tiling, schema colori e profili di Konsole vengono catturati dalla tua macchina e riapplicati sul server.", tag: "plasma" },
      { t: "Blindato", d: "SSH solo con chiave, niente login root con password, ufw, aggiornamenti di sicurezza automatici.", tag: "security" },
      { t: "Avvisa il tuo telefono", d: "Un hook Notification manda «Claude ti sta aspettando» a ntfy.sh, così puoi allontanarti.", tag: "ntfy" },
      { t: "Strumenti di sviluppo", d: "Docker, GitHub CLI, Node, ripgrep, strumenti di build e Chrome per le attività nel browser.", tag: "tools" },
      { t: "Rieseguibile", d: "Ogni passaggio controlla prima cosa c'è già. Rilancialo dopo un aggiornamento o con --only.", tag: "idempotent" },
    ],
    flowKicker: "Resta sincronizzato",
    flowTitle: "Modifica a casa. Compare sul server.",
    flowText: "Il repository è la fonte di verità. Pubblica dalla tua macchina, il server scarica a intervalli regolari.",
    flow: [
      { cmd: "claude-vps publish", t: "La tua macchina", d: "Cattura la config di KDE e Claude, ripulisce i percorsi personali, fa commit e push." },
      { cmd: "git push", t: "GitHub", d: "File semplici in dotfiles/home. Facili da confrontare, facili da rivedere." },
      { cmd: "claude-vps sync", t: "Server", d: "Scarica e applica, facendo il backup di tutto ciò che sostituisce. Oppure lascia che autosync lo faccia ogni 30 minuti." },
    ],
    stepsKicker: "Sotto il cofano",
    stepsTitle: "Nove passaggi, tutto bash leggibile.",
    steps: ["base", "user", "ssh", "firewall", "desktop", "rdp", "apps", "claude", "dotfiles"],
    stepsLink: "Cosa fa ogni passaggio",
    ctaTitle: "Prendi un Ubuntu nuovo e incolla questo.",
    ctaText: "Hetzner, DigitalOcean, una macchina inutilizzata a casa: qualsiasi cosa con Ubuntu 24.04 o successivo.",
    base: "/it",
  },
} as const;

const s = computed(() => STRINGS[props.lang ?? "en"]);
const faq = computed(() => FAQ[props.lang ?? "en"]);
const copied = ref(false);

async function copy() {
  try {
    await navigator.clipboard.writeText(INSTALL);
    copied.value = true;
    setTimeout(() => (copied.value = false), 1600);
  } catch {
    /* clipboard can be blocked on http, the command stays selectable */
  }
}

const link = (p: string) => withBase(s.value.base + p);
</script>

<template>
  <div class="lx">
    <div class="lx-bg" aria-hidden="true">
      <div class="lx-orb a" />
      <div class="lx-orb b" />
      <div class="lx-orb c" />
      <div class="lx-grid" />
    </div>

    <section class="lx-hero">
      <div class="lx-hero-copy">
        <span class="lx-eyebrow"><span class="pulse" />{{ s.eyebrow }}</span>
        <h1 class="lx-title">
          <span>{{ s.title1 }}</span>
          <span class="grad">{{ s.title2 }}</span>
        </h1>
        <p class="lx-lead">{{ s.lead }}</p>

        <div class="lx-cmd" @click="copy">
          <span class="ps">$</span>
          <code>{{ INSTALL }}</code>
          <button type="button" class="lx-copy" :class="{ done: copied }">
            {{ copied ? s.copied : s.copy }}
          </button>
        </div>

        <div class="lx-actions">
          <a class="lx-btn primary" :href="link('/guide/claude-code-vps')">{{ s.start }} <span>→</span></a>
          <a class="lx-btn ghost" :href="REPO" target="_blank" rel="noreferrer">{{ s.github }}</a>
        </div>

        <dl class="lx-stats">
          <div v-for="[n, l] in s.stats" :key="l">
            <dt>{{ n }}</dt>
            <dd>{{ l }}</dd>
          </div>
        </dl>
      </div>

      <div class="lx-hero-visual">
        <TerminalDemo />
      </div>
    </section>

    <section class="lx-section">
      <div class="lx-head">
        <span class="lx-kicker">{{ s.desktopKicker }}</span>
        <h2>{{ s.desktopTitle }}</h2>
        <p>{{ s.desktopText }}</p>
      </div>
      <div class="lx-desk" aria-hidden="true">
        <div class="desk-wall" />
        <div class="desk-win konsole">
          <div class="win-bar"><span>claude ~ Konsole</span><i /><i /><i /></div>
          <div class="win-body mono">
            <div><span class="c-acc">✻</span> Welcome back!</div>
            <div class="c-dim">~/projects/api</div>
            <div class="c-box">&gt; add rate limiting to the upload route<span class="caret" /></div>
            <div class="c-dim">● Reading src/routes/upload.ts</div>
            <div class="c-dim">● Editing src/middleware/rate-limit.ts</div>
            <div><span class="c-ok">✓</span> 14 tests passed</div>
          </div>
        </div>
        <div class="desk-win dolphin">
          <div class="win-bar"><span>projects ~ Dolphin</span><i /><i /><i /></div>
          <div class="win-body files">
            <div v-for="f in ['api', 'web', 'infra', 'notes', 'dotfiles', 'scratch']" :key="f" class="file">
              <span class="folder" />{{ f }}
            </div>
          </div>
        </div>
        <div class="desk-panel">
          <span class="launcher" />
          <span class="task on" /><span class="task" /><span class="task" />
          <span class="spacer" />
          <span class="tray">RDP · 53389</span>
          <span class="clock">21:47</span>
        </div>
      </div>
    </section>

    <section class="lx-section">
      <div class="lx-head">
        <span class="lx-kicker">{{ s.bentoKicker }}</span>
        <h2>{{ s.bentoTitle }}</h2>
      </div>
      <div class="lx-bento">
        <article v-for="(b, i) in s.bento" :key="b.tag" :class="['card', `c${i}`]">
          <span class="tag mono">{{ b.tag }}</span>
          <h3>{{ b.t }}</h3>
          <p>{{ b.d }}</p>
        </article>
      </div>
    </section>

    <section class="lx-section">
      <div class="lx-head">
        <span class="lx-kicker">{{ s.flowKicker }}</span>
        <h2>{{ s.flowTitle }}</h2>
        <p>{{ s.flowText }}</p>
      </div>
      <div class="lx-flow">
        <template v-for="(f, i) in s.flow" :key="f.t">
          <div class="node">
            <span class="idx mono">0{{ i + 1 }}</span>
            <h3>{{ f.t }}</h3>
            <code>{{ f.cmd }}</code>
            <p>{{ f.d }}</p>
          </div>
          <div v-if="i < s.flow.length - 1" class="wire" aria-hidden="true"><span /></div>
        </template>
      </div>
    </section>

    <section class="lx-section">
      <div class="lx-head">
        <span class="lx-kicker">{{ s.stepsKicker }}</span>
        <h2>{{ s.stepsTitle }}</h2>
      </div>
      <ol class="lx-steps mono">
        <li v-for="(st, i) in s.steps" :key="st" :style="{ '--i': i }">
          <span>{{ String(i + 1).padStart(2, "0") }}</span>{{ st }}
        </li>
      </ol>
      <p class="lx-more"><a :href="link('/guide/what-it-installs')">{{ s.stepsLink }} →</a></p>
    </section>

    <section class="lx-section">
      <div class="lx-head">
        <span class="lx-kicker">FAQ</span>
        <h2>{{ faq.title }}</h2>
      </div>
      <div class="lx-faq">
        <details v-for="(f, i) in faq.items" :key="f.q" :open="i === 0">
          <summary>{{ f.q }}</summary>
          <p>{{ f.a }}</p>
        </details>
      </div>
    </section>

    <section class="lx-cta">
      <h2>{{ s.ctaTitle }}</h2>
      <p>{{ s.ctaText }}</p>
      <div class="lx-cmd" @click="copy">
        <span class="ps">$</span>
        <code>{{ INSTALL }}</code>
        <button type="button" class="lx-copy" :class="{ done: copied }">
          {{ copied ? s.copied : s.copy }}
        </button>
      </div>
    </section>
  </div>
</template>
