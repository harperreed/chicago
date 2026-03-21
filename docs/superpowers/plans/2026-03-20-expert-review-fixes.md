# Expert Review Fixes Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Fix all critical and important findings from the 8-expert review panel, without changing the visual design.

**Architecture:** The site is a single-page Hugo static site deployed on Netlify. All fixes are template/config changes — no new pages or structural redesign. The Tailwind CDN swap is the largest change; everything else is small edits.

**Tech Stack:** Hugo 0.147.4, Tailwind CSS (currently CDN, moving to build-time), Leaflet 1.9.4, Netlify

**CONSTRAINT:** The visual design must not change. Every fix must preserve the current look. If a change risks altering appearance, verify by building locally with `hugo server` and comparing.

---

### Task 1: Add `lang="en"` to `<html>` tag

**Files:**
- Modify: `layouts/_default/baseof.html:2`

- [ ] **Step 1: Edit baseof.html**

Change line 2 from:
```html
<html>
```
to:
```html
<html lang="en">
```

- [ ] **Step 2: Build and verify**

Run: `hugo server`
Expected: Site looks identical. View source confirms `<html lang="en">`.

- [ ] **Step 3: Commit**

```bash
git add layouts/_default/baseof.html
git commit -m "fix: add lang=en to html element for accessibility"
```

---

### Task 2: Add `<main>` landmark and skip-to-content link

**Files:**
- Modify: `layouts/_default/baseof.html:8-17` (the entire `<body>...</body>` block)

- [ ] **Step 1: Edit baseof.html**

Replace the entire `<body>...</body>` block (lines 8-17) with:
```html
<body>
  <a href="#main-content" class="sr-only focus:not-sr-only focus:absolute focus:top-0 focus:left-0 focus:z-50 focus:p-4 focus:bg-white focus:text-black">Skip to content</a>
  <div class="container mx-auto my-5 sm:max-w-2xl px-5">

      {{ partialCached "header.html" . }}
      <main id="main-content">
      {{ block "main" . }}
      {{ end }}
      </main>
      {{ partialCached "footer.html" . }}
  </div>
  <script src="https://tinylytics.app/embed/FsFojECy_ojQBpqjn3Zp.js?kudos&hits&countries" defer></script>
</body>
```

Note: `sr-only` is a Tailwind utility that visually hides the link but keeps it accessible to screen readers. `focus:not-sr-only` reveals it when focused via keyboard. This does NOT change the visual design for sighted users.

- [ ] **Step 2: Build and verify**

Run: `hugo server`
Expected: Site looks identical visually. Tab key reveals "Skip to content" link. View source confirms `<main id="main-content">`.

- [ ] **Step 3: Commit**

```bash
git add layouts/_default/baseof.html
git commit -m "fix: add main landmark and skip-to-content link for accessibility"
```

---

### Task 3: Fix generic "link" text in favorites shortcode

**Files:**
- Modify: `layouts/shortcodes/favorites.html:70`

- [ ] **Step 1: Edit favorites.html line 70**

Change:
```html
{{ if $item.url }} - <a href="{{ $item.url }}">link</a>{{ end }}
```
to:
```html
{{ if $item.url }} - <a href="{{ $item.url }}">{{ $item.name }}</a>{{ end }}
```

**Accepted minor visual change:** This shows the restaurant/bar name instead of the word "link". The layout structure doesn't change, but the link text will be different. This is an intentional improvement for both accessibility and usability.

- [ ] **Step 2: Build and verify**

Run: `hugo server`
Expected: Each favorites entry now shows the place name as the link text instead of "link".

- [ ] **Step 3: Commit**

```bash
git add layouts/shortcodes/favorites.html
git commit -m "fix: use place name instead of generic 'link' text for accessibility"
```

---

### Task 4: Add aria-labels to map markers and map container

**Files:**
- Modify: `layouts/shortcodes/map.html:54,82-93,98,115`

- [ ] **Step 1: Add aria-label to map container**

Change line 54 from:
```html
<div id="map"></div>
```
to:
```html
<div id="map" role="application" aria-label="Interactive map of recommended Chicago places"></div>
```

- [ ] **Step 2: Add aria-label to map markers**

Replace the `createIcon` function (lines 82-93) with:

```javascript
function createIcon(type, isFriend, name) {
    var color = getColor(type);
    var size = isFriend ? 12 : 10;
    var border = isFriend ? '3px solid gold' : '2px solid white';

    return L.divIcon({
        className: 'custom-marker',
        html: '<div style="background-color: ' + color + '; width: ' + size + 'px; height: ' + size + 'px; border-radius: 50%; border: ' + border + '; box-shadow: 0 2px 4px rgba(0,0,0,0.3);" role="img" aria-label="' + name + '"></div>',
        iconSize: [size + 6, size + 6],
        iconAnchor: [(size + 6) / 2, (size + 6) / 2]
    });
}
```

- [ ] **Step 3: Update createIcon call to pass name**

Change line 98 from:
```javascript
var icon = createIcon(place.type, place.friends);
```
to:
```javascript
var icon = createIcon(place.type, place.friends, place.name);
```

- [ ] **Step 4: Add `rel="noopener noreferrer"` to popup links**

Change line 115 from:
```javascript
popupContent += ' <a href="' + place.url + '" target="_blank">↗</a>';
```
to:
```javascript
popupContent += ' <a href="' + place.url + '" target="_blank" rel="noopener noreferrer">↗</a>';
```

- [ ] **Step 5: Add "attraction" to typeColors and legend**

Add to typeColors object (after line 75):
```javascript
'attraction': '#16a085'
```

Add to legend div (insert before line 51, before the `⭐ = Friends` entry):
```html
<span>🏛️ Attraction</span>
```

- [ ] **Step 6: Add aria-label to nav in favorites shortcode**

In `layouts/shortcodes/favorites.html`, change line 17 from:
```html
<nav style="margin-bottom: 2rem; padding: 1rem; background: #f5f5f5; border-radius: 4px;">
```
to:
```html
<nav aria-label="Category navigation" style="margin-bottom: 2rem; padding: 1rem; background: #f5f5f5; border-radius: 4px;">
```

- [ ] **Step 7: Build and verify**

Run: `hugo server`
Expected: Map looks identical. Inspect markers in devtools to confirm `aria-label` attributes. Legend now includes Attraction.

- [ ] **Step 8: Commit**

```bash
git add layouts/shortcodes/map.html layouts/shortcodes/favorites.html
git commit -m "fix: add aria-labels to map markers, container, and nav for accessibility"
```

---

### Task 5: Fix Twitter card and OG image tags

**Files:**
- Modify: `layouts/partials/head/opengraph.html`

- [ ] **Step 1: Edit opengraph.html**

Replace the full file content (after the ABOUTME comments) with:

```html
{{/* ABOUTME: OpenGraph and Twitter Card meta tags for social sharing previews */}}
{{/* ABOUTME: Uses site params for description and dynamic baseURL for all URLs */}}

{{ $description := .Site.Params.description }}
{{ $title := .Site.Title }}
{{ $baseURL := .Site.BaseURL | strings.TrimSuffix "/" }}

<link rel="me" href="https://twitter.com/{{ .Site.Params.twitter }}">

<!-- Facebook Meta Tags -->
<meta property="og:url" content="{{ $baseURL }}">
<meta property="og:type" content="website">
<meta property="og:title" content="{{ $title }}">
<meta property="og:description" content="{{ $description }}">
<meta property="og:image" content="{{ $baseURL }}/og.jpg">
<meta property="og:image:width" content="1200">
<meta property="og:image:height" content="630">
<meta property="og:image:type" content="image/jpeg">
<meta property="og:image:alt" content="{{ $title }}">
<meta property="og:video" content="{{ $baseURL }}/og.mp4">
<meta property="og:video:secure_url" content="{{ $baseURL }}/og.mp4">
<meta property="og:video:type" content="video/mp4">
<meta property="og:video:width" content="1280">
<meta property="og:video:height" content="720">

<!-- Twitter Meta Tags -->
<meta name="twitter:card" content="summary_large_image">
<meta property="twitter:domain" content="chicago.harperreed.com">
<meta property="twitter:url" content="{{ $baseURL }}">
<meta name="twitter:title" content="{{ $title }}">
<meta name="twitter:description" content="{{ $description }}">
<meta name="twitter:image" content="{{ $baseURL }}/og.jpg">
```

Changes: switched `twitter:card` from `player` to `summary_large_image`, removed broken `twitter:player` tags, added `og:image` dimension/type/alt tags, added `og:video:secure_url`.

- [ ] **Step 2: Build and verify**

Run: `hugo server`
Expected: No visual change. View source confirms updated meta tags.

- [ ] **Step 3: Commit**

```bash
git add layouts/partials/head/opengraph.html
git commit -m "fix: switch Twitter card to summary_large_image and add OG image dimensions"
```

---

### Task 6: Fix head.html (remove broken links, deprecated tags, broken RSS)

**Files:**
- Modify: `layouts/partials/head.html`

- [ ] **Step 1: Edit head.html**

Replace content with:

```html
  {{ block "head" . }}
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <link rel="icon" href="/favicon.ico">

    <title>{{ .Site.Title}}</title>

    <meta name="description" content="{{ .Site.Params.description }}">
    <meta name="author" content="Harper Reed">


    {{- partial "head/opengraph.html" . -}}

    {{- partial "head/javascript.html" . -}}

    {{- partial "head/css.html" . -}}

  {{ end }}
```

Changes: removed deprecated `X-UA-Compatible`, removed `rel="shortcut icon"` (now `rel="icon"`), removed 4 broken favicon/manifest links (apple-touch-icon, favicon-32x32, favicon-16x16, site.webmanifest), removed broken RSS `<link>` tag (RSS is disabled), removed email from meta author tag (reduces spam harvesting).

- [ ] **Step 2: Build and verify**

Run: `hugo server`
Expected: Site looks identical. No more 404 requests for missing favicon files. View source confirms cleaned up head.

- [ ] **Step 3: Commit**

```bash
git add layouts/partials/head.html
git commit -m "fix: remove broken favicon links, deprecated meta tags, and empty RSS link"
```

---

### Task 7: Fix footer (stray `</p>`, HTTP link, noopener on figure)

**Files:**
- Modify: `layouts/partials/footer.html:13-15`
- Modify: `layouts/shortcodes/figure.html:28`

- [ ] **Step 1: Fix footer.html**

Change lines 13-15 from:
```html
        legally restrict others from doing anything the license permits. <a
            href="http://creativecommons.org/licenses/by-nc/4.0/">Click here to view a copy of this license</a></p>
    </p>
```
to:
```html
        legally restrict others from doing anything the license permits. <a
            href="https://creativecommons.org/licenses/by-nc/4.0/">View the license</a></p>
```

This removes the stray `</p>`, upgrades to HTTPS, and improves the link text.

- [ ] **Step 2: Fix figure.html rel attribute**

Change line 28 from:
```html
      <a href="{{ $link }}" target="_blank" rel="noopener">
```
to:
```html
      <a href="{{ $link }}" target="_blank" rel="noopener noreferrer">
```

- [ ] **Step 3: Build and verify**

Run: `hugo server`
Expected: Footer looks identical. View source confirms single `</p>`, HTTPS link.

- [ ] **Step 4: Commit**

```bash
git add layouts/partials/footer.html layouts/shortcodes/figure.html
git commit -m "fix: remove stray </p>, upgrade CC link to HTTPS, add noreferrer to figure"
```

---

### Task 8: Fix content typos and grammar

**Files:**
- Modify: `content/_index.md:3,9,17,21`
- Modify: `data/favorites.yaml:5`
- Modify: `layouts/shortcodes/thanks.html:4`

- [ ] **Step 1: Fix _index.md**

Line 3 — change:
```
I have lived in Chicago for 25 years (or more) and everytime someone is like "I am in chicago where should i go??" i always fail to recommend good spots. So here is my running list of spots.
```
to:
```
I have lived in Chicago for 25 years (or more) and every time someone is like "I am in Chicago where should I go??" I always fail to recommend good spots. So here is my running list of spots.
```

Line 9 — change:
```
-[harper](mailto:harper@modest.com)
```
to:
```
- [harper](mailto:harper@modest.com)
```

Line 17 — change:
```
## Friend's Guides
```
to:
```
## Friends' Guides
```

Line 21 — change:
```
#### {{< thanks >}}
```
to:
```
### {{< thanks >}}
```
(Fixes heading hierarchy: h2 -> h3 instead of h2 -> h4)

- [ ] **Step 2: Fix favorites.yaml line 5**

Change:
```yaml
  description: "A really wonderful macanese restaruant. Super tasty. "
```
to:
```yaml
  description: "A really wonderful Macanese restaurant. Super tasty."
```

- [ ] **Step 3: Fix thanks.html**

Change line 4 — the last word from:
```
in chicago
```
to:
```
in Chicago
```

- [ ] **Step 4: Fix friends-guides.html ABOUTME comment**

Change line 1 from:
```
{{/* ABOUTME: Simple Hugo shortcode that outputs all friend's guides from data/friends-guides.yaml */}}
```
to:
```
{{/* ABOUTME: Simple Hugo shortcode that outputs all friends' guides from data/friends-guides.yaml */}}
```

- [ ] **Step 5: Build and verify**

Run: `hugo server`
Expected: Content reads correctly. Heading hierarchy is now h1 > h2 > h3 > h2 > h3.

- [ ] **Step 6: Commit**

```bash
git add content/_index.md data/favorites.yaml layouts/shortcodes/thanks.html layouts/shortcodes/friends-guides.html
git commit -m "fix: correct typos, grammar, heading hierarchy, and possessive"
```

---

### Task 9: Add security and cache headers to netlify.toml

**Files:**
- Modify: `netlify.toml`

- [ ] **Step 1: Edit netlify.toml**

Replace content with:

```toml
# ABOUTME: Netlify build configuration for Hugo site
# ABOUTME: Specifies Hugo version and build settings for deployment

[build]
  command = "hugo --minify"
  publish = "public"

[build.environment]
  HUGO_VERSION = "0.147.4"

[[headers]]
  for = "/*"
  [headers.values]
    X-Frame-Options = "DENY"
    X-Content-Type-Options = "nosniff"
    Referrer-Policy = "strict-origin-when-cross-origin"
    Permissions-Policy = "camera=(), microphone=(), geolocation=()"
    Content-Security-Policy = "default-src 'self'; script-src 'self' 'unsafe-inline' 'unsafe-eval' https://cdn.tailwindcss.com https://unpkg.com https://tinylytics.app; style-src 'self' 'unsafe-inline' https://unpkg.com; img-src 'self' https://*.tile.openstreetmap.org data:; connect-src 'self' https://tinylytics.app; font-src 'self'"

# Long-lived cache for fingerprinted assets
[[headers]]
  for = "/*.*.css"
  [headers.values]
    Cache-Control = "public, max-age=31536000, immutable"

[[headers]]
  for = "/*.*.js"
  [headers.values]
    Cache-Control = "public, max-age=31536000, immutable"

# Moderate cache for static assets
[[headers]]
  for = "/og.*"
  [headers.values]
    Cache-Control = "public, max-age=86400"

[[headers]]
  for = "/favicon.ico"
  [headers.values]
    Cache-Control = "public, max-age=604800"

# Custom 404
[[redirects]]
  from = "/*"
  to = "/404.html"
  status = 404
```

Changes: `hugo --minify` for minified output, security headers, cache headers for fingerprinted and static assets, custom 404 redirect.

- [ ] **Step 2: Enable 404 page in hugo.toml**

In `hugo.toml`, change line 5 from:
```toml
disableKinds = ["taxonomy", "RSS", "sitemap", "robotsTXT", "404"]
```
to:
```toml
disableKinds = ["taxonomy", "RSS", "sitemap", "robotsTXT"]
```

- [ ] **Step 3: Build and verify**

Run: `hugo --minify`
Expected: Build succeeds. Output is minified. 404.html is generated in `public/`.

- [ ] **Step 4: Commit**

```bash
git add netlify.toml hugo.toml
git commit -m "feat: add security headers, cache headers, minification, and enable 404 page"
```

---

### Task 10: Swap Tailwind CDN for build-time CSS

**Files:**
- Modify: `layouts/partials/head/css.html`
- Modify: `netlify.toml`
- Modify: `.gitignore`
- Create: `package.json`
- Create: `tailwind.config.js`
- Create: `assets/css/tailwind-input.css`

**IMPORTANT:** This task has the highest risk of changing the design. Test carefully.

**IMPORTANT:** Pin Tailwind to v3.x. Tailwind v4 (released 2025) uses a completely different config system (CSS-based, no `tailwind.config.js`, no `@tailwind` directives). The site uses v3-style classes and the v3 CDN play mode, so we must stay on v3 for a safe swap.

- [ ] **Step 1: Install Tailwind CSS v3 and plugins**

```bash
cd /Users/harper/Public/src/personal/chicago
npm init -y
npm install -D tailwindcss@3 @tailwindcss/typography @tailwindcss/forms @tailwindcss/aspect-ratio
```

The `@3` pin is critical — without it, npm will install Tailwind v4 which has an incompatible config format.

`line-clamp` is built into Tailwind core since v3.3, no separate plugin needed.

- [ ] **Step 2: Create tailwind.config.js**

```javascript
/** @type {import('tailwindcss').Config} */
module.exports = {
  content: [
    "./layouts/**/*.html",
    "./content/**/*.md",
  ],
  plugins: [
    require('@tailwindcss/typography'),
    require('@tailwindcss/forms'),
    require('@tailwindcss/aspect-ratio'),
  ],
}
```

- [ ] **Step 3: Create Tailwind input CSS file**

Create `assets/css/tailwind-input.css`:
```css
@tailwind base;
@tailwind components;
@tailwind utilities;
```

- [ ] **Step 4: Build Tailwind CSS locally and verify it generates output**

```bash
npx tailwindcss -i ./assets/css/tailwind-input.css -o ./assets/css/tailwind-output.css --minify
```

Expected: File `assets/css/tailwind-output.css` is created. It should contain the prose, container, and other utility classes used in the templates. Check the file size — it should be roughly 5-30KB (not 0 and not 500KB+).

- [ ] **Step 5: Update css.html partial**

Replace the entire content of `layouts/partials/head/css.html` with:

```html
{{ $tailwind := resources.Get "css/tailwind-output.css" }}
{{ $custom := resources.Get "css/main.css" }}
{{ $combined := slice $tailwind $custom | resources.Concat "css/bundle.css" | resources.Fingerprint }}
<link rel="stylesheet" href="{{ $combined.RelPermalink }}" integrity="{{ $combined.Data.Integrity }}" crossorigin="anonymous">
```

This removes the Tailwind CDN `<script>` tag and replaces it with the build-time compiled CSS bundled with the custom CSS.

- [ ] **Step 6: Update netlify.toml build command**

Change the build command to compile Tailwind before Hugo:
```toml
[build]
  command = "npm install && npx tailwindcss -i ./assets/css/tailwind-input.css -o ./assets/css/tailwind-output.css --minify && hugo --minify"
```

- [ ] **Step 7: Update CSP in netlify.toml**

Remove `https://cdn.tailwindcss.com` and `'unsafe-eval'` from the `script-src` directive in the CSP header since we no longer load Tailwind from CDN.

Updated CSP:
```
Content-Security-Policy = "default-src 'self'; script-src 'self' 'unsafe-inline' https://unpkg.com https://tinylytics.app; style-src 'self' 'unsafe-inline' https://unpkg.com; img-src 'self' https://*.tile.openstreetmap.org data:; connect-src 'self' https://tinylytics.app; font-src 'self'"
```

- [ ] **Step 8: Build and verify CAREFULLY**

```bash
hugo server
```

Expected: Site looks **identical** to the current design. Compare carefully:
- Typography (prose classes still working — this is the #1 risk area)
- Link colors (blue, green on hover)
- Container width and padding
- Map styling
- Footer layout
- Jump-to nav background

If ANYTHING looks different, stop and debug before committing. The Tailwind CDN play mode includes ALL utilities — the build-time version only includes utilities actually used in templates. If a class is missing, add it to `tailwind.config.js` safelist:

```javascript
module.exports = {
  // ...existing config...
  safelist: ['sr-only', 'missing-class-name-here'],
}
```

- [ ] **Step 9: Add tailwind-output.css to .gitignore and commit**

```bash
echo "assets/css/tailwind-output.css" >> .gitignore
git add .gitignore package.json package-lock.json tailwind.config.js assets/css/tailwind-input.css layouts/partials/head/css.html netlify.toml
git commit -m "feat: replace Tailwind CDN with build-time CSS compilation (pinned to v3)"
```

---

### Task 11: Add Leaflet `defer` for non-blocking load

**Files:**
- Modify: `layouts/shortcodes/map.html:4-5`

- [ ] **Step 1: Defer Leaflet script loading**

This is tricky because the map init script runs immediately after the Leaflet script tag. We need to move the map initialization to a DOMContentLoaded callback.

Change lines 4-5 from:
```html
<link rel="stylesheet" href="https://unpkg.com/leaflet@1.9.4/dist/leaflet.css" integrity="sha256-p4NxAoJBhIIN+hmNHrzRCf9tD/miZyoHS5obTRR9BMY=" crossorigin="" />
<script src="https://unpkg.com/leaflet@1.9.4/dist/leaflet.js" integrity="sha256-20nQCchB9co0qIjJZRGuk2/Z9VM+kNiyxNV1lvTlZBo=" crossorigin=""></script>
```
to:
```html
<link rel="stylesheet" href="https://unpkg.com/leaflet@1.9.4/dist/leaflet.css" integrity="sha256-p4NxAoJBhIIN+hmNHrzRCf9tD/miZyoHS5obTRR9BMY=" crossorigin="" />
<script src="https://unpkg.com/leaflet@1.9.4/dist/leaflet.js" integrity="sha256-20nQCchB9co0qIjJZRGuk2/Z9VM+kNiyxNV1lvTlZBo=" crossorigin="" defer></script>
```

Then change the map init script (line 56-123) to wrap in DOMContentLoaded:

Change line 57 from:
```javascript
(function() {
```
to:
```javascript
document.addEventListener('DOMContentLoaded', function() {
```

And line 123 from:
```javascript
})();
```
to:
```javascript
});
```

- [ ] **Step 2: Build and verify**

Run: `hugo server`
Expected: Map still renders correctly. Content below the map appears faster.

- [ ] **Step 3: Commit**

```bash
git add layouts/shortcodes/map.html
git commit -m "perf: defer Leaflet loading to unblock page rendering"
```

---

### Task 12: Bump map legend font size to prevent iOS zoom

**Files:**
- Modify: `layouts/shortcodes/map.html:15,19,34`

**Accepted minor visual change:** Map popup and legend text will be slightly larger (14/15px -> 16px). This is an intentional deviation to prevent iOS Safari from auto-zooming when users interact with the map. The layout structure is unchanged.

- [ ] **Step 1: Update font sizes in map styles**

Change the `.leaflet-popup-content` font-size from `14px` to `16px` (line 15).
Change the `.leaflet-popup-content strong` font-size from `15px` to `16px` (line 19).
Change the `.map-legend` font-size from `14px` to `16px` (line 34).

- [ ] **Step 2: Build and verify**

Run: `hugo server`
Expected: Map popups and legend text are slightly larger. No layout breakage.

- [ ] **Step 3: Commit**

```bash
git add layouts/shortcodes/map.html
git commit -m "fix: bump map font sizes to 16px to prevent iOS auto-zoom"
```

---

## Task Summary

| Task | Category | Severity | Risk to Design |
|------|----------|----------|----------------|
| 1. `lang="en"` | A11y/Standards | Critical | None |
| 2. `<main>` + skip link | A11y | Critical | None |
| 3. Fix "link" text | A11y | Critical | Minimal (shows place names) |
| 4. Map aria-labels + legend | A11y/Standards | Critical | None (attraction gets color) |
| 5. Twitter card + OG tags | Social/Meta | Critical | None |
| 6. Clean head.html | Standards/Meta | Critical | None |
| 7. Footer + figure fixes | Standards/Security | Important | None |
| 8. Content typos | Copy | Critical+Important | None |
| 9. Netlify headers + 404 | Security/Performance | Important | None |
| 10. Tailwind build-time | Performance | Critical | **HIGH — test carefully** |
| 11. Defer Leaflet | Performance | Important | None |
| 12. Map font sizes | Mobile UX | Important | Minimal (slightly larger text) |

**Recommended order:** Tasks 1-9 first (low risk), then Task 10 (high risk, test carefully), then 11-12.
