<script setup lang="ts">
import { onBeforeUnmount, onMounted, ref } from "vue";

type Line = { kind: "cmd" | "head" | "ok" | "dim" | "done" | "kv"; text: string; key?: string };

const SCRIPT: Line[] = [
  { kind: "cmd", text: "curl -fsSL https://raw.githubusercontent.com/halitsever/claude-vps/main/install.sh | sudo bash" },
  { kind: "head", text: "Preflight" },
  { kind: "ok", text: "Ubuntu 26.04 on amd64" },
  { kind: "head", text: "System update, core packages, swap" },
  { kind: "ok", text: "base system ready" },
  { kind: "head", text: "Key-only SSH, ufw, unattended upgrades" },
  { kind: "ok", text: "firewall on" },
  { kind: "head", text: "KDE Plasma (X11 session)" },
  { kind: "ok", text: "KDE Plasma installed" },
  { kind: "head", text: "xrdp on a custom port" },
  { kind: "ok", text: "xrdp listening on 53389" },
  { kind: "head", text: "Claude Code native install" },
  { kind: "ok", text: "Claude Code installed to ~/.local/bin/claude" },
  { kind: "head", text: "Your KDE, Claude and shell config" },
  { kind: "dim", text: "updated .config/kdeglobals" },
  { kind: "dim", text: "updated .claude/settings.json" },
  { kind: "ok", text: "31 files updated" },
  { kind: "done", text: "Done." },
  { kind: "kv", key: "SSH", text: "ssh dev@203.0.113.7" },
  { kind: "kv", key: "Desktop", text: "RDP to 203.0.113.7:53389" },
  { kind: "kv", key: "Claude", text: "tmux, then claude" },
];

const shown = ref<Line[]>([]);
const typed = ref("");
const typing = ref(false);
const body = ref<HTMLElement | null>(null);
let timers: number[] = [];
let alive = true;

const wait = (ms: number) =>
  new Promise<void>((resolve) => {
    timers.push(window.setTimeout(resolve, ms));
  });

function scrollDown() {
  requestAnimationFrame(() => {
    if (body.value) body.value.scrollTop = body.value.scrollHeight;
  });
}

async function play() {
  while (alive) {
    shown.value = [];
    typed.value = "";
    await wait(600);
    for (const line of SCRIPT) {
      if (!alive) return;
      if (line.kind === "cmd") {
        typing.value = true;
        for (const ch of line.text) {
          typed.value += ch;
          await wait(28 + Math.random() * 40);
        }
        await wait(350);
        typing.value = false;
        shown.value.push(line);
        typed.value = "";
      } else {
        await wait(line.kind === "head" ? 420 : line.kind === "ok" ? 520 : 160);
        shown.value.push(line);
      }
      scrollDown();
    }
    await wait(5200);
  }
}

onMounted(() => {
  if (window.matchMedia("(prefers-reduced-motion: reduce)").matches) {
    shown.value = [...SCRIPT];
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
  <div class="term" aria-hidden="true">
    <div class="term-bar">
      <span class="dot" /><span class="dot" /><span class="dot" />
      <span class="term-title">root@ubuntu: ~</span>
    </div>
    <div ref="body" class="term-body">
      <div v-for="(l, i) in shown" :key="i" :class="['ln', l.kind]">
        <template v-if="l.kind === 'cmd'"><span class="ps">#</span> {{ l.text }}</template>
        <template v-else-if="l.kind === 'head'"><span class="arrow">==&gt;</span> {{ l.text }}</template>
        <template v-else-if="l.kind === 'ok'"><span class="check">✓</span> {{ l.text }}</template>
        <template v-else-if="l.kind === 'kv'"><span class="k">{{ l.key }}</span>{{ l.text }}</template>
        <template v-else>{{ l.text }}</template>
      </div>
      <div v-if="typing || shown.length === 0" class="ln cmd">
        <span class="ps">#</span> {{ typed }}<span class="caret" />
      </div>
    </div>
  </div>
</template>
