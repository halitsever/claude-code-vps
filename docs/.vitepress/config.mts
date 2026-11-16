import { defineConfig, type DefaultTheme } from "vitepress";

const repo = "https://github.com/halitsever/claude-vps";
const hostname = "https://halitsever.github.io";
const base = "/claude-vps/";
const siteUrl = hostname + base;

function sidebarEn(): DefaultTheme.SidebarItem[] {
  return [
    {
      text: "Guide",
      items: [
        { text: "Getting started", link: "/guide/getting-started" },
        { text: "What gets installed", link: "/guide/what-it-installs" },
        { text: "Remote desktop", link: "/guide/remote-desktop" },
        { text: "Running Claude Code", link: "/guide/claude-code" },
        { text: "Keeping config in sync", link: "/guide/sync" },
      ],
    },
    {
      text: "Reference",
      items: [
        { text: "CLI", link: "/reference/cli" },
        { text: "Troubleshooting", link: "/reference/troubleshooting" },
      ],
    },
  ];
}

function sidebarTr(): DefaultTheme.SidebarItem[] {
  return [
    {
      text: "Rehber",
      items: [
        { text: "Başlarken", link: "/tr/guide/getting-started" },
        { text: "Neler kuruluyor", link: "/tr/guide/what-it-installs" },
        { text: "Uzak masaüstü", link: "/tr/guide/remote-desktop" },
        { text: "Claude Code'u çalıştırmak", link: "/tr/guide/claude-code" },
        { text: "Config senkronizasyonu", link: "/tr/guide/sync" },
      ],
    },
    {
      text: "Referans",
      items: [
        { text: "CLI", link: "/tr/reference/cli" },
        { text: "Sorun giderme", link: "/tr/reference/troubleshooting" },
      ],
    },
  ];
}

export default defineConfig({
  title: "claude-vps",
  base,
  cleanUrls: true,
  lastUpdated: true,
  appearance: "dark",
  sitemap: { hostname: siteUrl },
  head: [
    ["link", { rel: "icon", type: "image/svg+xml", href: base + "logo.svg" }],
    ["link", { rel: "preconnect", href: "https://fonts.googleapis.com" }],
    ["link", { rel: "preconnect", href: "https://fonts.gstatic.com", crossorigin: "" }],
    [
      "link",
      {
        rel: "stylesheet",
        href: "https://fonts.googleapis.com/css2?family=Inter+Tight:wght@500;600;700;800&family=JetBrains+Mono:wght@400;500;700&display=swap",
      },
    ],
    ["meta", { name: "theme-color", content: "#0b0a09" }],
    ["meta", { property: "og:type", content: "website" }],
    ["meta", { property: "og:site_name", content: "claude-vps" }],
  ],
  locales: {
    root: {
      label: "English",
      lang: "en-US",
      description: "One command turns a blank Ubuntu server into a remote Claude Code workstation with KDE Plasma, RDP and your own config.",
      themeConfig: {
        nav: [
          { text: "Guide", link: "/guide/getting-started" },
          { text: "CLI", link: "/reference/cli" },
        ],
        sidebar: sidebarEn(),
        editLink: { pattern: `${repo}/edit/main/docs/:path`, text: "Edit this page on GitHub" },
      },
    },
    tr: {
      label: "Türkçe",
      lang: "tr-TR",
      link: "/tr/",
      description: "Tek komutla boş bir Ubuntu sunucuyu KDE Plasma, RDP ve kendi ayarlarınla uzaktan Claude Code iş istasyonuna çevirir.",
      themeConfig: {
        nav: [
          { text: "Rehber", link: "/tr/guide/getting-started" },
          { text: "CLI", link: "/tr/reference/cli" },
        ],
        sidebar: sidebarTr(),
        editLink: { pattern: `${repo}/edit/main/docs/:path`, text: "Bu sayfayı GitHub'da düzenle" },
        outline: { label: "Bu sayfada" },
        docFooter: { prev: "Önceki", next: "Sonraki" },
        lastUpdated: { text: "Son güncelleme" },
        darkModeSwitchLabel: "Görünüm",
        sidebarMenuLabel: "Menü",
        returnToTopLabel: "Başa dön",
        langMenuLabel: "Dil",
      },
    },
  },
  themeConfig: {
    logo: "/logo.svg",
    socialLinks: [{ icon: "github", link: repo }],
    search: { provider: "local" },
    footer: {
      message: "MIT licensed. Not affiliated with Anthropic.",
      copyright: "© 2026 Halit Sever",
    },
  },
});
