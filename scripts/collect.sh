#!/usr/bin/env bash
# Aduna semnale SEO + Google Ads/Shopping dintr-un URL public (fara acces la cont).
# Output: raport text structurat la stdout, pe care skill-ul il citeste si il transforma in audit.
# Dependinte: curl, python3 (doar stdlib). Fara chei API.
# Usage: collect.sh https://exemplu.ro
set -uo pipefail

URL="${1:?usage: collect.sh https://domeniu.ro}"
URL="${URL%/}"
DOMAIN="$(echo "$URL" | sed -E 's#https?://##; s#/.*##')"
UA="Mozilla/5.0 (compatible; DevrikaAudit/1.0; +https://devrika.ro)"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

fetch() { curl -sL --max-time 25 -A "$UA" "$1" 2>/dev/null; }
code()  { curl -s -o /dev/null -w "%{http_code}" --max-time 15 -A "$UA" "$1" 2>/dev/null; }

echo "================ DEVRIKA AUDIT — COLECTARE SEMNALE ================"
echo "URL: $URL"
echo "Domeniu: $DOMAIN"
echo "Data: $(date '+%Y-%m-%d %H:%M')"
echo

# ---------- HOMEPAGE ----------
fetch "$URL/" > "$TMP/home.html"
HSIZE=$(wc -c < "$TMP/home.html" | tr -d ' ')
echo "===== HOMEPAGE ====="
echo "HTML size: $HSIZE bytes"
# detectie protectie anti-bot (Cloudflare / challenge) — crawler blocat, datele nu sunt fiabile
if grep -qiE 'Just a moment|cf-mitigated|challenge-platform|Attention Required|_cf_chl|Enable JavaScript and cookies' "$TMP/home.html" || [ "$HSIZE" -lt 2000 ]; then
  echo "!!! BLOCKER: site in spatele protectiei anti-bot (Cloudflare/challenge) sau pagina goala."
  echo "!!! Crawler-ul nu primeste HTML real. Optiuni: ruleaza din browser (Playwright) sau cere acces."
  echo "!!! NU genera audit pe datele de mai jos — sunt incomplete/false."
fi
python3 - "$TMP/home.html" <<'PY'
import sys, re, html
h = open(sys.argv[1], encoding='utf-8', errors='ignore').read()
def first(p):
    m = re.search(p, h, re.I|re.S)
    return html.unescape(re.sub(r'\s+',' ', m.group(1)).strip())[:200] if m else "(lipsa)"
print("Title:", first(r'<title[^>]*>(.*?)</title>'))
print("Meta desc:", first(r'<meta[^>]+name=["\']description["\'][^>]+content=["\'](.*?)["\']'))
h1 = re.findall(r'<h1[^>]*>(.*?)</h1>', h, re.I|re.S)
print("H1 count:", len(h1))
if h1: print("H1[0]:", html.unescape(re.sub(r'<[^>]+>|\s+',' ', h1[0]).strip())[:160])
print("Canonical:", first(r'<link[^>]+rel=["\']canonical["\'][^>]+href=["\'](.*?)["\']'))
print("Lang:", first(r'<html[^>]+lang=["\'](.*?)["\']'))
imgs = re.findall(r'<img\b[^>]*>', h, re.I)
noalt = [i for i in imgs if not re.search(r'alt=["\'][^"\']+["\']', i)]
print(f"Imagini: {len(imgs)} | fara alt: {len(noalt)}")
fmt = {}
for m in re.findall(r'\.(jpg|jpeg|png|webp|avif)\b', h, re.I):
    fmt[m.lower()] = fmt.get(m.lower(),0)+1
print("Formate img (sample):", fmt)
sch = re.findall(r'"@type"\s*:\s*"([^"]+)"', h)
print("Schema @type:", sorted(set(sch)) or "(niciun JSON-LD)")
print("OG image:", "DA" if re.search(r'og:image', h, re.I) else "NU")
print("Viewport meta:", "DA" if re.search(r'name=["\']viewport["\']', h, re.I) else "NU")
words = len(re.sub(r'<[^>]+>',' ', re.sub(r'(?is)<(script|style).*?</\1>',' ', h)).split())
print("Word count (vizibil aprox):", words)
# platforma
plat = []
for sig, name in [('wp-content','WordPress'),('woocommerce','WooCommerce'),('cdn.shopify','Shopify'),
                  ('catalog/view','OpenCart'),('Journal3','Journal3'),('elementor','Elementor'),
                  ('PrestaShop','PrestaShop'),('Magento','Magento'),('rank-math','Rank Math'),
                  ('yoast','Yoast'),('wix.com','Wix')]:
    if re.search(re.escape(sig), h, re.I): plat.append(name)
print("Platforma/stack:", ", ".join(dict.fromkeys(plat)) or "necunoscut")
PY
echo

# ---------- HTTPS / WWW / REDIRECTS ----------
echo "===== HTTPS / REDIRECT ====="
echo "https://$DOMAIN -> $(code "https://$DOMAIN")"
echo "http://$DOMAIN  -> $(code "http://$DOMAIN")  (asteptat 301 -> https)"
echo "www.$DOMAIN     -> $(code "https://www.$DOMAIN")  (verifica daca face redirect la non-www sau e duplicat 200)"
echo

# ---------- VITEZA (masuratoare reala server, fara cheie) ----------
echo "===== VITEZA SERVER (TTFB, masurat) ====="
TTFB=$(curl -s -o /dev/null -w "%{time_starttransfer}" --max-time 25 -A "$UA" "$URL/" 2>/dev/null)
KB=$(( HSIZE / 1024 ))
echo "TTFB homepage: ${TTFB}s | HTML homepage: ${KB} KB"
awk -v t="$TTFB" 'BEGIN{ if(t==""){print "TTFB: nemasurat"} else if(t+0>1.0){print "  -> LENT (>1s): server greu, semnal rosu"} else if(t+0>0.5){print "  -> mediu (0.5-1s): de imbunatatit"} else {print "  -> ok (<0.5s)"} }'
awk -v k="$KB" 'BEGIN{ if(k+0>800){print "  -> HTML f. greu (>800KB): risc LCP mobil"} else if(k+0>300){print "  -> HTML greu (>300KB)"} else {print "  -> HTML ok"} }'
echo

# ---------- ROBOTS ----------
echo "===== ROBOTS.TXT ====="
fetch "$URL/robots.txt" > "$TMP/robots.txt"
if [ -s "$TMP/robots.txt" ]; then
  echo "Sitemap declarat: $(grep -i '^sitemap:' "$TMP/robots.txt" | head -3 | sed 's/[Ss]itemap: *//')"
  echo "AI bots:"
  for b in GPTBot ClaudeBot PerplexityBot Google-Extended anthropic-ai; do
    grep -qi "$b" "$TMP/robots.txt" && echo "  $b: mentionat" || echo "  $b: nemention (default Allow)"
  done
  echo "Disallow count: $(grep -ci '^disallow:' "$TMP/robots.txt")"
else
  echo "robots.txt: LIPSA sau gol"
fi
echo "llms.txt: $(code "$URL/llms.txt") (200 = exista)"
echo

# ---------- SITEMAP ----------
echo "===== SITEMAP ====="
SMAP=$(grep -i '^sitemap:' "$TMP/robots.txt" | head -1 | sed 's/[Ss]itemap: *//;s/\r//')
[ -z "$SMAP" ] && SMAP="$URL/sitemap_index.xml"
fetch "$SMAP" > "$TMP/smap.xml"
if grep -qi '<sitemapindex' "$TMP/smap.xml"; then
  echo "Tip: sitemap index ($SMAP)"
  grep -oE '<loc>[^<]+</loc>' "$TMP/smap.xml" | sed -E 's#</?loc>##g' | head -20 | while read -r sm; do
    n=$(fetch "$sm" | grep -c '<loc>')
    echo "  $(basename "$sm"): $n url-uri"
  done
elif grep -qi '<urlset' "$TMP/smap.xml"; then
  echo "Tip: sitemap simplu — $(grep -c '<loc>' "$TMP/smap.xml") url-uri"
else
  echo "Sitemap: negasit la $SMAP"
fi
echo

# ---------- GOOGLE ADS / SHOPPING / FEED (oportunitate) ----------
echo "===== GOOGLE ADS / SHOPPING — semnale oportunitate ====="
ECOM=$(python3 - "$TMP/home.html" <<'PY'
import sys,re
h=open(sys.argv[1],encoding='utf-8',errors='ignore').read()
print("DA" if re.search(r'add-to-cart|/cart|/product|/cos|adauga in cos|woocommerce|shopify|/shop|/magazin|priceCurrency', h, re.I) else "NU")
PY
)
echo "E-commerce detectat: $ECOM"
echo "Product schema cu pret: $(grep -oqi 'priceCurrency' "$TMP/home.html" && echo DA || echo 'verifica pe pagina produs')"
echo "Review/AggregateRating in schema: $(grep -qi 'AggregateRating\|"Review"' "$TMP/home.html" && echo DA || echo 'NU pe homepage')"
# feed produse comune
echo "Feed produse posibil (verificat HTTP):"
for f in "/feed" "/product-feed" "/feed.xml" "/wp-content/uploads/woo-feed" "/index.php?route=extension/feed/google_sitemap" "/googlebase.xml" "/feed/google" "/products.json" "/sitemap_products_1.xml" "/collections/all.atom" ; do
  c=$(code "$URL$f"); [ "$c" = "200" ] && echo "  $f -> $c"
done
echo "GMC/Shopping nota: ID Merchant Center si datele din cont NU sunt publice — raporteaza ca 'de verificat' + framing oportunitate."
echo "Ads Transparency (competitie): https://adstransparency.google.com/?region=RO&query=$DOMAIN"
echo "Meta Ad Library (competitie): https://www.facebook.com/ads/library/?q=$DOMAIN"
echo

# ---------- SAMPLE PRODUCT PAGE (daca ecom) ----------
if [ "$ECOM" = "DA" ]; then
  echo "===== SAMPLE PAGINA PRODUS ====="
  # 1) preferential: din product sitemap (general, exact). 2) fallback: heuristica homepage.
  PSM=$(grep -oE '<loc>[^<]+</loc>' "$TMP/smap.xml" 2>/dev/null | sed -E 's#</?loc>##g' | grep -iE 'product|produs' | head -1)
  PROD=""
  if [ -n "$PSM" ]; then
    PROD=$(fetch "$PSM" | grep -oE '<loc>[^<]+</loc>' | sed -E 's#</?loc>##g' | grep -viE '/(category|categorie|product_cat|collections?|magazin|shop|store|catalog)/?$' | head -1)
  fi
  [ -z "$PROD" ] && PROD=$(grep -oE "$URL/(produs|product|p)/[a-z0-9-]{6,}/?" "$TMP/home.html" | head -1)
  [ -z "$PROD" ] && PROD=$(grep -oE "$URL/[a-z0-9][a-z0-9-]{12,}/?" "$TMP/home.html" | grep -viE '/(category|categorie|cart|cos|cont|account|page|blog|tag|despre|contact|termeni|politica|wp-)' | head -1)
  if [ -n "$PROD" ]; then
    echo "URL probat: $PROD"
    fetch "$PROD" > "$TMP/prod.html"
    # raport stoc rapid (semnal puternic ecom): esantion 12 produse din sitemap
    if [ -n "$PSM" ]; then
      oos=0; tot=0
      for u in $(fetch "$PSM" | grep -oE '<loc>[^<]+</loc>' | sed -E 's#</?loc>##g' | grep -viE '/(magazin|shop|store|catalog|category|categorie)/?$' | awk 'NR%9==3' | head -15); do
        av=$(fetch "$u" | grep -oE 'schema.org/(InStock|OutOfStock|PreOrder)' | head -1)
        [ -z "$av" ] && continue           # pagina goala/timeout -> nu o numara
        tot=$((tot+1)); [ "$av" = "schema.org/OutOfStock" ] && oos=$((oos+1))
      done
      [ "$tot" -gt 0 ] && echo "Stoc (estimat, esantion $tot produse cu date): $oos OutOfStock ($(( oos*100/tot ))%)" || echo "Stoc: nu am putut esantiona (verifica manual)"
    fi
    python3 - "$TMP/prod.html" <<'PY'
import sys,re
h=open(sys.argv[1],encoding='utf-8',errors='ignore').read()
print("Product schema:", "DA" if re.search(r'"@type"\s*:\s*"Product"', h) else "NU")
print("Pret in schema:", (re.search(r'"price"\s*:\s*"?([\d.,]+)', h) or ["","(lipsa)"])[1] if re.search(r'"price"', h) else "(lipsa)")
print("Availability:", (re.search(r'schema.org/(InStock|OutOfStock|PreOrder)', h) or ["","(lipsa)"])[0].split('/')[-1] if re.search(r'availability', h) else "(lipsa)")
print("AggregateRating:", "DA" if re.search(r'AggregateRating', h) else "NU (fara stele in SERP/Shopping)")
PY
  else
    echo "Nu am putut extrage un URL de produs din homepage."
  fi
  echo
fi

# ---------- CORE WEB VITALS (best effort, fara cheie) ----------
echo "===== PERFORMANTA (PageSpeed, best-effort fara cheie) ====="
PSI=$(fetch "https://www.googleapis.com/pagespeedonline/v5/runPagespeed?url=$URL&strategy=mobile")
echo "$PSI" | python3 - <<'PY'
import sys,json
try:
    d=json.load(sys.stdin)
    lh=d.get("lighthouseResult",{})
    perf=lh.get("categories",{}).get("performance",{}).get("score")
    print("Performance score (lab):", round(perf*100) if perf is not None else "n/a")
    au=lh.get("audits",{})
    for k,lbl in [("largest-contentful-paint","LCP"),("cumulative-layout-shift","CLS"),
                  ("total-blocking-time","TBT"),("speed-index","Speed Index")]:
        v=au.get(k,{}).get("displayValue")
        if v: print(f"{lbl}: {v}")
except Exception as e:
    print("PSI indisponibil (rate-limit fara cheie sau eroare). CWV: de masurat manual.")
PY
echo
echo "================ FINAL COLECTARE ================"
