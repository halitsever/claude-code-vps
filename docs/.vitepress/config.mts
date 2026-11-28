import { fileURLToPath } from "node:url";
import { defineConfig, type DefaultTheme, type HeadConfig } from "vitepress";
import { LOCALES as I18N } from "./theme/i18n";

const repo = "https://github.com/halitsever/claude-code-vps";
const hostname = "https://projects.halit.org";
const base = "/claude-code-vps/";
const siteUrl = hostname + base;
const siteName = "Claude Code VPS";

type Labels = { guide: string; ref: string; pages: string[] };

const LOCALES = Object.fromEntries(
  Object.entries(I18N).map(([key, l]) => [key, { prefix: l.meta.prefix, lang: l.meta.lang, og: l.meta.og }]),
) as Record<string, { prefix: string; lang: string; og: string }>;
type LocaleKey = string;

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

/** English-only pages: the blog and the phone landing page. They get no hreflang alternates. */
const BLOG: [string, string][] = [
  ["claude-code-remote-control", "Remote Control vs a server"],
  ["install-claude-code-linux", "Install Claude Code on Linux"],
  ["claude-code-notifications", "Claude Code notifications"],
  ["claude-code-ssh", "Claude Code over SSH"],
  ["ntfy-notifications", "Push notifications with ntfy"],
  ["ntfy-vs-gotify", "ntfy vs Gotify"],
  ["install-docker-ubuntu-server", "Install Docker on Ubuntu Server"],
  ["install-chrome-ubuntu-server", "Install Chrome on Ubuntu"],
];
const EN_ONLY = (path: string) => path === "blog/" || path.startsWith("blog/") || path === "claude-code-on-your-phone";

function sidebar(prefix: string, t: Labels): DefaultTheme.SidebarItem[] {
  const link = (i: number) => ({ text: t.pages[i], link: `${prefix}/${PAGES[i]}` });
  return [
    { text: t.guide, items: [0, 1, 2, 3, 4, 5].map(link) },
    { text: t.ref, items: [6, 7].map(link) },
  ];
}

const blogSidebar: DefaultTheme.SidebarItem[] = [
  {
    text: "Blog",
    items: [{ text: "All posts", link: "/blog/" }, ...BLOG.map(([slug, text]) => ({ text, link: `/blog/${slug}` }))],
  },
  { text: "Guides", items: [{ text: "Claude Code on your phone", link: "/claude-code-on-your-phone" }, { text: "Claude Code on a VPS", link: "/guide/claude-code-vps" }, { text: "Getting started", link: "/guide/getting-started" }] },
];

function nav(prefix: string, guide: string, vps: string): DefaultTheme.NavItem[] {
  return [
    { text: vps, link: `${prefix}/guide/claude-code-vps` },
    { text: guide, link: `${prefix}/guide/getting-started` },
    { text: "CLI", link: `${prefix}/reference/cli` },
    ...(prefix ? [] : [{ text: "Blog", link: "/blog/" }]),
  ];
}

/** Page path without locale prefix, e.g. "guide/sync" or "" for a home page. */
function barePath(relativePath: string): { locale: LocaleKey; path: string } {
  const clean = relativePath.replace(/(^|\/)index\.md$/, "$1").replace(/\.md$/, "");
  const first = clean.split("/")[0];
  if (first && first !== "root" && first in LOCALES) return { locale: first, path: clean.slice(first.length + 1) };
  return { locale: "root", path: clean };
}

const urlFor = (locale: LocaleKey, path: string) =>
  siteUrl + (LOCALES[locale].prefix ? LOCALES[locale].prefix.slice(1) + "/" : "") + path;

export default defineConfig({
  title: siteName,
  titleTemplate: `:title | ${siteName}`,
  base,
  cleanUrls: true,
  lastUpdated: true,
  /** keeps the page hash map out of every page's HTML, which Semrush reads as a low text-to-HTML ratio */
  metaChunk: true,
  appearance: "dark",
  sitemap: { hostname: siteUrl },
  vite: {
    resolve: {
      alias: [
        /** Swaps in theme/langs.ts so English-only pages do not link to translations that do not exist. */
        { find: /^\.\.?\/composables\/langs(\.js)?$/, replacement: fileURLToPath(new URL("./theme/langs.ts", import.meta.url)) },
      ],
    },
  },
  head: [
    /** Cloudflare Web Analytics, one token for every page on projects.halit.org. */
    ["script", { defer: "", src: "https://static.cloudflareinsights.com/beacon.min.js", "data-cf-beacon": '{"token": "dd7e54d3f48841c187d72d9dbb92a6b6"}' }],
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
        content: "claude code vps, claude code server, claude code ubuntu, claude code remote server, run claude code on server, run claude code remotely, claude code ssh, claude code tmux, claude vps guide, kde plasma xrdp, remote dev server, ai coding agent server",
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
    const desc = pageData.frontmatter.description || pageData.description || localeDesc;
    const fullTitle = pageData.frontmatter.titleTemplate === false ? title : `${title} | ${siteName}`;

    const head: HeadConfig[] = [
      ["link", { rel: "canonical", href: url }],
      ["meta", { property: "og:url", content: url }],
      ["meta", { property: "og:title", content: fullTitle }],
      ["meta", { property: "og:description", content: desc }],
      ["meta", { property: "og:locale", content: LOCALES[locale].og }],
      ["meta", { name: "twitter:title", content: fullTitle }],
      ["meta", { name: "twitter:description", content: desc }],
    ];
    if (!EN_ONLY(path)) {
      for (const key of Object.keys(LOCALES)) {
        head.push(["link", { rel: "alternate", hreflang: LOCALES[key].lang.startsWith("zh") ? "zh-Hans" : LOCALES[key].lang.slice(0, 2), href: urlFor(key, path) }]);
      }
      head.push(["link", { rel: "alternate", hreflang: "x-default", href: urlFor("root", path) }]);
    }

    const graph: Record<string, unknown>[] = [];
    if (path === "") {
      graph.push(
        { "@type": "WebSite", name: siteName, url: siteUrl, inLanguage: LOCALES[locale].lang },
        {
          "@type": "SoftwareSourceCode",
          "@id": `${url}#source`,
          name: "claude-code-vps",
          description: desc,
          url,
          codeRepository: repo,
          programmingLanguage: "Shell",
          license: "https://opensource.org/licenses/MIT",
          author: { "@type": "Person", name: "Halit Sever", url: "https://github.com/halitsever" },
        },
        {
          "@type": "FAQPage",
          mainEntity: I18N[locale].faq.items.map((f) => ({
            "@type": "Question",
            name: f.q,
            acceptedAnswer: { "@type": "Answer", text: f.a },
          })),
        },
      );
    } else if (path.startsWith("blog/") && path !== "blog/") {
      graph.push(
        {
          "@type": "BlogPosting",
          headline: title,
          description: desc,
          inLanguage: "en-US",
          url,
          mainEntityOfPage: url,
          image: siteUrl + "og.png",
          datePublished: pageData.frontmatter.date,
          dateModified: pageData.lastUpdated ? new Date(pageData.lastUpdated).toISOString() : pageData.frontmatter.date,
          author: { "@type": "Person", name: "Halit Sever", url: "https://halit.org" },
          publisher: { "@type": "Person", name: "Halit Sever", url: "https://halit.org" },
        },
        {
          "@type": "BreadcrumbList",
          itemListElement: [
            { "@type": "ListItem", position: 1, name: siteName, item: siteUrl },
            { "@type": "ListItem", position: 2, name: "Blog", item: siteUrl + "blog/" },
            { "@type": "ListItem", position: 3, name: title, item: url },
          ],
        },
      );
    } else if (path === "blog/") {
      graph.push({ "@type": "Blog", name: `${siteName} blog`, description: desc, url, inLanguage: "en-US", author: { "@type": "Person", name: "Halit Sever", url: "https://halit.org" } });
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
    const faq = pageData.frontmatter.faq as { q: string; a: string }[] | undefined;
    if (faq?.length) {
      graph.push({ "@type": "FAQPage", mainEntity: faq.map((f) => ({ "@type": "Question", name: f.q, acceptedAnswer: { "@type": "Answer", text: f.a } })) });
    }
    head.push(["script", { type: "application/ld+json" }, JSON.stringify({ "@context": "https://schema.org", "@graph": graph })]);

    pageData.frontmatter.head ??= [];
    pageData.frontmatter.head.push(...head);
  },

  locales: Object.fromEntries(
    Object.entries(I18N).map(([key, l]) => {
      const p = l.meta.prefix;
      const u = l.meta.ui;
      return [
        key,
        {
          label: l.meta.label,
          lang: l.meta.lang,
          ...(p ? { link: `${p}/` } : {}),
          description: l.meta.description,
          themeConfig: {
            nav: nav(p, l.meta.nav.docs, l.meta.nav.vps),
            sidebar: p ? sidebar(p, l.meta.sidebar) : { "/blog/": blogSidebar, "/claude-code-on-your-phone": blogSidebar, "/": sidebar(p, l.meta.sidebar) },
            editLink: { pattern: `${repo}/edit/main/docs/:path`, text: u.editLink },
            outline: { label: u.outline },
            docFooter: { prev: u.prev, next: u.next },
            lastUpdated: { text: u.lastUpdated },
            darkModeSwitchLabel: u.darkMode,
            sidebarMenuLabel: u.menu,
            returnToTopLabel: u.top,
            langMenuLabel: u.langMenu,
          },
        },
      ];
    }),
  ),

  themeConfig: {
    logo: { src: "/logo.svg", alt: "Claude Code VPS logo" },
    siteTitle: "Claude Code VPS",
    socialLinks: [{ icon: "github", link: repo }],
    search: { provider: "local" },
    footer: {
      message: "MIT licensed. Not affiliated with Anthropic.",
      copyright: "© 2026 Halit Sever",
    },
  },
});
