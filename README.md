# Audit Devrika — Skill Claude Code

Genereaza un **raport PDF de audit (SEO + Google Ads/Shopping)** branduit Devrika, pornind **doar de la URL-ul** unui site. Instrument de **lead-generation**: diagnostic real, ambalat persuasiv, scris pentru un decident netehnic, terminat cu CTA Devrika.

![tip](https://img.shields.io/badge/tip-lead--gen-orange) ![input](https://img.shields.io/badge/input-doar%20URL-blue)

## Ce face
- Crawl public al site-ului (fara acces la cont)
- Scor de vizibilitate online 0-100 + sub-scoruri
- 5 pagini A4: coperta, rezumat, SEO, Google Ads/Shopping, plan + CTA
- PDF profesionist generat din HTML via Chrome headless

## Instalare (colegi)
```bash
git clone https://github.com/devrikaro-ship-it/audit-devrika.git ~/.claude/skills/audit-devrika
chmod +x ~/.claude/skills/audit-devrika/scripts/*.sh
```
(repo privat — cere acces de colaborator pe `devrikaro-ship-it/audit-devrika`)
Necesita: **Google Chrome** instalat, `curl`, `python3` (doar stdlib). Fara chei API.

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
│   ├── collect.sh           # aduna semnale SEO + Ads din URL
│   └── html_to_pdf.sh       # HTML -> PDF (Chrome headless)
├── assets/
│   └── template.html        # template brand Devrika (tokens {{...}})
└── references/
    ├── framing.md           # ton lead-gen, traduceri tehnic->client
    └── scoring.md           # cum dai scorurile 0-100
```

## Note
- Datele Google Ads/GMC nu sunt publice → sectiunea Ads e **audit de oportunitate** (feed, Shopping, competitie via Ads Transparency / Meta Ad Library).
- Text fara diacritice (standard clienti Devrika).
- Model de referinta: `seo-audits/sndeco/`.

— Devrika Agency · devrika.ro
