/** Pages that exist only in English, so other locales have no matching page to link to. */
export const isEnglishOnly = (relativePath: string) => relativePath.startsWith("blog/") || relativePath === "claude-code-on-your-phone.md";
