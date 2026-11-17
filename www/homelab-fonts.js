/**
 * Home Lab — font loader for Home Assistant
 *
 * Home Assistant themes can name a font family but cannot load one. This
 * module loads the two faces white_dove.yaml asks for:
 *
 *   Libre Franklin   variable, 100–900 + italic   all interface text
 *   IBM Plex Mono    400–600                      code, logs, updating numbers
 *
 * Install
 *   1. Save this file as /config/www/homelab-fonts.js
 *   2. Put these three files in /config/www/fonts/, named EXACTLY this:
 *        LibreFranklin.woff2          (variable, latin, normal)
 *        LibreFranklin-Italic.woff2   (variable, latin, italic)
 *        IBMPlexMono.woff2            (weight 400, latin, normal)
 *      Renaming them is expected — the downloaded names are long and
 *      inconsistent between sources, so the theme picks the names.
 *   3. configuration.yaml:
 *        frontend:
 *          extra_module_url:
 *            - /local/homelab-fonts.js
 *   4. Restart Home Assistant, then hard-refresh the browser
 *
 * Self-hosted on purpose: half this stack has to work when the internet is
 * down, and a wall tablet falling back to system-ui mid-outage looks broken.
 * If you'd rather use Google's CDN, the alternative is at the bottom.
 */

(() => {
  const ID = "homelab-fonts";
  if (document.getElementById(ID)) return;

  const style = document.createElement("style");
  style.id = ID;
  style.textContent = `
    /* Libre Franklin — variable file, covers every weight from one download.
       The 100 900 range is what lets the theme ask for 400/500/600. */
    @font-face {
      font-family: 'Libre Franklin';
      font-style: normal; font-weight: 100 900; font-display: swap;
      src: url('/local/fonts/LibreFranklin.woff2') format('woff2');
    }
    @font-face {
      font-family: 'Libre Franklin';
      font-style: italic; font-weight: 100 900; font-display: swap;
      src: url('/local/fonts/LibreFranklin-Italic.woff2') format('woff2');
    }

    /* IBM Plex Mono — if you grabbed a static file, this is weight 400 only.
       If your download had a variable Plex Mono, change 400 to: 400 600 */
    @font-face {
      font-family: 'IBM Plex Mono';
      font-style: normal; font-weight: 400; font-display: swap;
      src: url('/local/fonts/IBMPlexMono.woff2') format('woff2');
    }

    /* Temperatures, power, counters: keep digits the same width so a row
       doesn't twitch every time a sensor updates. */
    :root, body, ha-card, hui-view {
      font-variant-numeric: tabular-nums;
    }
  `;
  document.head.appendChild(style);

  /* ── CDN alternative ──────────────────────────────────────────────────
   * Delete everything above from `const style` down and use this instead.
   * Fonts then break when the box is offline.
   *
   * const link = document.createElement("link");
   * link.id = ID;
   * link.rel = "stylesheet";
   * link.href = "https://fonts.googleapis.com/css2" +
   *   "?family=Libre+Franklin:ital,wght@0,100..900;1,100..900" +
   *   "&family=IBM+Plex+Mono:wght@400;500;600&display=swap";
   * document.head.appendChild(link);
   */
})();