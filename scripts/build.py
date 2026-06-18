#!/usr/bin/env python3
"""Genereaza raportul HTML (A4, brand Devrika) dintr-un fisier JSON de date.
Acopera si randurile variabile (findings, plan) — nu mai completezi tokens manual.
Apoi ruleaza html_to_pdf.py pe output.
Usage: python build.py date.json raport.html
Schema JSON: vezi assets/example.json
"""
import os, sys, json

HERE = os.path.dirname(os.path.abspath(__file__))
CSS = open(os.path.join(HERE, "..", "assets", "styles.css"), encoding="utf-8").read()

def bar_color(s):
    s = int(s)
    return "#1A7A4A" if s >= 70 else "#D45B00" if s >= 40 else "#C0392B"

SEV_LABEL = {"critical": "Grav", "high": "Important", "medium": "Mediu", "low": "Minor"}

def badge(f):
    sev = f.get("sev", "medium")
    lbl = f.get("sev_label", SEV_LABEL.get(sev, "Mediu"))
    return f'<span class="badge badge-{sev}">{lbl}</span>'

def effort(f):
    lvl = f.get("effort_level", "low")
    return f'<span class="effort effort-{lvl}">{f.get("effort","")}</span>'

def dots(n):
    n = int(n)
    return '<div class="impact-bar">' + "".join(
        f'<div class="impact-dot{" on" if i < n else ""}"></div>' for i in range(5)) + "</div>"

def exec_items(arr):
    return "".join(f'<div class="exec-item"><span class="exec-num">{i+1}</span><span>{x}</span></div>'
                   for i, x in enumerate(arr))

def score_rows(rows):
    out = ""
    for r in rows:
        c = bar_color(r["score"])
        out += (f'<tr><td><strong>{r["name"]}</strong></td>'
                f'<td><div class="score-bar-wrap"><div class="score-bar-fill" style="width:{r["score"]}%;background:{c}"></div></div></td>'
                f'<td><span class="score-num" style="color:{c}">{r["score"]}</span></td>'
                f'<td>{r["problem"]}</td></tr>')
    return out

def finding_rows(arr, area_key="area"):
    out = ""
    for f in arr:
        meaning = f'<span class="meaning">{f["meaning"]}</span>' if f.get("meaning") else ""
        out += (f'<tr><td>{badge(f)}</td>'
                f'<td><span class="finding-title">{f["title"]}</span>'
                f'<span class="finding-desc">{f.get("desc","")}</span>{meaning}</td>'
                f'<td>{f.get(area_key,"")}</td><td>{effort(f)}</td></tr>')
    return out

def strength_rows(arr):
    return "".join(f'<tr><td><span class="finding-title">{s["title"]}</span></td>'
                   f'<td class="finding-desc">{s["why"]}</td></tr>' for s in arr)

def tech_chips(arr):
    if not arr:
        return ""
    chips = ""
    for c in arr:
        ok = c.get("ok", True)
        col = "#1A7A4A" if ok else "#C0392B"
        mark = "&#10003;" if ok else "&#10007;"
        chips += (f'<span class="chip" style="margin:0 1.5mm 1.5mm 0;padding:1mm 2.5mm;font-size:6.5pt">'
                  f'<span style="color:{col};font-weight:700">{mark}</span> {c["label"]}</span>')
    return ('<div class="section-title">Semnale tehnice verificate</div>'
            f'<div style="display:flex;flex-wrap:wrap;margin-bottom:2mm">{chips}</div>')

def plan_rows(arr):
    out = ""
    for i, a in enumerate(arr):
        sev = a.get("zone_sev", "high")
        out += (f'<tr><td><strong>{i+1}</strong></td>'
                f'<td><span class="action-title">{a["title"]}</span><span class="action-sub">{a.get("sub","")}</span></td>'
                f'<td><span class="badge badge-{sev}">{a.get("zone","")}</span></td>'
                f'<td>{effort(a)}</td><td>{dots(a.get("impact",3))}</td></tr>')
    return out

def footer(p):
    return (f'<div class="page-footer"><span class="footer-text">Confidential — Devrika Agency · devrika.ro</span>'
            f'<span class="footer-page">Pagina {p}</span></div>')

def build(d):
    s = d["scores"]
    tag = d["client"]
    sub = d.get("logo_sm", f'{tag} · Audit Devrika · {d.get("date","")}')
    strengths = ""
    if d.get("seo_strengths"):
        strengths = ('<div class="section-title">Ce e deja bine (si trebuie pastrat)</div>'
                     '<table class="findings-table"><thead><tr><th>Punct forte</th><th>De ce conteaza</th></tr></thead>'
                     f'<tbody>{strength_rows(d["seo_strengths"])}</tbody></table>')
    speed_note = f'<div class="callout">{d["speed_note"]}</div>' if d.get("speed_note") else ""
    ads_comp = f'<div class="callout"><strong>Ce face competitia:</strong> {d["ads_competition"]}</div>' if d.get("ads_competition") else ""
    cta = d.get("cta", {})

    html = f'''<!DOCTYPE html><html lang="ro"><head><meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Audit Devrika — {tag}</title>
<link rel="preconnect" href="https://fonts.googleapis.com">
<link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&family=Sora:wght@400;600;700;800&display=swap" rel="stylesheet">
<script src="https://cdn.jsdelivr.net/npm/chart.js@4.4.0/dist/chart.umd.min.js"></script>
<style>{CSS}</style></head><body>

<div class="page cover">
  <div class="cover-top"><div class="agency-badge">Devrika</div><div class="cover-date">{d.get("date","")}</div></div>
  <div class="cover-hero">
    <div class="cover-titles"><div class="cover-tag">Audit Gratuit · SEO + Google Ads</div>
      <h1 class="cover-title">{tag}</h1>
      <p class="cover-subtitle">Cat de bine te gasesc clientii online — si cat pierzi</p></div>
    <div class="gauge-wrap"><canvas id="gaugeChart"></canvas>
      <div class="gauge-center"><div class="gauge-score">{s["global"]}</div><div class="gauge-max">din 100</div>
        <div class="gauge-label">Vizibilitate online</div></div></div>
    <div class="score-grid">
      <div class="score-pill"><span class="score-pill-val">{s["seo"]}</span><span class="score-pill-lbl">SEO Tehnic</span></div>
      <div class="score-pill"><span class="score-pill-val">{s["content"]}</span><span class="score-pill-lbl">Continut</span></div>
      <div class="score-pill"><span class="score-pill-val">{s["ads"]}</span><span class="score-pill-lbl">Google Ads / Shopping</span></div>
      <div class="score-pill"><span class="score-pill-val">{s["speed"]}</span><span class="score-pill-lbl">Viteza &amp; Mobil</span></div></div>
  </div>
  <div class="cover-footer"><div class="cover-meta">
    <strong>Site analizat:</strong> {d.get("url","")}<br>
    <strong>Platforma:</strong> {d.get("platform","")}<br>
    <strong>Tip business:</strong> {d.get("business","")}<br>
    <strong>Pregatit de:</strong> Devrika Agency</div>
    <div class="cover-logo-area"><div class="cover-logo-text">DEVRIKA AGENCY</div></div></div>
</div>

<div class="page page-inner">
  <div class="page-header"><div class="page-section-label">Ce am gasit pe scurt</div><div class="page-logo-sm">{sub}</div></div>
  <div class="callout"><strong>Pe scurt:</strong> {d.get("summary","")}</div>
  <div class="exec-two-col">
    <div class="exec-card"><div class="exec-card-head critical">&#9888; Ce te costa acum</div>
      <div class="exec-card-body">{exec_items(d.get("costs",[]))}</div></div>
    <div class="exec-card"><div class="exec-card-head wins">&#10003; Castiguri rapide (sub 1 zi)</div>
      <div class="exec-card-body">{exec_items(d.get("wins",[]))}</div></div></div>
  <div class="section-title">Scorul tau pe categorii</div>
  <table class="score-table"><thead><tr><th>Categorie</th><th style="width:50mm">Cat de sanatos</th><th>Scor</th><th>Principala problema</th></tr></thead>
    <tbody>{score_rows(d.get("score_table",[]))}</tbody></table>
  {speed_note}
  {footer(2)}
</div>

<div class="page page-inner">
  <div class="page-header"><div class="page-section-label">Cum te gasesc clientii (SEO)</div><div class="page-logo-sm">{sub}</div></div>
  {f'<div class="callout">{d["seo_intro"]}</div>' if d.get("seo_intro") else ""}
  {tech_chips(d.get("tech_signals", []))}
  <div class="section-title">Probleme care iti scad vanzarile</div>
  <table class="findings-table"><thead><tr><th class="col-sev">Cat de grav</th><th>Problema</th><th class="col-area">Arie</th><th class="col-fix">Efort fix</th></tr></thead>
    <tbody>{finding_rows(d.get("seo_findings",[]))}</tbody></table>
  {strengths}
  {footer(3)}
</div>

<div class="page page-inner">
  <div class="page-header"><div class="page-section-label">Google Ads &amp; Shopping — bani lasati pe masa</div><div class="page-logo-sm">{sub}</div></div>
  {f'<div class="callout"><strong>Context:</strong> {d["ads_context"]}</div>' if d.get("ads_context") else ""}
  <div class="section-title">Oportunitati Google Ads / Shopping</div>
  <table class="findings-table"><thead><tr><th class="col-sev">Prioritate</th><th>Oportunitate</th><th class="col-area">Impact</th><th class="col-fix">Efort</th></tr></thead>
    <tbody>{finding_rows(d.get("ads_findings",[]))}</tbody></table>
  {ads_comp}
  {footer(4)}
</div>

<div class="page page-inner">
  <div class="page-header"><div class="page-section-label">Ce facem mai departe</div><div class="page-logo-sm">{sub}</div></div>
  {f'<div class="callout">{d["plan_intro"]}</div>' if d.get("plan_intro") else ""}
  <div class="section-title">Plan prioritizat</div>
  <table class="action-table"><thead><tr><th style="width:6mm">#</th><th>Actiune</th><th style="width:20mm">Zona</th><th style="width:14mm">Efort</th><th style="width:24mm">Impact</th></tr></thead>
    <tbody>{plan_rows(d.get("plan",[]))}</tbody></table>
  <div class="cta"><h3>{cta.get("title","Vrei sa rezolvam asta pentru tine?")}</h3>
    <p>{cta.get("text","Echipa Devrika poate implementa tot planul de mai sus. Prima discutie e gratuita.")}</p>
    <span class="cta-btn">{cta.get("btn","Programeaza o discutie gratuita")}</span>
    <div class="cta-contact">{cta.get("contact","<strong>devrika.ro</strong> · contact@devrika.ro")}</div></div>
  {footer(5)}
</div>

<script>(function(){{var c=document.getElementById('gaugeChart');if(!c)return;var sc={s["global"]},f=sc/100;
new Chart(c,{{type:'doughnut',data:{{datasets:[{{data:[f,1-f],backgroundColor:['#E07B00','rgba(255,255,255,0.08)'],borderWidth:0,circumference:270,rotation:225}}]}},
options:{{responsive:true,maintainAspectRatio:true,cutout:'72%',plugins:{{legend:{{display:false}},tooltip:{{enabled:false}}}},animation:{{duration:0}}}}}});}})();</script>
</body></html>'''
    return html

def main():
    if len(sys.argv) < 3:
        sys.exit("usage: python build.py date.json raport.html")
    d = json.load(open(sys.argv[1], encoding="utf-8"))
    open(sys.argv[2], "w", encoding="utf-8").write(build(d))
    print("HTML generat:", sys.argv[2])

if __name__ == "__main__":
    main()
