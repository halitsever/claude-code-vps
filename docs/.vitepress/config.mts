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

function sidebarFor(prefix: string, t: { guide: string; ref: string; pages: string[] }): DefaultTheme.SidebarItem[] {
  const [start, installs, rdp, claude, sync, cli, trouble] = t.pages;
  return [
    {
      text: t.guide,
      items: [
        { text: start, link: `${prefix}/guide/getting-started` },
        { text: installs, link: `${prefix}/guide/what-it-installs` },
        { text: rdp, link: `${prefix}/guide/remote-desktop` },
        { text: claude, link: `${prefix}/guide/claude-code` },
        { text: sync, link: `${prefix}/guide/sync` },
      ],
    },
    {
      text: t.ref,
      items: [
        { text: cli, link: `${prefix}/reference/cli` },
        { text: trouble, link: `${prefix}/reference/troubleshooting` },
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
    fr: {
      label: "Français",
      lang: "fr-FR",
      link: "/fr/",
      description: "Une seule commande transforme un serveur Ubuntu vierge en poste Claude Code distant, avec KDE Plasma, RDP et votre propre configuration.",
      themeConfig: {
        nav: [
          { text: "Guide", link: "/fr/guide/getting-started" },
          { text: "CLI", link: "/fr/reference/cli" },
        ],
        sidebar: sidebarFor("/fr", {
          guide: "Guide",
          ref: "Référence",
          pages: ["Bien démarrer", "Ce qui est installé", "Bureau à distance", "Utiliser Claude Code", "Synchroniser la config", "CLI", "Dépannage"],
        }),
        editLink: { pattern: `${repo}/edit/main/docs/:path`, text: "Modifier cette page sur GitHub" },
        outline: { label: "Sur cette page" },
        docFooter: { prev: "Précédent", next: "Suivant" },
        lastUpdated: { text: "Dernière mise à jour" },
        darkModeSwitchLabel: "Apparence",
        sidebarMenuLabel: "Menu",
        returnToTopLabel: "Retour en haut",
        langMenuLabel: "Langue",
      },
    },
    it: {
      label: "Italiano",
      lang: "it-IT",
      link: "/it/",
      description: "Un solo comando trasforma un server Ubuntu vuoto in una postazione Claude Code remota, con KDE Plasma, RDP e la tua configurazione.",
      themeConfig: {
        nav: [
          { text: "Guida", link: "/it/guide/getting-started" },
          { text: "CLI", link: "/it/reference/cli" },
        ],
        sidebar: sidebarFor("/it", {
          guide: "Guida",
          ref: "Riferimento",
          pages: ["Per iniziare", "Cosa viene installato", "Desktop remoto", "Usare Claude Code", "Sincronizzare la config", "CLI", "Risoluzione problemi"],
        }),
        editLink: { pattern: `${repo}/edit/main/docs/:path`, text: "Modifica questa pagina su GitHub" },
        outline: { label: "In questa pagina" },
        docFooter: { prev: "Precedente", next: "Successivo" },
        lastUpdated: { text: "Ultimo aggiornamento" },
        darkModeSwitchLabel: "Aspetto",
        sidebarMenuLabel: "Menu",
        returnToTopLabel: "Torna su",
        langMenuLabel: "Lingua",
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
