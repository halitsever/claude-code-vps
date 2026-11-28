import { computed } from "vue";
import { useData } from "vitepress";
import { isEnglishOnly } from "./english-only";

/** VitePress's useLangs, except English-only pages link each language to its home instead of a page that does not exist. */
export function useLangs({ correspondingLink = false } = {}) {
  const { site, localeIndex, page, theme, hash } = useData();
  const currentLang = computed(() => ({
    label: site.value.locales[localeIndex.value]?.label,
    link: site.value.locales[localeIndex.value]?.link || (localeIndex.value === "root" ? "/" : `/${localeIndex.value}/`),
  }));
  const localeLinks = computed(() =>
    Object.entries(site.value.locales).flatMap(([key, value]) =>
      currentLang.value.label === value.label
        ? []
        : {
            text: value.label,
            link:
              normalizeLink(
                value.link || (key === "root" ? "/" : `/${key}/`),
                theme.value.i18nRouting !== false && correspondingLink && !isEnglishOnly(page.value.relativePath),
                page.value.relativePath.slice(currentLang.value.link.length - 1),
                !site.value.cleanUrls,
              ) + hash.value,
          },
    ),
  );
  return { localeLinks, currentLang };
}

function normalizeLink(link: string, addPath: boolean, path: string, addExt: boolean) {
  if (!addPath) return link;
  const p = path.replace(/(^|\/)index\.md$/, "$1").replace(/\.md$/, addExt ? ".html" : "");
  return link.replace(/\/$/, "") + (p.startsWith("/") ? p : "/" + p);
}
