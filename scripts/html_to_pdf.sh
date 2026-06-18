#!/usr/bin/env bash
# Converteste un fisier HTML stilizat (A4) in PDF via Chrome/Chromium/Edge headless.
# Foloseste --virtual-time-budget ca Chart.js sa apuce sa randeze inainte de print.
# Usage: html_to_pdf.sh input.html output.pdf
set -euo pipefail

HTML="${1:?usage: html_to_pdf.sh input.html output.pdf}"
OUT="${2:?usage: html_to_pdf.sh input.html output.pdf}"

find_chrome() {
  local candidates=(
    "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"
    "/Applications/Chromium.app/Contents/MacOS/Chromium"
    "/Applications/Microsoft Edge.app/Contents/MacOS/Microsoft Edge"
    "google-chrome" "google-chrome-stable" "chromium" "chromium-browser" "microsoft-edge"
  )
  for c in "${candidates[@]}"; do
    if [ -x "$c" ]; then echo "$c"; return 0; fi
    if command -v "$c" >/dev/null 2>&1; then command -v "$c"; return 0; fi
  done
  return 1
}

CHROME="$(find_chrome)" || {
  echo "EROARE: Chrome/Chromium/Edge negasit. Instaleaza Google Chrome." >&2
  exit 1
}

# garda: refuza daca au ramas {{TOKEN}}-uri necompletate
if grep -qE '\{\{[A-Z_0-9]+\}\}' "$HTML"; then
  echo "EROARE: au ramas tokens necompletate in $HTML — completeaza-le inainte de PDF:" >&2
  grep -oE '\{\{[A-Z_0-9]+\}\}' "$HTML" | sort -u >&2
  exit 1
fi

# cale absoluta pt file://
ABS_HTML="$(cd "$(dirname "$HTML")" && pwd)/$(basename "$HTML")"

"$CHROME" --headless=new --disable-gpu --no-pdf-header-footer \
  --virtual-time-budget=10000 \
  --print-to-pdf="$OUT" "file://$ABS_HTML" >/dev/null 2>&1 || true

if [ -f "$OUT" ]; then
  echo "PDF generat: $OUT ($(du -h "$OUT" | cut -f1))"
else
  echo "EROARE: PDF nu a fost generat." >&2
  exit 1
fi
