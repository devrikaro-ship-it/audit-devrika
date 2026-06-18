---
name: audit-devrika
description: "Genereaza un raport PDF de audit (SEO + Google Ads/Shopping) branduit Devrika, pornind doar de la URL-ul unui site. Instrument de lead-generation: diagnostic real ambalat persuasiv, scris pe intelesul unui decident netehnic, terminat cu CTA Devrika. Foloseste cand userul zice: audit client, raport PDF, audit lead, agata client, audit prospect, raport vanzare."
user-invokable: true
argument-hint: "[url] [nume-client optional]"
license: MIT
metadata:
  author: Devrika
  version: "1.0.0"
  category: audit
---

# Audit Devrika — Raport PDF Lead-Gen (SEO + Google Ads)

Genereaza **un singur PDF** profesionist din **doar URL-ul** unui potential client.
Scop: **lead generation** — aratam ce e stricat + cat pierde, ambalat ca sa-l agatam, terminat cu CTA Devrika.

## Principii (NU le incalca)
1. **Input = doar URL.** Toate datele se deduc din ce e public pe site. Fara acces la cont, fara date din Ads/GMC.
2. **Date reale, framing persuasiv.** Findings-urile sunt reale din crawl (credibilitate). Doar *incadrarea* vinde: durere + bani pierduti.
3. **Pentru un NETEHNIC.** Decidentul nu stie ce e DNS/schema. Fiecare problema are linia `Ce inseamna pentru tine` in limbaj de client (clienti pierduti, bani, locul in Google).
4. **Se termina cu CTA Devrika.** "Hai sa vorbim / noi rezolvam asta" + contact.
5. **Fara diacritice** in textul raportului (regula clienti Devrika).

## Proces

1. **Colecteaza semnale**
   ```
   python scripts/collect.py https://domeniul-clientului.ro
   ```
   Aduna: title/meta/H1/H2, meta robots+hreflang, robots+sitemap, schema, HTTPS/www, **security headers** (HSTS/CSP/X-Frame), **broken links** (esantion), **readability + citability AI** (propozitii, liste, FAQ, JS-render), imagini/alt/format, **viteza TTFB + CWV reali** (CrUX cu cheie), e-commerce/stoc, feed/Shopping, competitie Ads. Citeste tot output-ul.
   **Daca apare `!!! BLOCKER` (Cloudflare/anti-bot):** crawler-ul e blocat, datele sunt false. NU genera audit pe ele. Fallback: ia paginile prin browser (Playwright MCP: `browser_navigate` + `browser_evaluate` ca sa scoti HTML real), apoi continua. Daca nici asa nu merge, spune userului ca site-ul blocheaza crawl si cere alta metoda.

2. **Verifica manual ce conteaza** (nu te baza orb pe script):
   - deschide 1 pagina produs + 1 categorie (schema Product, pret, availability, reviews)
   - raport stoc (cate produse OutOfStock — semnal puternic la ecom)
   - GMC/Shopping: ID-ul nu e public → raporteaza "feed de verificat" + oportunitate
   - competitie: deschide linkurile Ads Transparency / Meta Ad Library din output

2b. **Research Google Shopping (Playwright, best-effort)** — vezi `references/google-ads-research.md`
   - cauta 2-3 produse reale ale clientului pe Google Shopping → ruleaza Shopping? produsele apar?
   - citeste atributul **"By <provider>"** sub produs: `By Google Shopping` = **fara CSS** → spune-i ce pierde (CPC pana la ~20% mai mare, fara plasare premium); alt nume (ProductHero/Bidnamic) = deja pe CSS
   - daca Google blocheaza (CAPTCHA/consent) → "research neconcludent", NU inventa
   - **MEREU**, indiferent de research: constatare segmentare produse (Heroes/Villains/Zombies) — fara separare, bugetul se arde pe produse care nu vand. Vezi research §A.

3. **Scoreaza** (0-100 per categorie). Vezi `references/scoring.md`. Calculeaza scorul global ponderat.

4. **Construieste raportul (recomandat: JSON → build.py)**
   - scrie datele intr-un fisier JSON dupa schema din `assets/example.json` (date reale + framing din `references/framing.md`)
   - culorile barelor de scor se calculeaza automat (rosu <40, portocaliu 40-69, verde 70+)
   - findings: pune cate ai nevoie (5-9 SEO, 3-6 Ads). Ads include MEREU segmentare + CSS.
   ```
   python scripts/build.py date.json raport.html
   ```
   Fallback manual: poti edita direct `assets/template.html` (tokens `{{...}}`) daca preferi.

5. **Genereaza PDF**
   ```
   python scripts/html_to_pdf.py raport.html "Audit-Devrika-{client}.pdf"
   ```
   (refuza daca au ramas tokens necompletate — la nevoie completeaza-le)

6. **Salveaza** in `seo-audits/{client}/` (creeaza dosarul). Pastreaza si JSON-ul (pt editari ulterioare).

## Structura raport (5 pagini A4)
1. **Coperta** — domeniu, scor global (gauge), 4 sub-scoruri
2. **Ce am gasit pe scurt** — "ce te costa" vs "castiguri rapide", tabel scoruri
3. **SEO** — probleme care ascund site-ul de clienti
4. **Google Ads / Shopping** — bani lasati pe masa + ce face competitia
5. **Plan + CTA Devrika**

## Note
- Chart.js se randeaza in headless prin `--virtual-time-budget` (deja in `html_to_pdf.py`). Nu schimba.
- Scripturile sunt Python (cross-platform: Windows/Mac/Linux), fara dependinte. Ruleaza cu `python` sau `python3`.
- Daca PSI e rate-limited fara cheie, scrie "viteza de masurat" — nu inventa cifre.
- Model proven de la care a pornit template-ul: `seo-audits/sndeco/`.
