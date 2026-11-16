/** Everything one site language needs: menus, landing copy and FAQ. */
export type Locale = {
  meta: {
    label: string;
    lang: string;
    og: string;
    prefix: string;
    homeTitle: string;
    description: string;
    nav: { vps: string; docs: string };
    sidebar: { guide: string; ref: string; pages: string[] };
    ui: {
      editLink: string;
      outline: string;
      prev: string;
      next: string;
      lastUpdated: string;
      darkMode: string;
      menu: string;
      top: string;
      langMenu: string;
    };
  };
  landing: {
    title1: string;
    title2: string;
    lead: string;
    start: string;
    github: string;
    copy: string;
    copied: string;
    /** The last pair's number is replaced with the real language count. */
    stats: string[][];
    toast: string;
    stepsKicker: string;
    stepsTitle: string;
    stepDesc: string[];
    stepsLink: string;
    bentoKicker: string;
    bentoTitle: string;
    bento: { t: string; d: string; tag: string }[];
    flowKicker: string;
    flowTitle: string;
    flowText: string;
    flow: { cmd: string; t: string; d: string }[];
    ctaTitle: string;
    ctaText: string;
  };
  faq: { title: string; items: { q: string; a: string }[] };
};
