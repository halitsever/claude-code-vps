import { defineConfig, type DefaultTheme, type HeadConfig } from "vitepress";
import { FAQ, type Lang } from "./theme/faq";

const repo = "https://github.com/halitsever/claude-code-vps";
const hostname = "https://halitsever.github.io";
const base = "/claude-code-vps/";
const siteUrl = hostname + base;
const siteName = "Claude Code VPS";

type Labels = { guide: string; ref: string; pages: string[] };

const LOCALES = {
  root: { prefix: "", lang: "en-US", og: "en_US" },
  fr: { prefix: "/fr", lang: "fr-FR", og: "fr_FR" },
  it: { prefix: "/it", lang: "it-IT", og: "it_IT" },
  tr: { prefix: "/tr", lang: "tr-TR", og: "tr_TR" },
} as const;

const PAGES = [
  "guide/claude-code-vps",
  "guide/getting-started",
  "guide/what-it-installs",
  "guide/remote-desktop",
  "guide/claude-code",
  "guide/sync",
  "reference/cli",
  "reference/troubleshooting",
];

function sidebar(prefix: string, t: Labels): DefaultTheme.SidebarItem[] {
  const link = (i: number) => ({ text: t.pages[i], link: `${prefix}/${PAGES[i]}` });
  return [
    { text: t.guide, items: [0, 1, 2, 3, 4, 5].map(link) },
    { text: t.ref, items: [6, 7].map(link) },
  ];
}

function nav(prefix: string, guide: string, vps: string): DefaultTheme.NavItem[] {
  return [
    { text: vps, link: `${prefix}/guide/claude-code-vps` },
    { text: guide, link: `${prefix}/guide/getting-started` },
    { text: "CLI", link: `${prefix}/reference/cli` },
  ];
}

/** Page path without locale prefix, e.g. "guide/sync" or "" for a home page. */
function barePath(relativePath: string): { locale: keyof typeof LOCALES; path: string } {
  const clean = relativePath.replace(/(^|\/)index\.md$/, "$1").replace(/\.md$/, "");
  const m = clean.match(/^(fr|it|tr)(?:\/|$)(.*)$/);
  return m ? { locale: m[1] as keyof typeof LOCALES, path: m[2] } : { locale: "root", path: clean };
}

const urlFor = (locale: keyof typeof LOCALES, path: string) =>
  siteUrl + (LOCALES[locale].prefix ? LOCALES[locale].prefix.slice(1) + "/" : "") + path;

export default defineConfig({
  title: siteName,
  titleTemplate: `:title | ${siteName}`,
  base,
  cleanUrls: true,
  lastUpdated: true,
  appearance: "dark",
  sitemap: { hostname: siteUrl },
  head: [
    ["link", { rel: "icon", type: "image/svg+xml", href: base + "logo.svg" }],
    ["link", { rel: "apple-touch-icon", href: base + "logo-180.png" }],
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
    ["meta", { name: "author", content: "Halit Sever" }],
    [
      "meta",
      {
        name: "keywords",
        content: "claude code vps, claude code server, claude code ubuntu, run claude code remotely, claude code ssh, claude code tmux, claude vps guide, kde plasma xrdp, remote dev server, ai coding agent server",
      },
    ],
    ["meta", { property: "og:type", content: "website" }],
    ["meta", { property: "og:site_name", content: siteName }],
    ["meta", { property: "og:image", content: siteUrl + "og.png" }],
    ["meta", { property: "og:image:width", content: "1200" }],
    ["meta", { property: "og:image:height", content: "630" }],
    ["meta", { name: "twitter:card", content: "summary_large_image" }],
    ["meta", { name: "twitter:image", content: siteUrl + "og.png" }],
  ],

  /** Canonical, hreflang, Open Graph and JSON-LD per page, so each language ranks on its own URL. */
  transformPageData(pageData, { siteConfig }) {
    if (pageData.isNotFound) return;
    const { locale, path } = barePath(pageData.relativePath);
    const url = urlFor(locale, path);
    const localeDesc = siteConfig.site.locales[locale]?.description ?? siteConfig.site.description;
    const title = pageData.frontmatter.title ?? pageData.title ?? siteName;
    const desc = pageData.frontmatter.description ?? pageData.description ?? localeDesc;
    const fullTitle = path === "" ? `${siteName}: ${title}` : `${title} | ${siteName}`;

    const head: HeadConfig[] = [
      ["link", { rel: "canonical", href: url }],
      ["meta", { property: "og:url", content: url }],
      ["meta", { property: "og:title", content: fullTitle }],
      ["meta", { property: "og:description", content: desc }],
      ["meta", { property: "og:locale", content: LOCALES[locale].og }],
      ["meta", { name: "twitter:title", content: fullTitle }],
      ["meta", { name: "twitter:description", content: desc }],
    ];
    for (const key of Object.keys(LOCALES) as (keyof typeof LOCALES)[]) {
      head.push(["link", { rel: "alternate", hreflang: LOCALES[key].lang.slice(0, 2), href: urlFor(key, path) }]);
    }
    head.push(["link", { rel: "alternate", hreflang: "x-default", href: urlFor("root", path) }]);

    const graph: Record<string, unknown>[] = [];
    if (path === "") {
      graph.push(
        { "@type": "WebSite", name: siteName, url: siteUrl, inLanguage: LOCALES[locale].lang },
        {
          "@type": "SoftwareApplication",
          name: "claude-vps",
          applicationCategory: "DeveloperApplication",
          operatingSystem: "Ubuntu 24.04, Ubuntu 26.04",
          description: desc,
          url,
          downloadUrl: repo,
          license: "https://opensource.org/licenses/MIT",
          offers: { "@type": "Offer", price: "0", priceCurrency: "USD" },
          author: { "@type": "Person", name: "Halit Sever", url: "https://github.com/halitsever" },
        },
        {
          "@type": "FAQPage",
          mainEntity: FAQ[(locale === "root" ? "en" : locale) as Lang].items.map((f) => ({
            "@type": "Question",
            name: f.q,
            acceptedAnswer: { "@type": "Answer", text: f.a },
          })),
        },
      );
    } else {
      graph.push({
        "@type": "TechArticle",
        headline: title,
        description: desc,
        inLanguage: LOCALES[locale].lang,
        url,
        author: { "@type": "Person", name: "Halit Sever", url: "https://github.com/halitsever" },
        ...(pageData.lastUpdated ? { dateModified: new Date(pageData.lastUpdated).toISOString() } : {}),
      });
    }
    head.push(["script", { type: "application/ld+json" }, JSON.stringify({ "@context": "https://schema.org", "@graph": graph })]);

    pageData.frontmatter.head ??= [];
    pageData.frontmatter.head.push(...head);
  },

  locales: {
    root: {
      label: "English",
      lang: "en-US",
      description: "Run Claude Code on a VPS. One command turns a blank Ubuntu server into a remote Claude Code workstation with KDE Plasma, RDP and your own config.",
      themeConfig: {
        nav: nav("", "Docs", "VPS guide"),
        sidebar: sidebar("", {
          guide: "Guide",
          ref: "Reference",
          pages: ["Claude Code on a VPS", "Getting started", "What gets installed", "Remote desktop", "Running Claude Code", "Keeping config in sync", "CLI", "Troubleshooting"],
        }),
        editLink: { pattern: `${repo}/edit/main/docs/:path`, text: "Edit this page on GitHub" },
      },
    },
    fr: {
      label: "Français",
      lang: "fr-FR",
      link: "/fr/",
      description: "Faire tourner Claude Code sur un VPS. Une seule commande transforme un serveur Ubuntu vierge en poste Claude Code distant, avec KDE Plasma et RDP.",
      themeConfig: {
        nav: nav("/fr", "Docs", "Guide VPS"),
        sidebar: sidebar("/fr", {
          guide: "Guide",
          ref: "Référence",
          pages: ["Claude Code sur un VPS", "Bien démarrer", "Ce qui est installé", "Bureau à distance", "Utiliser Claude Code", "Synchroniser la config", "CLI", "Dépannage"],
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
      description: "Eseguire Claude Code su un VPS. Un solo comando trasforma un server Ubuntu vuoto in una postazione Claude Code remota, con KDE Plasma e RDP.",
      themeConfig: {
        nav: nav("/it", "Docs", "Guida VPS"),
        sidebar: sidebar("/it", {
          guide: "Guida",
          ref: "Riferimento",
          pages: ["Claude Code su un VPS", "Per iniziare", "Cosa viene installato", "Desktop remoto", "Usare Claude Code", "Sincronizzare la config", "CLI", "Risoluzione problemi"],
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
      description: "Claude Code'u VPS'te çalıştır. Tek komutla boş bir Ubuntu sunucuyu KDE Plasma, RDP ve kendi ayarlarınla uzaktan Claude Code iş istasyonuna çevir.",
      themeConfig: {
        nav: nav("/tr", "Doküman", "VPS rehberi"),
        sidebar: sidebar("/tr", {
          guide: "Rehber",
          ref: "Referans",
          pages: ["VPS'te Claude Code", "Başlarken", "Neler kuruluyor", "Uzak masaüstü", "Claude Code'u çalıştırmak", "Config senkronizasyonu", "CLI", "Sorun giderme"],
        }),
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
    siteTitle: "Claude Code VPS",
    socialLinks: [{ icon: "github", link: repo }],
    search: { provider: "local" },
    footer: {
      message: "MIT licensed. Not affiliated with Anthropic.",
      copyright: "© 2026 Halit Sever",
    },
  },
});
