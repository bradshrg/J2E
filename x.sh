cd /workspaces/J2E && bash <<'BASH'
set -euo pipefail

BASE_BRANCH="clean-white-site"
NEW_BRANCH="professional-white-redesign"

echo "=== Updating source branch ==="
git fetch origin
git switch "$BASE_BRANCH"
git pull --ff-only origin "$BASE_BRANCH"

if git show-ref --verify --quiet "refs/heads/$NEW_BRANCH"; then
  git switch "$NEW_BRANCH"
else
  git switch -c "$NEW_BRANCH"
fi

echo "=== Removing temporary migration files ==="
rm -f bullshit.sh bullshit1.sh
rm -f tools/clean_white_site.py
rmdir tools 2>/dev/null || true

cat > /tmp/redesign_mavj.py <<'PY'
from pathlib import Path

ROOT = Path("/workspaces/J2E")
SRC = ROOT / "frontend" / "src"


def read(relative: str) -> str:
    return (ROOT / relative).read_text(encoding="utf-8")


def write(relative: str, content: str) -> None:
    path = ROOT / relative
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(content, encoding="utf-8")
    print(f"updated: {relative}")


# ==========================================================
# 1. Replace the enormous homepage with a focused landing page
# ==========================================================
homepage = r'''import React from 'react';
import { Link } from 'react-router-dom';

const pathways = [
  {
    title: 'The Journey',
    text: 'Begin with the principles, story, and practical foundation of the alkaline vegan journey.',
    to: '/TheJourney',
  },
  {
    title: 'Recipes',
    text: 'Explore focused alkaline meals, snacks, drinks, herbs, oils, seeds, and sea moss.',
    to: '/Recipes',
  },
  {
    title: 'Alkaline Shop',
    text: 'Browse sea moss, wellness products, merchandise, consultations, and related offerings.',
    to: '/MAVJStore',
  },
];

const featured = [
  {
    eyebrow: 'Nutrition',
    title: 'Alkaline Recipes',
    text: 'Simple food pathways organized around ingredients and practical preparation.',
    to: '/Recipes',
  },
  {
    eyebrow: 'Wellness',
    title: 'Vibrational Intelligence',
    text: 'Explore frequency, consciousness, biofield research, and wellness practices.',
    to: '/VibrationalIntelligence',
  },
  {
    eyebrow: 'St. Lucia',
    title: 'Journey 2 Enlightenment',
    text: 'Discover accommodations, excursions, workshops, food, agriculture, and water experiences.',
    to: '/Journey2Enlightenment',
  },
  {
    eyebrow: 'Community',
    title: 'Align With Us',
    text: 'Connect, participate, collaborate, and support the ongoing journey.',
    to: '/AlignWithUs',
  },
];

const HomePage = () => (
  <main className="new-home">
    <section className="new-home__hero">
      <div className="new-home__hero-logo">
        <img
          src="/images/MAVJLogo.jpg"
          alt="My Alkaline Vegan Journey"
          onError={(event) => {
            event.currentTarget.style.display = 'none';
          }}
        />
      </div>

      <p className="new-home__kicker">My Alkaline Vegan Journey</p>

      <h1>
        A clearer path to food, wellness, consciousness, and community.
      </h1>

      <p className="new-home__intro">
        Explore practical alkaline nutrition, plant-based recipes, sea moss,
        wellness education, and the Journey 2 Enlightenment experience in
        St. Lucia.
      </p>

      <div className="new-home__actions">
        <Link className="button button--primary" to="/TheJourney">
          Start the Journey
        </Link>
        <Link className="button button--secondary" to="/MAVJStore">
          Visit the Shop
        </Link>
      </div>
    </section>

    <section className="new-home__section">
      <div className="section-heading">
        <p>Choose your path</p>
        <h2>Explore the main areas</h2>
      </div>

      <div className="pathway-grid">
        {pathways.map((item) => (
          <Link className="pathway-card" to={item.to} key={item.to}>
            <span className="pathway-card__arrow">↗</span>
            <h3>{item.title}</h3>
            <p>{item.text}</p>
          </Link>
        ))}
      </div>
    </section>

    <section className="new-home__feature-band">
      <div>
        <p className="feature-band__eyebrow">Featured focus</p>
        <h2>Food and wellness without the visual noise</h2>
        <p>
          The homepage now introduces the major pathways instead of loading
          every video, product, gallery, announcement, game, and program into
          one very long page.
        </p>
      </div>

      <Link className="text-link" to="/MAVJSearch">
        Search the full site <span aria-hidden="true">→</span>
      </Link>
    </section>

    <section className="new-home__section">
      <div className="section-heading">
        <p>Discover more</p>
        <h2>Nutrition, wellness, and experience</h2>
      </div>

      <div className="featured-grid">
        {featured.map((item) => (
          <article className="featured-card" key={item.to}>
            <p className="featured-card__eyebrow">{item.eyebrow}</p>
            <h3>{item.title}</h3>
            <p>{item.text}</p>
            <Link to={item.to}>Learn more →</Link>
          </article>
        ))}
      </div>
    </section>

    <section className="new-home__contact">
      <div>
        <p>Questions or collaboration</p>
        <h2>Connect with My Alkaline Vegan Journey</h2>
      </div>

      <Link className="button button--primary" to="/ContactUs">
        Contact Us
      </Link>
    </section>
  </main>
);

export default HomePage;
'''

write("frontend/src/Pages/HomePage.js", homepage)


# ==========================================================
# 2. Preserve all translation data, but replace the old chrome
# ==========================================================
layout_path = "frontend/src/components/PageLayout.jsx"
layout = read(layout_path)

return_marker = (
    "\n  return (\n"
    "    <TranslationContext.Provider value={{ currentLang, "
    "setCurrentLang, T, t, LANGS, translations: T }}>"
)

start = layout.find(return_marker)

if start == -1:
    raise RuntimeError(
        "Could not locate the current PageLayout return block. "
        "The branch does not match the uploaded source."
    )

new_return = r'''
  return (
    <TranslationContext.Provider
      value={{
        currentLang,
        setCurrentLang,
        T,
        t,
        LANGS,
        translations: T,
      }}
    >
      <div className="site-frame">
        <header className="site-header">
          <div className="site-header__inner">
            <button
              type="button"
              className="site-brand"
              onClick={() => handleNav('/')}
              aria-label="Go to homepage"
            >
              <img
                src="/images/MAVJLogo.jpg"
                alt=""
                onError={(event) => {
                  event.currentTarget.style.display = 'none';
                }}
              />
              <span>
                <strong>My Alkaline Vegan Journey</strong>
                <small>Food · Wellness · Consciousness</small>
              </span>
            </button>

            <nav className="site-navigation" aria-label="Primary navigation">
              {navItems
                .filter((item) => item.type === 'nav')
                .slice(0, 9)
                .map((item) => (
                  <button
                    type="button"
                    key={item.path}
                    className={
                      location.pathname === item.path
                        ? 'site-navigation__link is-active'
                        : 'site-navigation__link'
                    }
                    onClick={() => handleNav(item.path)}
                  >
                    {item.label}
                  </button>
                ))}
            </nav>

            <div className="site-header__actions">
              <div className="language-control">
                <button
                  type="button"
                  className="language-control__button"
                  onClick={() => setShowDropdown((open) => !open)}
                  aria-expanded={showDropdown}
                >
                  <span>{activeLangObj.flag}</span>
                  <span>{currentLang}</span>
                  <span aria-hidden="true">⌄</span>
                </button>

                {showDropdown && (
                  <div className="language-menu">
                    {LANGS.map((language) => (
                      <button
                        type="button"
                        key={language.name}
                        className={
                          language.name === currentLang ? 'is-active' : ''
                        }
                        onClick={() => handleLangChange(language.name)}
                      >
                        <span>{language.flag}</span>
                        <span>{language.name}</span>
                      </button>
                    ))}
                  </div>
                )}
              </div>

              <button
                type="button"
                className="header-search"
                onClick={() => handleNav('/MAVJSearch')}
                aria-label="Search"
              >
                Search
              </button>
            </div>
          </div>

          <div className="site-header__mobile-nav">
            {navItems
              .filter((item) => item.type === 'nav')
              .slice(0, 9)
              .map((item) => (
                <button
                  type="button"
                  key={item.path}
                  className={
                    location.pathname === item.path ? 'is-active' : ''
                  }
                  onClick={() => handleNav(item.path)}
                >
                  {item.label}
                </button>
              ))}
          </div>
        </header>

        {pageTitle && pageTitle !== 'HOME' && (
          <div className="page-title-strip">
            <p>My Alkaline Vegan Journey</p>
            <h1>{displayTitle}</h1>
          </div>
        )}

        <div className="site-content">{children}</div>

        <footer className="site-footer">
          <div className="site-footer__inner">
            <div>
              <strong>My Alkaline Vegan Journey</strong>
              <p>
                Plant-based nutrition, wellness education, and transformational
                experiences.
              </p>
            </div>

            <div className="site-footer__links">
              <button type="button" onClick={() => handleNav('/AboutUs')}>
                About
              </button>
              <button type="button" onClick={() => handleNav('/ContactUs')}>
                Contact
              </button>
              <button type="button" onClick={() => handleNav('/MAVJSearch')}>
                Search
              </button>
            </div>
          </div>

          <p className="site-footer__notice">{T.foot}</p>
        </footer>
      </div>
    </TranslationContext.Provider>
  );
};

export default Layout;
'''

layout = layout[:start] + "\n" + new_return.lstrip()
write(layout_path, layout)


# ==========================================================
# 3. Replace prior experimental theme with deliberate styling
# ==========================================================
theme = r''':root {
  --page-bg: #ffffff;
  --surface: #ffffff;
  --surface-warm: #f5e4c5;
  --surface-soft: #faf8f3;
  --text: #202020;
  --text-muted: #686868;
  --border: #e8e3da;
  --accent: #6f5325;
  --accent-dark: #493718;
  --shadow: 0 18px 45px rgba(34, 28, 18, 0.08);
  --content-width: 1180px;
}

html,
body,
#root {
  min-height: 100%;
  margin: 0;
  background: var(--page-bg);
  color: var(--text);
}

body {
  font-family: Inter, "Helvetica Neue", Arial, sans-serif;
  font-size: 16px;
  line-height: 1.55;
  -webkit-font-smoothing: antialiased;
}

* {
  box-sizing: border-box;
}

button,
input,
select,
textarea {
  font: inherit;
}

button {
  color: inherit;
}

a {
  color: inherit;
}

img {
  max-width: 100%;
}

.site-frame {
  min-height: 100vh;
  background: #fff;
}

.site-header {
  position: sticky;
  top: 0;
  z-index: 1000;
  background: rgba(255, 255, 255, 0.97);
  border-bottom: 1px solid var(--border);
  backdrop-filter: blur(14px);
}

.site-header__inner {
  width: min(var(--content-width), calc(100% - 40px));
  min-height: 84px;
  margin: 0 auto;
  display: grid;
  grid-template-columns: minmax(240px, auto) 1fr auto;
  align-items: center;
  gap: 30px;
}

.site-brand {
  border: 0;
  padding: 0;
  background: transparent;
  display: inline-flex;
  align-items: center;
  gap: 12px;
  text-align: left;
  cursor: pointer;
}

.site-brand img {
  width: 48px;
  height: 48px;
  border-radius: 50%;
  object-fit: cover;
}

.site-brand span {
  display: grid;
  gap: 2px;
}

.site-brand strong {
  font-family: Georgia, "Times New Roman", serif;
  font-size: 1rem;
  letter-spacing: 0.02em;
}

.site-brand small {
  color: var(--text-muted);
  font-size: 0.7rem;
  letter-spacing: 0.12em;
  text-transform: uppercase;
}

.site-navigation {
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 4px;
}

.site-navigation__link {
  position: relative;
  border: 0;
  padding: 30px 10px 26px;
  background: transparent;
  color: #383838;
  font-size: 0.72rem;
  font-weight: 600;
  letter-spacing: 0.08em;
  text-transform: uppercase;
  cursor: pointer;
  white-space: nowrap;
}

.site-navigation__link::after {
  position: absolute;
  right: 10px;
  bottom: 20px;
  left: 10px;
  height: 2px;
  background: transparent;
  content: "";
}

.site-navigation__link:hover::after,
.site-navigation__link.is-active::after {
  background: var(--text);
}

.site-header__actions {
  display: flex;
  align-items: center;
  gap: 8px;
}

.language-control {
  position: relative;
}

.language-control__button,
.header-search {
  min-height: 40px;
  border: 1px solid var(--border);
  border-radius: 999px;
  padding: 8px 13px;
  background: #fff;
  cursor: pointer;
}

.language-control__button {
  display: flex;
  align-items: center;
  gap: 7px;
  font-size: 0.78rem;
}

.header-search {
  font-size: 0.75rem;
  font-weight: 700;
  letter-spacing: 0.05em;
  text-transform: uppercase;
}

.language-menu {
  position: absolute;
  top: calc(100% + 10px);
  right: 0;
  width: 220px;
  max-height: 420px;
  overflow: auto;
  padding: 8px;
  border: 1px solid var(--border);
  border-radius: 12px;
  background: #fff;
  box-shadow: var(--shadow);
}

.language-menu button {
  width: 100%;
  border: 0;
  border-radius: 8px;
  padding: 9px 10px;
  background: transparent;
  display: flex;
  gap: 10px;
  cursor: pointer;
  text-align: left;
}

.language-menu button:hover,
.language-menu button.is-active {
  background: var(--surface-soft);
}

.site-header__mobile-nav {
  display: none;
}

.site-content {
  min-height: 60vh;
  background: #fff;
}

.page-title-strip {
  padding: 46px 20px;
  background: var(--surface-soft);
  border-bottom: 1px solid var(--border);
  text-align: center;
}

.page-title-strip p {
  margin: 0 0 7px;
  color: var(--accent);
  font-size: 0.72rem;
  font-weight: 700;
  letter-spacing: 0.18em;
  text-transform: uppercase;
}

.page-title-strip h1 {
  margin: 0;
  color: var(--text);
  font-family: Georgia, "Times New Roman", serif;
  font-size: clamp(2rem, 5vw, 3.2rem);
  font-weight: 400;
}

.new-home {
  width: min(var(--content-width), calc(100% - 40px));
  margin: 0 auto;
  padding: 42px 0 72px;
}

.new-home__hero {
  min-height: 520px;
  padding: 62px 9%;
  border-radius: 2px;
  background: var(--surface-warm);
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  text-align: center;
}

.new-home__hero-logo {
  width: 92px;
  height: 92px;
  margin-bottom: 22px;
}

.new-home__hero-logo img {
  width: 100%;
  height: 100%;
  border-radius: 50%;
  object-fit: cover;
}

.new-home__kicker,
.section-heading > p,
.feature-band__eyebrow,
.featured-card__eyebrow,
.new-home__contact > div > p {
  margin: 0 0 12px;
  color: var(--accent);
  font-size: 0.74rem;
  font-weight: 700;
  letter-spacing: 0.18em;
  text-transform: uppercase;
}

.new-home__hero h1 {
  max-width: 900px;
  margin: 0;
  font-family: Georgia, "Times New Roman", serif;
  font-size: clamp(2.6rem, 6vw, 5rem);
  font-weight: 400;
  line-height: 1.08;
  letter-spacing: -0.025em;
}

.new-home__intro {
  max-width: 720px;
  margin: 25px auto 0;
  color: #4f4a42;
  font-size: 1.08rem;
}

.new-home__actions {
  margin-top: 32px;
  display: flex;
  flex-wrap: wrap;
  justify-content: center;
  gap: 12px;
}

.button {
  min-height: 48px;
  padding: 12px 22px;
  border: 1px solid var(--text);
  display: inline-flex;
  align-items: center;
  justify-content: center;
  color: var(--text);
  font-size: 0.76rem;
  font-weight: 700;
  letter-spacing: 0.1em;
  text-decoration: none;
  text-transform: uppercase;
}

.button--primary {
  background: var(--text);
  color: #fff;
}

.button--secondary {
  background: transparent;
}

.button:hover {
  transform: translateY(-1px);
}

.new-home__section {
  padding: 88px 0 18px;
}

.section-heading {
  max-width: 720px;
  margin-bottom: 35px;
}

.section-heading h2,
.new-home__feature-band h2,
.new-home__contact h2 {
  margin: 0;
  font-family: Georgia, "Times New Roman", serif;
  font-size: clamp(2rem, 4vw, 3.25rem);
  font-weight: 400;
  line-height: 1.13;
}

.pathway-grid {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  border-top: 1px solid var(--border);
  border-left: 1px solid var(--border);
}

.pathway-card {
  min-height: 255px;
  padding: 34px;
  border-right: 1px solid var(--border);
  border-bottom: 1px solid var(--border);
  background: #fff;
  color: var(--text);
  text-decoration: none;
}

.pathway-card:hover {
  background: var(--surface-soft);
}

.pathway-card__arrow {
  display: block;
  margin-bottom: 52px;
  text-align: right;
  font-size: 1.25rem;
}

.pathway-card h3,
.featured-card h3 {
  margin: 0 0 13px;
  font-family: Georgia, "Times New Roman", serif;
  font-size: 1.65rem;
  font-weight: 400;
}

.pathway-card p,
.featured-card > p:not(.featured-card__eyebrow),
.new-home__feature-band p {
  margin: 0;
  color: var(--text-muted);
}

.new-home__feature-band {
  margin-top: 80px;
  padding: 58px;
  background: var(--surface-soft);
  display: grid;
  grid-template-columns: 1fr auto;
  align-items: end;
  gap: 40px;
}

.new-home__feature-band > div {
  max-width: 730px;
}

.new-home__feature-band h2 {
  margin-bottom: 18px;
}

.text-link {
  padding-bottom: 4px;
  border-bottom: 1px solid var(--text);
  font-weight: 700;
  text-decoration: none;
  white-space: nowrap;
}

.featured-grid {
  display: grid;
  grid-template-columns: repeat(2, 1fr);
  gap: 20px;
}

.featured-card {
  min-height: 270px;
  padding: 38px;
  border: 1px solid var(--border);
  background: #fff;
  display: flex;
  flex-direction: column;
}

.featured-card > a {
  margin-top: auto;
  padding-top: 32px;
  color: var(--accent-dark);
  font-weight: 700;
  text-decoration: none;
}

.new-home__contact {
  margin-top: 90px;
  padding: 54px 58px;
  background: var(--surface-warm);
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 30px;
}

.site-footer {
  margin-top: 50px;
  border-top: 1px solid var(--border);
  background: var(--surface-soft);
}

.site-footer__inner {
  width: min(var(--content-width), calc(100% - 40px));
  margin: 0 auto;
  padding: 48px 0 36px;
  display: flex;
  justify-content: space-between;
  gap: 40px;
}

.site-footer__inner strong {
  font-family: Georgia, "Times New Roman", serif;
  font-size: 1.15rem;
}

.site-footer__inner p {
  max-width: 520px;
  margin: 8px 0 0;
  color: var(--text-muted);
}

.site-footer__links {
  display: flex;
  align-items: flex-start;
  gap: 20px;
}

.site-footer__links button {
  border: 0;
  padding: 0;
  background: transparent;
  cursor: pointer;
  font-weight: 700;
}

.site-footer__notice {
  margin: 0;
  padding: 15px 20px;
  border-top: 1px solid var(--border);
  color: var(--text-muted);
  font-size: 0.68rem;
  letter-spacing: 0.08em;
  text-align: center;
}

.not-found {
  width: min(720px, calc(100% - 40px));
  margin: 80px auto;
  padding: 60px 30px;
  background: var(--surface-soft);
  text-align: center;
}

@media (max-width: 1180px) {
  .site-header__inner {
    grid-template-columns: 1fr auto;
  }

  .site-navigation {
    display: none;
  }

  .site-header__mobile-nav {
    display: flex;
    gap: 4px;
    overflow-x: auto;
    padding: 0 20px 12px;
  }

  .site-header__mobile-nav button {
    flex: 0 0 auto;
    border: 0;
    border-bottom: 2px solid transparent;
    padding: 8px 10px;
    background: transparent;
    font-size: 0.72rem;
    cursor: pointer;
  }

  .site-header__mobile-nav button.is-active {
    border-bottom-color: var(--text);
  }
}

@media (max-width: 760px) {
  .site-header__inner,
  .new-home,
  .site-footer__inner {
    width: min(100% - 24px, var(--content-width));
  }

  .site-header__inner {
    min-height: 72px;
    gap: 12px;
  }

  .site-brand small,
  .language-control {
    display: none;
  }

  .site-brand strong {
    font-size: 0.88rem;
  }

  .site-brand img {
    width: 40px;
    height: 40px;
  }

  .new-home {
    padding-top: 16px;
  }

  .new-home__hero {
    min-height: 440px;
    padding: 44px 22px;
  }

  .new-home__hero h1 {
    font-size: clamp(2.25rem, 12vw, 3.5rem);
  }

  .new-home__section {
    padding-top: 64px;
  }

  .pathway-grid,
  .featured-grid {
    grid-template-columns: 1fr;
  }

  .pathway-card {
    min-height: 215px;
  }

  .new-home__feature-band {
    margin-top: 62px;
    padding: 36px 25px;
    grid-template-columns: 1fr;
    align-items: start;
  }

  .new-home__contact {
    margin-top: 65px;
    padding: 38px 25px;
    flex-direction: column;
    align-items: flex-start;
  }

  .site-footer__inner {
    padding-top: 38px;
    flex-direction: column;
  }
}
'''

write("frontend/src/styles/theme-light.css", theme)


# ==========================================================
# 4. Add obsolete local files to .gitignore
# ==========================================================
gitignore_path = ".gitignore"
gitignore = read(gitignore_path)

entries = """
# One-time local scripts
bullshit*.sh
tools/clean_white_site.py
""".strip()

if "bullshit*.sh" not in gitignore:
    gitignore = gitignore.rstrip() + "\n\n" + entries + "\n"

write(gitignore_path, gitignore)

print("Redesign source changes completed.")
PY

python3 /tmp/redesign_mavj.py
rm -f /tmp/redesign_mavj.py

echo
echo "=== Installing exact dependencies ==="
cd /workspaces/J2E/frontend
npm ci

echo
echo "=== Building production frontend ==="
npm run build

echo
echo "=== Build passed; committing changes ==="
cd /workspaces/J2E
git add -A
git commit -m "Replace legacy homepage with professional white redesign"

echo
echo "=== Pushing redesign branch ==="
git push -u origin "$NEW_BRANCH"

echo
echo "===================================================="
echo "DONE"
echo "Branch: $NEW_BRANCH"
echo
echo "Preview it with:"
echo "  cd /workspaces/J2E/frontend"
echo "  npm start"
echo
echo "Do not merge until you inspect:"
echo "  /"
echo "  /TheJourney"
echo "  /Recipes"
echo "  /MAVJStore"
echo "  /Journey2Enlightenment"
echo "  /VibrationalIntelligence"
echo "  /AlignWithUs"
echo "  /MAVJSearch"
echo "===================================================="
BASH