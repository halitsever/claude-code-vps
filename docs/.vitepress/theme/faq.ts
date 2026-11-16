/** Shared by the landing page and the FAQPage structured data in config.mts. */
export type Lang = "en" | "fr" | "it" | "tr";
export type Faq = { q: string; a: string };

export const FAQ: Record<Lang, { title: string; items: Faq[] }> = {
  en: {
    title: "Questions people ask",
    items: [
      { q: "Can Claude Code run on a VPS?", a: "Yes. Claude Code is a terminal app, so any Linux server works. You log in once through a link you open on your own device, and it keeps running inside tmux after you disconnect." },
      { q: "What size server do I need for Claude Code?", a: "2 vCPU and 4 GB RAM is enough for the terminal. With the KDE Plasma desktop, 4 vCPU and 8 GB RAM feels like a real workstation." },
      { q: "Which Ubuntu versions does claude-vps support?", a: "Ubuntu 24.04 LTS and newer, including 26.04 LTS. amd64 gets everything, arm64 works without Chrome." },
      { q: "Do I need a Claude subscription?", a: "You need a plan that includes Claude Code (Pro or Max) or an Anthropic API key. claude-vps itself is free and MIT licensed." },
      { q: "Is it safe to expose RDP?", a: "xrdp encrypts the session and runs on a non-default port, but you can also keep it closed with --rdp-private and reach it through an SSH tunnel." },
      { q: "Can I use my own KDE and Claude settings?", a: "Yes. Fork the repo, run claude-vps capture on your machine and point the installer at your fork. The server then follows every change you publish." },
    ],
  },
  fr: {
    title: "Questions fréquentes",
    items: [
      { q: "Claude Code peut-il tourner sur un VPS ?", a: "Oui. Claude Code est une application en terminal, donc n'importe quel serveur Linux convient. Vous vous connectez une fois via un lien ouvert sur votre propre appareil, et il continue de tourner dans tmux après la déconnexion." },
      { q: "Quelle taille de serveur pour Claude Code ?", a: "2 vCPU et 4 Go de RAM suffisent pour le terminal. Avec le bureau KDE Plasma, 4 vCPU et 8 Go de RAM donnent un vrai poste de travail." },
      { q: "Quelles versions d'Ubuntu sont prises en charge ?", a: "Ubuntu 24.04 LTS et plus récent, y compris 26.04 LTS. En amd64 tout est installé, en arm64 tout fonctionne sauf Chrome." },
      { q: "Faut-il un abonnement Claude ?", a: "Il faut une offre qui inclut Claude Code (Pro ou Max) ou une clé API Anthropic. claude-vps lui-même est gratuit et sous licence MIT." },
      { q: "Est-il sûr d'exposer RDP ?", a: "xrdp chiffre la session et écoute sur un port non standard, mais vous pouvez aussi le garder fermé avec --rdp-private et passer par un tunnel SSH." },
      { q: "Puis-je utiliser mes propres réglages KDE et Claude ?", a: "Oui. Forkez le dépôt, lancez claude-vps capture sur votre machine et pointez l'installeur vers votre fork. Le serveur suit ensuite chaque changement publié." },
    ],
  },
  it: {
    title: "Domande frequenti",
    items: [
      { q: "Claude Code può girare su un VPS?", a: "Sì. Claude Code è un'app da terminale, quindi va bene qualsiasi server Linux. Accedi una volta tramite un link che apri sul tuo dispositivo, e continua a girare in tmux anche dopo la disconnessione." },
      { q: "Che server serve per Claude Code?", a: "2 vCPU e 4 GB di RAM bastano per il terminale. Con il desktop KDE Plasma, 4 vCPU e 8 GB di RAM danno una vera postazione di lavoro." },
      { q: "Quali versioni di Ubuntu sono supportate?", a: "Ubuntu 24.04 LTS e successive, compresa la 26.04 LTS. Su amd64 c'è tutto, su arm64 funziona tutto tranne Chrome." },
      { q: "Serve un abbonamento Claude?", a: "Serve un piano che includa Claude Code (Pro o Max) o una chiave API Anthropic. claude-vps è gratuito e con licenza MIT." },
      { q: "È sicuro esporre RDP?", a: "xrdp cifra la sessione e usa una porta non standard, ma puoi anche tenerla chiusa con --rdp-private e passare da un tunnel SSH." },
      { q: "Posso usare le mie impostazioni di KDE e Claude?", a: "Sì. Fai un fork del repository, esegui claude-vps capture sulla tua macchina e punta l'installer al tuo fork. Il server seguirà ogni modifica che pubblichi." },
    ],
  },
  tr: {
    title: "Sık sorulanlar",
    items: [
      { q: "Claude Code VPS'te çalışır mı?", a: "Evet. Claude Code bir terminal uygulaması, her Linux sunucuda çalışır. Kendi cihazında açtığın bir linkle bir kere giriş yaparsın, bağlantıyı kapatsan da tmux içinde çalışmaya devam eder." },
      { q: "Claude Code için nasıl bir sunucu lazım?", a: "Sadece terminal için 2 vCPU ve 4 GB RAM yeter. KDE Plasma masaüstüyle birlikte 4 vCPU ve 8 GB RAM gerçek bir iş istasyonu hissi verir." },
      { q: "Hangi Ubuntu sürümleri destekleniyor?", a: "Ubuntu 24.04 LTS ve üstü, 26.04 LTS dahil. amd64'te her şey kurulur, arm64'te Chrome hariç her şey çalışır." },
      { q: "Claude aboneliği gerekiyor mu?", a: "Claude Code içeren bir plan (Pro ya da Max) veya bir Anthropic API anahtarı gerekiyor. claude-vps'in kendisi ücretsiz ve MIT lisanslı." },
      { q: "RDP'yi internete açmak güvenli mi?", a: "xrdp oturumu şifreler ve varsayılan olmayan bir portta çalışır. İstersen --rdp-private ile portu kapalı tutup SSH tüneliyle bağlanabilirsin." },
      { q: "Kendi KDE ve Claude ayarlarımı kullanabilir miyim?", a: "Evet. Repoyu fork'la, kendi makinende claude-vps capture çalıştır ve kurulumu fork'una yönlendir. Sunucu yayınladığın her değişikliği takip eder." },
    ],
  },
};
