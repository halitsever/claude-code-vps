<script setup lang="ts">
import { onBeforeUnmount, onMounted, ref } from "vue";

const props = defineProps<{ toast: string }>();

type Phase = "boot" | "install" | "reveal" | "desktop";

const INSTALL = [
  ["base", "base system ready"],
  ["user", "created dev"],
  ["ssh", "SSH accepts keys only"],
  ["firewall", "firewall on"],
  ["desktop", "KDE Plasma installed"],
  ["rdp", "xrdp listening on 53389"],
  ["apps", "Docker, gh and browser ready"],
  ["claude", "Claude Code installed"],
  ["dotfiles", "31 files updated"],
];

const CLAUDE = [
  { k: "you", t: "add rate limiting to the upload route" },
  { k: "tool", t: "Read src/routes/upload.ts" },
  { k: "tool", t: "Edit src/middleware/rate-limit.ts" },
  { k: "tool", t: "Bash npm test" },
  { k: "ok", t: "14 passed, 0 failed" },
];

const phase = ref<Phase>("boot");
const bootLines = ref(0);
const done = ref(0);
const typed = ref("");
const claudeLines = ref(0);
const windows = ref(0);
const showToast = ref(false);
const clock = ref("21:47");

let timers: number[] = [];
let alive = true;
const wait = (ms: number) => new Promise<void>((r) => timers.push(window.setTimeout(r, ms)));

const CMD = "curl -fsSL .../install.sh | sudo bash";

async function play() {
  while (alive) {
    phase.value = "boot";
    bootLines.value = 0;
    done.value = 0;
    typed.value = "";
    claudeLines.value = 0;
    windows.value = 0;
    showToast.value = false;

    for (let i = 1; i <= 3; i++) {
      await wait(260);
      bootLines.value = i;
    }
    await wait(350);
    for (const ch of CMD) {
      typed.value += ch;
      await wait(24 + Math.random() * 30);
    }
    await wait(300);
    phase.value = "install";
    for (let i = 1; i <= INSTALL.length; i++) {
      await wait(340);
      done.value = i;
    }
    await wait(700);
    phase.value = "reveal";
    await wait(900);
    phase.value = "desktop";
    for (let i = 1; i <= 3; i++) {
      await wait(280);
      windows.value = i;
    }
    for (let i = 1; i <= CLAUDE.length; i++) {
      await wait(i === 1 ? 500 : 650);
      claudeLines.value = i;
    }
    await wait(500);
    showToast.value = true;
    await wait(4200);
  }
}

onMounted(() => {
  const d = new Date();
  clock.value = `${String(d.getHours()).padStart(2, "0")}:${String(d.getMinutes()).padStart(2, "0")}`;
  if (window.matchMedia("(prefers-reduced-motion: reduce)").matches) {
    phase.value = "desktop";
    windows.value = 3;
    claudeLines.value = CLAUDE.length;
    showToast.value = true;
    return;
  }
  play();
});

onBeforeUnmount(() => {
  alive = false;
  timers.forEach(clearTimeout);
});
</script>

<template>
  <div class="boot" :class="phase" aria-hidden="true">
    <!-- Console: boot and install -->
    <div class="tty mono">
      <div v-if="bootLines >= 1" class="dim">Ubuntu 26.04 LTS ubuntu tty1</div>
      <div v-if="bootLines >= 2" class="dim">ubuntu login: root</div>
      <div v-if="bootLines >= 3" class="dim">Last login: just now from 203.0.113.7</div>
      <div v-if="bootLines >= 3" class="cmdline">
        <span class="ps">root@ubuntu:~#</span> {{ typed }}<span v-if="phase === 'boot'" class="caret" />
      </div>
      <template v-if="phase !== 'boot'">
        <div v-for="(s, i) in INSTALL.slice(0, done)" :key="s[0]" class="step">
          <span class="arrow">==&gt;</span> <span class="name">{{ s[0] }}</span>
          <span class="ok">✓</span> <span class="dim">{{ s[1] }}</span>
        </div>
        <div class="bar">
          <span :style="{ width: (done / INSTALL.length) * 100 + '%' }" />
        </div>
        <div class="dim small">claude-vps setup · {{ done }}/{{ INSTALL.length }}</div>
      </template>
    </div>

    <!-- Plasma desktop -->
    <div class="desk">
      <div class="wall" />

      <div class="win konsole" :class="{ in: windows >= 1 }">
        <div class="bar-t"><span>claude ~ Konsole</span><i /><i /><i /></div>
        <div class="body mono">
          <div class="banner"><span class="spark">✻</span> Claude Code <span class="dim">~/projects/api</span></div>
          <template v-for="(l, i) in CLAUDE.slice(0, claudeLines)" :key="i">
            <div v-if="l.k === 'you'" class="you">&gt; {{ l.t }}</div>
            <div v-else-if="l.k === 'tool'" class="tool"><span class="bullet">●</span> {{ l.t }}</div>
            <div v-else class="okl"><span class="ok">✓</span> {{ l.t }}</div>
          </template>
          <div class="prompt">&gt; <span class="caret" /></div>
        </div>
        <div class="tmux mono"><span class="tab on">0:claude*</span><span class="tab">1:tests</span><span class="tab">2:logs</span><span class="r">dev@claude-vps</span></div>
      </div>

      <div class="win dolphin" :class="{ in: windows >= 2 }">
        <div class="bar-t"><span>projects ~ Dolphin</span><i /><i /><i /></div>
        <div class="files">
          <div v-for="f in ['api', 'web', 'infra', 'notes', 'dotfiles', 'scratch']" :key="f" class="file">
            <span class="folder" />{{ f }}
          </div>
        </div>
      </div>

      <div class="win chrome" :class="{ in: windows >= 3 }">
        <div class="bar-t"><span>localhost:3000</span><i /><i /><i /></div>
        <div class="page">
          <div class="pg-hero" />
          <div class="pg-line w70" />
          <div class="pg-line w50" />
          <div class="pg-cards"><span /><span /><span /></div>
        </div>
      </div>

      <div class="toast" :class="{ in: showToast }">
        <div class="t-icon" />
        <div>
          <div class="t-title">Claude Code</div>
          <div class="t-body">{{ props.toast }}</div>
        </div>
      </div>

      <div class="panel">
        <span class="launcher" />
        <span class="task on" /><span class="task" /><span class="task" />
        <span class="spacer" />
        <span class="tray mono">RDP 53389</span>
        <span class="clock">{{ clock }}</span>
      </div>
    </div>
  </div>
</template>
