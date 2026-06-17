# Scoring — cum dai scorurile (0-100)

Scop: scoruri **credibile si consistente** intre clienti. Nu sunt exacte stiintific, dar trebuie sa reflecte realitatea din crawl.

## Categorii + pondere (scor global)
| Categorie | Pondere | Ce masoara |
|-----------|---------|-----------|
| SEO Tehnic | 25% | robots, sitemap, canonical, HTTPS/www, indexare, securitate |
| Continut | 23% | title/meta/H1, descrieri categorii, E-E-A-T, thin content |
| Google Ads / Shopping | 22% | feed, schema produs+pret, reviews, Shopping/PMax, CSS, competitie |
| Viteza & Mobil | 15% | CWV/PSI, greutate HTML, WebP, viewport |
| Schema / Rich results | 15% | Product, Organization, LocalBusiness, Breadcrumb, reviews |

Scor global = suma ponderata. Rotunjeste.

## Bareme rapide (porneste de la 100, scazi)
**SEO Tehnic** — -25 sitemap rupt/404; -20 www duplicat 200; -15 filtre indexabile; -10 fara canonical; -8 fara security headers; -5 robots gresit.
**Continut** — -20 H1 lipsa homepage; -15 meta desc lipsa pagini cheie; -15 zero reviews; -12 descrieri categorii lipsa; -8 title-uri slabe.
**Google Ads/Shopping** — -25 nu ruleaza deloc Ads (oportunitate, dar scor mic = durere); -20 fara feed/Shopping; -15 fara reviews (zero stele Shopping); -15 **fara segmentare produse** (buget pe Villains/Zombies — penalizeaza MEREU daca nu exista sistem); -12 titluri produs neoptimizate; -10 **fara CSS** ("By Google Shopping" = CPC mai mare); -10 multe produse OutOfStock.
**Viteza & Mobil** — -25 PSI <40 sau HTML >800KB; -15 TTFB >1s; -10 fara WebP; -8 fonturi render-blocking.
**Schema** — -30 fara Product; -20 fara reviews/AggregateRating; -15 fara LocalBusiness (la local); -10 fara Breadcrumb; -10 @context http.

## Culori bara (in raport)
- rosu `#C0392B` → scor < 40
- portocaliu `#D45B00` → 40-69
- verde `#1A7A4A` → 70+

## Scor tinta (pt pagina de plan)
Pune un orizont realist (90 zile): de obicei +25 pana la +35 fata de scorul curent, fara sa depasesti ~80 (credibil).

## Nota lead-gen
Un scor prea mare nu vinde. Daca site-ul chiar e bun (75+), muta accentul pe **oportunitatea Ads/Shopping** si crestere, nu pe "e stricat".
