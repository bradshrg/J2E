cd /workspaces/J2E && bash <<'BASH'
set -euo pipefail

echo "=== Confirming repository ==="
test -d frontend/src
test -f frontend/src/App.js
test -f frontend/src/components/PageLayout.jsx
test -f frontend/src/Pages/HomePage.js

git switch main
git pull --ff-only origin main

BRANCH="clean-white-site"
if git show-ref --verify --quiet "refs/heads/$BRANCH"; then
  git switch "$BRANCH"
else
  git switch -c "$BRANCH"
fi

mkdir -p tools

cat > tools/clean_white_site.py <<'PY'
from pathlib import Path
import re
import shutil

ROOT = Path("/workspaces/J2E")
SRC = ROOT / "frontend" / "src"


def read(relative):
    return (ROOT / relative).read_text(encoding="utf-8")


def write(relative, content):
    path = ROOT / relative
    path.write_text(content, encoding="utf-8")
    print(f"updated: {relative}")


def replace_required(text, old, new, label):
    if old not in text:
        raise RuntimeError(f"Could not find expected code for: {label}")
    return text.replace(old, new, 1)


# ---------------------------------------------------------
# 1. Remove obsolete source backups and one-off repair files
# ---------------------------------------------------------
obsolete_dirs = [
    ROOT / "_Archive",
    ROOT / "temp_backup",
    SRC / "Pages" / "HPBackups",
    SRC / "Pages" / "Fixes",
]

for directory in obsolete_dirs:
    if directory.exists():
        shutil.rmtree(directory)
        print(f"removed directory: {directory.relative_to(ROOT)}")

obsolete_patterns = [
    "*.backup",
    "*.backup-*",
    "*.bak",
    "*.bak.*",
    "*.before_*",
    "*.before.*",
    "*.broken",
    "*.tmp",
]

for pattern in obsolete_patterns:
    for path in SRC.rglob(pattern):
        if path.is_file():
            path.unlink()
            print(f"removed backup: {path.relative_to(ROOT)}")

for path in [
    SRC / "Pages" / "add-top-margin.js",
    SRC / "Pages" / "nav_fix_clean.js",
    SRC / "Pages" / "step3-fancy-font.js",
    SRC / "Pages" / "step4-tagline-style.js",
    SRC / "Pages" / "step5-bigger-sidebox.js",
    SRC / "Pages" / "step6-title-bottom.js",
    SRC / "Pages" / "symmetrical-layout.js",
    SRC / "Pages" / "VETTED_logo_fix.js",
]:
    if path.exists():
        path.unlink()
        print(f"removed obsolete helper: {path.relative_to(ROOT)}")


# ---------------------------------------------------------
# 2. Repair TranslationContext and redesign PageLayout
# ---------------------------------------------------------
layout_path = "frontend/src/components/PageLayout.jsx"
layout = read(layout_path)

old_provider = (
    '<TranslationContext.Provider value={{ currentLang, setCurrentLang, '
    'T, LANGS, translations: T }}>'
)

if old_provider in layout:
    translation_helper = """
  const t = useCallback((key, fallback) => {
    const value = String(key)
      .split('.')
      .reduce((current, part) => (
        current && Object.prototype.hasOwnProperty.call(current, part)
          ? current[part]
          : undefined
      ), T);

    return value ?? fallback ?? key;
  }, [T]);

"""
    anchor = "  return (\n    <TranslationContext.Provider"
    if anchor not in layout:
        raise RuntimeError("Could not locate PageLayout return statement.")

    layout = layout.replace(
        anchor,
        translation_helper + "  return (\n    <TranslationContext.Provider",
        1,
    )
    layout = layout.replace(
        old_provider,
        '<TranslationContext.Provider value={{ currentLang, setCurrentLang, '
        'T, t, LANGS, translations: T }}>',
        1,
    )

replacements = {
    "color: '#FFD700', fontSize: '0.7rem'":
        "color: '#624d00', fontSize: '0.7rem'",

    "background: active ? 'linear-gradient(135deg,rgba(255,215,0,0.3),rgba(0,212,255,0.3))' : 'rgba(0,0,0,0.7)'":
        "background: active ? '#fff3bf' : '#ffffff'",

    "boxShadow: '0 0 6px rgba(255,215,0,0.3)'":
        "boxShadow: '0 2px 8px rgba(31,41,55,0.10)'",

    "background: 'linear-gradient(135deg,rgba(26,26,26,0.98),rgba(10,10,10,0.98))'":
        "background: 'rgba(255,255,255,0.98)'",

    "boxShadow: '0 4px 20px rgba(0,0,0,0.5)'":
        "boxShadow: '0 4px 18px rgba(31,41,55,0.12)'",

    "backgroundColor:'rgba(0,0,0,0.82)', backgroundImage:'url(/images/star-pattern.png)'":
        "backgroundColor:'#fffdf5'",

    "boxShadow:'0 4px 20px rgba(0,0,0,0.8)'":
        "boxShadow:'0 4px 18px rgba(31,41,55,0.12)'",

    "minHeight:'160px', maxHeight:'160px'":
        "minHeight:'118px', maxHeight:'118px'",

    "background:'rgba(0,0,0,0.95)'":
        "background:'#ffffff'",

    "background:'rgba(0,0,0,0.97)'":
        "background:'#ffffff'",

    "color:'#00d4ff'":
        "color:'#075985'",

    "color:'#FFD700'":
        "color:'#725800'",

    "paddingTop:'235px', minHeight:'100vh', backgroundColor:'#000', color:'#ffffff'":
        "paddingTop:'168px', minHeight:'100vh', backgroundColor:'#ffffff', color:'#1f2937'",

    "background:'linear-gradient(90deg,rgba(255,0,0,0.12),rgba(255,165,0,0.12))'":
        "background:'#fffaf0'",

    "color:'#ffccbc'":
        "color:'#4b5563'",
}

for old, new in replacements.items():
    layout = layout.replace(old, new)

# Replace JS hover handlers that restore black backgrounds.
layout = layout.replace(
    "e.currentTarget.style.background='rgba(0,0,0,0.7)'",
    "e.currentTarget.style.background='#ffffff'",
)
layout = layout.replace(
    ":'rgba(0,0,0,0.7)'",
    ":'#ffffff'",
)

write(layout_path, layout)


# ---------------------------------------------------------
# 3. Remove nested layouts causing duplicate headers/spacing
# ---------------------------------------------------------
home_path = "frontend/src/Pages/HomePage.js"
home = read(home_path)

home = home.replace(
    "import Layout, { TranslationContext } from '../components/PageLayout';",
    "import { TranslationContext } from '../components/PageLayout';",
)

home = replace_required(
    home,
    '    <Layout pageTitle="HOME">\n      <div style={styles.mainContainer}>',
    '    <div className="mavj-home" style={styles.mainContainer}>',
    "HomePage opening Layout",
)

# Remove the final Layout closing tag only.
closing_index = home.rfind("</Layout>")
if closing_index == -1:
    raise RuntimeError("Could not locate HomePage closing Layout tag.")
home = home[:closing_index] + home[closing_index + len("</Layout>"):]

# Remove the oversized background-photo wrapper.
home = home.replace(
"""<div style={{
  position: 'relative',
  marginTop: '-60px',
          backgroundImage: 'url(/images/Robin.jpeg)',
  backgroundSize: 'cover',
  backgroundPosition: 'center 30%',
  backgroundAttachment: 'scroll',
  backgroundRepeat: 'no-repeat'
}}>""",
"""<div className="home-announcements">""",
1,
)

# Convert the principal announcement cards to light cards.
home_replacements = {
    "background: 'rgba(0,0,0,0.88)'":
        "background: '#ffffff'",
    "background: 'rgba(0,0,0,0.5)'":
        "background: '#f8fafc'",
    "background: 'rgba(0,0,0,0.4)'":
        "background: '#f8fafc'",
    "color: '#fff'":
        "color: '#1f2937'",
    "color: '#ddd'":
        "color: '#4b5563'",
    "color: '#ccc'":
        "color: '#4b5563'",
    "color: '#DDD6B8'":
        "color: '#4b5563'",
}

for old, new in home_replacements.items():
    home = home.replace(old, new)

# Shorten the homepage by removing containers 6 through 11.
start_marker = (
    "      {/* CONTAINER 6: QUANTUM PHYSICS FOUNDATION - "
    "FIXED VIDEO GALLERY */}"
)
end_marker = "      {/* CONTAINER 12: UNIVERSAL FOOTER */}"

start = home.find(start_marker)
end = home.find(end_marker)

if start == -1 or end == -1 or end <= start:
    raise RuntimeError(
        "Could not locate homepage containers 6 through 11."
    )

compact_section = """      {/* COMPACT HOMEPAGE NAVIGATION */}
      <section className="home-explore">
        <h2>Explore the Journey</h2>
        <p>
          Continue through the focused pages instead of loading every
          program, gallery, artisan profile, and research section here.
        </p>
        <div className="home-explore-grid">
          <a href="/TheJourney">The Journey</a>
          <a href="/Recipes">Recipes</a>
          <a href="/MAVJStore">Store</a>
          <a href="/Journey2Enlightenment">Journey 2 Enlightenment</a>
          <a href="/VibrationalIntelligence">Vibrational Intelligence</a>
          <a href="/AlignWithUs">Align With Us</a>
        </div>
      </section>

"""

home = home[:start] + compact_section + home[end:]

# Repair footer links that previously led to missing routes.
home = home.replace('href="/privacy"', 'href="/ContactUs"')
home = home.replace('href="/terms"', 'href="/ContactUs"')
home = home.replace('href="/contact"', 'href="/ContactUs"')

write(home_path, home)


# TheJourney also contained a second PageLayout and expected t().
journey_path = "frontend/src/Pages/TheJourney.js"
journey = read(journey_path)

journey = journey.replace(
    'import PageLayout from "../components/PageLayout.jsx";\n',
    "",
)
journey = replace_required(
    journey,
    "    <PageLayout>\n      <VIBreadcrumbs />",
    '    <div className="content-page journey-page">\n      <VIBreadcrumbs />',
    "TheJourney opening PageLayout",
)

journey_closing = journey.rfind("</PageLayout>")
if journey_closing == -1:
    raise RuntimeError("Could not locate TheJourney closing PageLayout tag.")
journey = (
    journey[:journey_closing]
    + "</div>"
    + journey[journey_closing + len("</PageLayout>"):]
)

write(journey_path, journey)


# ---------------------------------------------------------
# 4. Repair known broken routes and route aliases
# ---------------------------------------------------------
app_path = "frontend/src/App.js"
app = read(app_path)

# Use React Router for the 404 homepage link.
app = app.replace(
    "import { BrowserRouter as Router, Routes, Route, Navigate } "
    "from 'react-router-dom';",
    "import { BrowserRouter as Router, Routes, Route, Navigate, Link } "
    "from 'react-router-dom';",
)

route_anchor = (
    '                <Route path="/home" '
    'element={<Navigate to="/" replace />} />'
)

alias_routes = """                <Route path="/home" element={<Navigate to="/" replace />} />
                <Route path="/Search" element={<Navigate to="/MAVJSearch" replace />} />
                <Route path="/contact" element={<Navigate to="/ContactUs" replace />} />
                <Route path="/privacy" element={<Navigate to="/ContactUs" replace />} />
                <Route path="/terms" element={<Navigate to="/ContactUs" replace />} />
                <Route path="/book" element={<Navigate to="/Consultations" replace />} />
                <Route path="/reset" element={<Navigate to="/MAVJDetox" replace />} />
                <Route path="/research" element={<Navigate to="/VibrationalIntelligence/QuantumResearch" replace />} />
                <Route path="/cart" element={<Navigate to="/Checkout" replace />} />
                <Route path="/ShoppingCart" element={<Navigate to="/Checkout" replace />} />
                <Route path="/Q" element={<Navigate to="/" replace />} />
                <Route path="/journey-to-enlightenment" element={<Navigate to="/Journey2Enlightenment" replace />} />
                <Route path="/j2e-agro" element={<Navigate to="/J2EAgro" replace />} />
                <Route path="/j2e-aqua" element={<Navigate to="/J2EAqua" replace />} />
                <Route path="/j2e-accommodations" element={<Navigate to="/J2EAccommodations" replace />} />
                <Route path="/vibrational-intelligence" element={<Navigate to="/VibrationalIntelligence" replace />} />
                <Route path="/vibrational-intelligence/science-of-consciousness" element={<Navigate to="/VibrationalIntelligence/ScienceOfConsciousness" replace />} />
                <Route path="/vibrational-intelligence/science-of-consciousness/neuro-quantics" element={<Navigate to="/VibrationalIntelligence/ScienceOfConsciousness/NeuroQuantics" replace />} />
                <Route path="/vibrational-intelligence/science-of-consciousness/biofield-research" element={<Navigate to="/VibrationalIntelligence/ScienceOfConsciousness/BiofieldResearch" replace />} />
                <Route path="/vibrational-intelligence/quantum-research" element={<Navigate to="/VibrationalIntelligence/QuantumResearch" replace />} />
                <Route path="/vibrational-intelligence/quantum-research/quantum-biology-news" element={<Navigate to="/VibrationalIntelligence/QuantumResearch/QuantumBiologyNews" replace />} />"""

if alias_routes not in app:
    app = replace_required(
        app,
        route_anchor,
        alias_routes,
        "App route aliases",
    )

app = app.replace(
    '<p>Return to <a href="/" style={{ color: \'#00d4ff\' }}>Homepage</a></p>',
    '<p>Return to <Link to="/" style={{ color: \'#075985\' }}>Homepage</Link></p>',
)

app = app.replace(
    "style={{ padding: '20px', textAlign: 'center', color: '#FFD700' }}",
    "className=\"not-found\"",
)

write(app_path, app)


navbar_path = "frontend/src/components/Navbar.js"
navbar = read(navbar_path)
navbar = navbar.replace('to="/Search"', 'to="/MAVJSearch"')
write(navbar_path, navbar)


# ---------------------------------------------------------
# 5. Remove duplicated white-theme override from index.css
# ---------------------------------------------------------
index_css_path = "frontend/src/index.css"
index_css = read(index_css_path)

marker = "/* =========================================================\n   MAVJ LIGHT THEME OVERRIDE"
first = index_css.find(marker)
if first != -1:
    index_css = index_css[:first].rstrip() + "\n"

# Remove a second older duplicate block if it starts at its heading.
old_heading = "/* Main content containers */"
old_start = index_css.find(old_heading)
if old_start != -1 and old_start > max(0, len(index_css) - 7000):
    index_css = index_css[:old_start].rstrip() + "\n"

write(index_css_path, index_css)


# ---------------------------------------------------------
# 6. Add centralized, intentional theme system
# ---------------------------------------------------------
theme = r"""
:root {
  --mavj-bg: #ffffff;
  --mavj-surface: #fffdf7;
  --mavj-surface-alt: #f8fafc;
  --mavj-text: #1f2937;
  --mavj-muted: #596273;
  --mavj-gold: #8a6a00;
  --mavj-gold-bright: #d8a900;
  --mavj-cyan: #075985;
  --mavj-border: #e5d7a3;
  --mavj-shadow: 0 10px 28px rgba(31, 41, 55, 0.10);
}

html,
body,
#root {
  min-height: 100%;
  margin: 0;
  background: var(--mavj-bg);
  color: var(--mavj-text);
}

body {
  font-family: Inter, system-ui, -apple-system, BlinkMacSystemFont,
    "Segoe UI", sans-serif;
}

* {
  box-sizing: border-box;
}

a {
  color: var(--mavj-cyan);
}

button,
input,
select,
textarea {
  font: inherit;
}

input,
select,
textarea {
  background: #ffffff;
  color: var(--mavj-text);
  border: 1px solid #cbd5e1;
}

main,
.site-shell,
.content-page,
.mavj-home {
  background: var(--mavj-bg);
  color: var(--mavj-text);
}

.mavj-home {
  width: min(1180px, 100%);
  margin: 0 auto;
  padding: 0 20px 32px;
}

.home-announcements {
  position: relative;
  margin: 0;
  padding: 0;
  background: #ffffff;
}

.home-announcements > div {
  position: relative;
}

.mavj-home section {
  margin: 22px 0;
  border-radius: 18px;
}

.mavj-home h1,
.mavj-home h2,
.mavj-home h3,
.content-page h1,
.content-page h2,
.content-page h3 {
  color: var(--mavj-gold);
}

.mavj-home p,
.mavj-home li,
.content-page p,
.content-page li {
  color: var(--mavj-text);
}

.home-announcements section:first-of-type {
  padding-top: 26px !important;
}

.home-announcements section:first-of-type > div:nth-child(2) > div {
  background: #ffffff !important;
  color: var(--mavj-text) !important;
  border: 1px solid var(--mavj-border) !important;
  border-image: none !important;
  box-shadow: var(--mavj-shadow);
  min-height: 0 !important;
}

.home-announcements section:first-of-type p,
.home-announcements section:first-of-type span {
  color: var(--mavj-text);
}

.home-announcements section:first-of-type h2,
.home-announcements section:first-of-type h3 {
  color: var(--mavj-gold) !important;
}

.home-explore {
  background: var(--mavj-surface);
  border: 1px solid var(--mavj-border);
  padding: 30px;
  text-align: center;
  box-shadow: var(--mavj-shadow);
}

.home-explore h2 {
  margin-top: 0;
}

.home-explore-grid {
  display: grid;
  grid-template-columns: repeat(3, minmax(0, 1fr));
  gap: 12px;
  margin-top: 22px;
}

.home-explore-grid a {
  display: flex;
  min-height: 54px;
  align-items: center;
  justify-content: center;
  padding: 12px;
  color: #503f00;
  background: #ffffff;
  border: 1px solid var(--mavj-border);
  border-radius: 12px;
  text-decoration: none;
  font-weight: 750;
  box-shadow: 0 4px 12px rgba(31, 41, 55, 0.07);
}

.home-explore-grid a:hover {
  background: #fff4c7;
  transform: translateY(-1px);
}

.content-page {
  width: min(1000px, calc(100% - 32px));
  margin: 0 auto;
  padding: 28px;
}

.journey-page > div {
  color: var(--mavj-text);
}

.not-found {
  max-width: 720px;
  margin: 60px auto;
  padding: 40px;
  text-align: center;
  color: var(--mavj-text);
  background: var(--mavj-surface);
  border: 1px solid var(--mavj-border);
  border-radius: 16px;
}

footer {
  background: var(--mavj-surface) !important;
  color: var(--mavj-muted) !important;
}

@media (max-width: 800px) {
  .mavj-home {
    padding-inline: 12px;
  }

  .home-explore-grid {
    grid-template-columns: 1fr;
  }

  .content-page {
    width: calc(100% - 20px);
    padding: 18px;
  }
}
""".strip() + "\n"

write("frontend/src/styles/theme-light.css", theme)

index_js_path = "frontend/src/index.js"
index_js = read(index_js_path)

theme_import = "import './styles/theme-light.css';"
if theme_import not in index_js:
    index_js = index_js.replace(
        "import './index.css';",
        "import './index.css';\nimport './styles/theme-light.css';",
        1,
    )

write(index_js_path, index_js)


# ---------------------------------------------------------
# 7. Keep future generated files out of source control
# ---------------------------------------------------------
gitignore_path = ".gitignore"
gitignore = read(gitignore_path)

ignore_entries = """
# Local/generated material
_Archive/
temp_backup/
**/.venv/
**/venv/
**/__pycache__/
*.py[cod]
frontend/build/
frontend/src/**/*.backup*
frontend/src/**/*.bak*
frontend/src/**/*.before_*
frontend/src/**/*.broken
J2E-*.zip
""".strip()

if "# Local/generated material" not in gitignore:
    gitignore = gitignore.rstrip() + "\n\n" + ignore_entries + "\n"
    write(gitignore_path, gitignore)

print("\nSource transformation completed.")
PY

python3 tools/clean_white_site.py

echo
echo "=== Installing frontend dependencies ==="
cd /workspaces/J2E/frontend
npm ci

echo
echo "=== Running production build ==="
npm run build

echo
echo "=== Reviewing changes ==="
cd /workspaces/J2E
git status --short

echo
echo "=== Committing ==="
git add -A
git commit -m "Create clean white theme, shorten homepage, and repair routes"

echo
echo "=== Pushing branch ==="
git push -u origin clean-white-site

echo
echo "DONE."
echo "Open the GitHub pull request from clean-white-site into main."
echo "Preview locally with:"
echo "  cd /workspaces/J2E/frontend && npm start"
BASH