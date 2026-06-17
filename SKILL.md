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
   bash scripts/collect.sh https://domeniul-clientului.ro
   ```
   Aduna: title/meta/H1, robots+sitemap, schema, HTTPS/www, e-commerce, feed/Shopping, viteza (PSI best-effort), competitie Ads. Citeste tot output-ul.
   **Daca apare `!!! BLOCKER` (Cloudflare/anti-bot):** crawler-ul e blocat, datele sunt false. NU genera audit pe ele. Fallback: ia paginile prin browser (Playwright MCP: `browser_navigate` + `browser_evaluate` ca sa scoti HTML real), apoi continua. Daca nici asa nu merge, spune userului ca site-ul blocheaza crawl si cere alta metoda.

2. **Verifica manual ce conteaza** (nu te baza orb pe script):
   - deschide 1 pagina produs + 1 categorie (schema Product, pret, availability, reviews)
   - raport stoc (cate produse OutOfStock — semnal puternic la ecom)
   - GMC/Shopping: ID-ul nu e public → raporteaza "feed de verificat" + oportunitate
   - competitie: deschide linkurile Ads Transparency / Meta Ad Library din output

3. **Scoreaza** (0-100 per categorie). Vezi `references/scoring.md`. Calculeaza scorul global ponderat.

4. **Construieste raportul**
   - copiaza `assets/template.html` intr-un fisier de lucru
   - inlocuieste TOATE `{{TOKEN}}`-urile (cauta `{{` ca sa nu ramana niciunul)
   - culori bara scor: rosu `#C0392B` (<40), portocaliu `#D45B00` (40-69), verde `#1A7A4A` (70+)
   - 5-9 findings SEO, 3-6 oportunitati Ads. Sterge randurile-exemplu nefolosite.
   - framing: vezi `references/framing.md`

5. **Genereaza PDF**
   ```
   bash scripts/html_to_pdf.sh raport.html "Audit-Devrika-{client}.pdf"
   ```

6. **Salveaza** in `seo-audits/{client}/` (creeaza dosarul). Pastreaza si HTML-ul (pt editari ulterioare).

## Structura raport (5 pagini A4)
1. **Coperta** — domeniu, scor global (gauge), 4 sub-scoruri
2. **Ce am gasit pe scurt** — "ce te costa" vs "castiguri rapide", tabel scoruri
3. **SEO** — probleme care ascund site-ul de clienti
4. **Google Ads / Shopping** — bani lasati pe masa + ce face competitia
5. **Plan + CTA Devrika**

## Note
- Chart.js se randeaza in headless prin `--virtual-time-budget` (deja in `html_to_pdf.sh`). Nu schimba.
- Daca PSI e rate-limited fara cheie, scrie "viteza de masurat" — nu inventa cifre.
- Model proven de la care a pornit template-ul: `seo-audits/sndeco/`.
