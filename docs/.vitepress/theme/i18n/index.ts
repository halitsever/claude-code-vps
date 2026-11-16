import type { Locale } from "./types";
import en from "./en";
import es from "./es";
import de from "./de";
import fr from "./fr";
import pt from "./pt";
import it from "./it";
import ru from "./ru";
import zh from "./zh";
import ja from "./ja";
import ko from "./ko";
import tr from "./tr";

/** Site languages in menu order. The key is the URL prefix, "root" is English at "/". */
export const LOCALES: Record<string, Locale> = { root: en, es, de, fr, pt, it, ru, zh, ja, ko, tr };

export type LocaleKey = keyof typeof LOCALES;
export type { Locale };
