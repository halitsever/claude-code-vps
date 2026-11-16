<script setup lang="ts">
import { computed, onBeforeUnmount, onMounted, ref } from "vue";
import { useData, withBase } from "vitepress";
import AuroraCanvas from "./AuroraCanvas.vue";
import BootScreen from "./BootScreen.vue";
import { LOCALES } from "../i18n";

const props = defineProps<{ lang?: string }>();
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


const locale = computed(() => LOCALES[!props.lang || props.lang === "en" ? "root" : props.lang] ?? LOCALES.root);
const languageCount = String(Object.keys(LOCALES).length);
const s = computed(() => {
  const l = locale.value.landing;
  const stats = l.stats.map((row, i) => (i === l.stats.length - 1 ? [languageCount, row[1]] : row));
  return { ...l, stats };
});
const faq = computed(() => locale.value.faq);
const link = (p: string) => withBase(locale.value.meta.prefix + p);

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
