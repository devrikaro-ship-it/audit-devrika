# Audit Devrika — Skill Claude Code

Genereaza un **raport PDF de audit (SEO + Google Ads/Shopping)** branduit Devrika, pornind **doar de la URL-ul** unui site. Instrument de **lead-generation**: diagnostic real, ambalat persuasiv, scris pentru un decident netehnic, terminat cu CTA Devrika.

![tip](https://img.shields.io/badge/tip-lead--gen-orange) ![input](https://img.shields.io/badge/input-doar%20URL-blue)

## Ce face
- Crawl public al site-ului (fara acces la cont)
- Scor de vizibilitate online 0-100 + sub-scoruri
- 5 pagini A4: coperta, rezumat, SEO, Google Ads/Shopping, plan + CTA
- PDF profesionist generat din HTML via Chrome headless

## Instalare
macOS / Linux:
```bash
git clone https://github.com/devrikaro-ship-it/audit-devrika.git ~/.claude/skills/audit-devrika
```
Windows (PowerShell):
```powershell
git clone https://github.com/devrikaro-ship-it/audit-devrika.git "$env:USERPROFILE\.claude\skills\audit-devrika"
```
Reporneste Claude Code → apare `/audit-devrika`. Repo public, nu necesita acces.
Necesita doar: **Google Chrome** + **Python 3** (stdlib). Scripturile-s cross-platform (**Windows / macOS / Linux**). Fara chei API, fara pip install.

## Folosire
In Claude Code:
```
/audit-devrika https://site-client.ro [Nume Client]
```
Sau natural: „fa-mi un audit PDF pentru site-ul X ca sa-l agatam”.

PDF-ul iese in `seo-audits/{client}/`.

## Structura
```
audit-devrika/
├── SKILL.md                 # orchestrare (cititul de Claude)
├── scripts/
│   ├── collect.py           # aduna semnale SEO + Ads din URL (cross-platform)
│   ├── build.py             # JSON date -> HTML raport (randuri variabile)
│   └── html_to_pdf.py       # HTML -> PDF (Chrome headless, cross-platform)
├── assets/
│   ├── styles.css           # CSS brand Devrika (sursa unica)
│   ├── example.json         # exemplu date raport (vegis.ro)
│   └── template.html        # fallback manual (tokens {{...}})
└── references/
    ├── framing.md           # ton lead-gen, traduceri tehnic->client
    ├── scoring.md           # cum dai scorurile 0-100
    └── google-ads-research.md  # research CSS/Shopping via Playwright
```

## Note
- Datele Google Ads/GMC nu sunt publice → sectiunea Ads e **audit de oportunitate** (feed, Shopping, competitie via Ads Transparency / Meta Ad Library).
- Text fara diacritice (standard clienti Devrika).
- Model de referinta: `seo-audits/sndeco/`.

— Devrika Agency · devrika.ro
