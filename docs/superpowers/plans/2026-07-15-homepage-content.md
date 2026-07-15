# Homepage Content Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace the full-screen profile card with a content-led homepage containing a profile introduction, About text, three recent posts, education, and a single C++ skill.

**Architecture:** Keep Jekyll's existing page and layout structure. `index.md` owns homepage content and obtains recent posts from `site.posts`; `assets/css/style.scss` owns all presentation and responsive behavior; a focused PowerShell source-contract check provides repeatable local verification without requiring Ruby.

**Tech Stack:** Jekyll, Liquid, Markdown/HTML, SCSS, PowerShell, headless Microsoft Edge for visual inspection.

---

## File Map

- Create `scripts/check-homepage.ps1`: repeatable source-level contract checks for homepage structure and styling.
- Modify `index.md`: semantic homepage sections and Liquid recent-post loop.
- Modify `assets/css/style.scss`: vertical homepage layout, section rhythm, recent-post rows, education, skills, and mobile adjustments.
- Keep `_layouts/default.html`, `_layouts/post.html`, `about.md`, and `archive.md` unchanged.

### Task 1: Homepage Content And Dynamic Posts

**Files:**
- Create: `scripts/check-homepage.ps1`
- Modify: `index.md`
- Test: `scripts/check-homepage.ps1`

- [ ] **Step 1: Write the failing homepage content check**

Create `scripts/check-homepage.ps1` with:

```powershell
$ErrorActionPreference = "Stop"

$projectRoot = Split-Path -Parent $PSScriptRoot
$indexPath = Join-Path $projectRoot "index.md"
$index = Get-Content -Raw -Encoding utf8 $indexPath

function Assert-Contains {
    param(
        [string]$Content,
        [string]$Expected,
        [string]$Message
    )

    if (-not $Content.Contains($Expected)) {
        throw $Message
    }
}

function Assert-NotContains {
    param(
        [string]$Content,
        [string]$Unexpected,
        [string]$Message
    )

    if ($Content.Contains($Unexpected)) {
        throw $Message
    }
}

Assert-Contains $index '<div class="home-page">' "Homepage wrapper is missing."
Assert-Contains $index '<section class="profile-intro"' "Profile introduction is missing."
Assert-Contains $index 'id="about"' "About section is missing."
Assert-Contains $index 'id="recent-posts"' "Recent posts section is missing."
Assert-Contains $index 'id="education"' "Education section is missing."
Assert-Contains $index 'id="skills"' "Skills section is missing."
Assert-Contains $index '{% for post in site.posts limit: 3 %}' "Recent posts must use a three-post Jekyll loop."
Assert-Contains $index '{{ post.url | relative_url }}' "Post links must respect Jekyll base URLs."
Assert-Contains $index "北京大学信息科学技术学院" "Education content is missing."
Assert-Contains $index "C++" "C++ skill is missing."
Assert-NotContains $index 'id="typewriter"' "Typewriter markup must be removed."
Assert-NotContains $index 'setTimeout(type' "Typewriter JavaScript must be removed."

Write-Output "PASS: homepage content contract"
```

- [ ] **Step 2: Run the check and verify it fails for the missing homepage wrapper**

Run:

```powershell
pwsh -NoProfile -File scripts/check-homepage.ps1
```

Expected: exit code `1` with `Homepage wrapper is missing.`

- [ ] **Step 3: Replace the profile card in `index.md` with the semantic homepage**

Use this complete page body after the existing front matter:

```html
<div class="home-page">
    <section class="profile-intro" aria-labelledby="profile-name">
        <img src="{{ '/assets/images/avatar.jpg' | relative_url }}" alt="Percival 的头像" class="avatar">
        <h1 id="profile-name">Percival</h1>
        <p class="profile-role">开发者 / 创作者 / 终身学习者</p>
        <div class="profile-meta" aria-label="个人信息">
            <span>北京</span>
            <span aria-hidden="true">/</span>
            <a href="https://github.com/percival-06" target="_blank" rel="noopener noreferrer">GitHub</a>
        </div>
    </section>

    <section class="home-section" id="about" aria-labelledby="about-title">
        <h2 id="about-title">关于</h2>
        <div class="home-prose">
            <p>Hi，我是 Percival，北京大学信息科学技术学院 2025 级本科生。</p>
            <p>在这里记录学习、技术与生活中的思考。</p>
        </div>
    </section>

    <section class="home-section" id="recent-posts" aria-labelledby="recent-posts-title">
        <div class="home-section-heading">
            <h2 id="recent-posts-title">最近文章</h2>
            <a href="{{ '/archive/' | relative_url }}">查看全部</a>
        </div>
        <ul class="home-post-list">
            {% for post in site.posts limit: 3 %}
            <li>
                <a class="home-post-link" href="{{ post.url | relative_url }}">
                    <time datetime="{{ post.date | date_to_xmlschema }}">{{ post.date | date: "%Y-%m-%d" }}</time>
                    <span>{{ post.title }}</span>
                </a>
            </li>
            {% endfor %}
        </ul>
    </section>

    <section class="home-section" id="education" aria-labelledby="education-title">
        <h2 id="education-title">教育经历</h2>
        <div class="education-item">
            <div>
                <strong>北京大学</strong>
                <p>信息科学技术学院 · 本科生</p>
            </div>
            <span>2025 - 至今</span>
        </div>
    </section>

    <section class="home-section" id="skills" aria-labelledby="skills-title">
        <h2 id="skills-title">技能</h2>
        <ul class="skill-list">
            <li>C++</li>
        </ul>
    </section>

    <footer class="home-footer">© {{ site.time | date: "%Y" }} {{ site.title }}</footer>
</div>
```

- [ ] **Step 4: Run the homepage content check and verify it passes**

Run:

```powershell
pwsh -NoProfile -File scripts/check-homepage.ps1
```

Expected: exit code `0` and `PASS: homepage content contract`.

- [ ] **Step 5: Commit the content and test together**

```powershell
git add -- index.md scripts/check-homepage.ps1
git commit -m "feat: add homepage content sections"
```

### Task 2: Homepage Layout And Responsive Styling

**Files:**
- Modify: `scripts/check-homepage.ps1`
- Modify: `assets/css/style.scss`
- Test: `scripts/check-homepage.ps1`

- [ ] **Step 1: Extend the check with the homepage style contract**

Add after the existing `$index` assignment:

```powershell
$stylePath = Join-Path $projectRoot "assets/css/style.scss"
$style = Get-Content -Raw -Encoding utf8 $stylePath
```

Add before the final `Write-Output`:

```powershell
Assert-Contains $style ".home-page" "Homepage page-shell styles are missing."
Assert-Contains $style ".profile-intro" "Profile introduction styles are missing."
Assert-Contains $style ".home-section" "Homepage section styles are missing."
Assert-Contains $style ".home-post-link" "Recent-post row styles are missing."
Assert-Contains $style ".education-item" "Education styles are missing."
Assert-Contains $style ".skill-list" "Skill styles are missing."
Assert-Contains $style "@media (prefers-reduced-motion: reduce)" "Reduced-motion support must remain available."
Assert-NotContains $style ".typewriter-text" "Legacy typewriter styles must be removed."
Assert-NotContains $style "@keyframes blink" "Legacy cursor animation must be removed."
```

- [ ] **Step 2: Run the check and verify it fails for the missing `.home-page` styles**

Run:

```powershell
pwsh -NoProfile -File scripts/check-homepage.ps1
```

Expected: exit code `1` with `Homepage page-shell styles are missing.`

- [ ] **Step 3: Replace the legacy homepage, typewriter, tagline, and minimal-footer style blocks**

Remove `.home-layout`, `.home-layout h1`, `.typewriter-text`, `.cursor`, `.tagline`, `.minimal-nav`, `.minimal-footer`, and `@keyframes blink`. Add:

```scss
.home-page {
  width: min(100%, 720px);
  margin: 0 auto;
  padding: 3rem 1.5rem 2.5rem;
  animation: fade-in-up 320ms ease both;
}

.profile-intro {
  display: flex;
  min-height: min(58vh, 32rem);
  padding: 2rem 0 3.5rem;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  text-align: center;
}

.profile-intro h1 {
  margin-bottom: 0.5rem;
  font-size: 2.5rem;
  font-weight: 700;
  letter-spacing: 0;
  line-height: 1.2;
}

.profile-role {
  color: var(--muted-foreground);
  font-size: 1rem;
}

.profile-meta {
  display: flex;
  margin-top: 0.75rem;
  align-items: center;
  justify-content: center;
  gap: 0.625rem;
  color: var(--muted-foreground);
  font-size: 0.875rem;
}

.profile-meta a {
  text-decoration: none;
  transition: color 160ms ease;
}

.profile-meta a:hover {
  color: var(--primary);
}

.home-section {
  padding: 2.75rem 0;
  border-top: 1px solid var(--border);
}

.home-section h2 {
  font-size: 1.25rem;
  font-weight: 700;
  letter-spacing: 0;
  line-height: 1.4;
}

.home-section-heading {
  display: flex;
  align-items: baseline;
  justify-content: space-between;
  gap: 1rem;
}

.home-section-heading a {
  color: var(--muted-foreground);
  font-size: 0.875rem;
  text-decoration: none;
  transition: color 160ms ease;
}

.home-section-heading a:hover {
  color: var(--primary);
}

.home-prose {
  margin-top: 1rem;
  color: var(--muted-foreground);
}

.home-prose p + p {
  margin-top: 0.5rem;
}

.home-post-list {
  margin-top: 1rem;
  list-style: none;
}

.home-post-list li + li {
  border-top: 1px solid var(--border);
}

.home-post-link {
  display: grid;
  min-height: 3.25rem;
  padding: 0.75rem 0;
  grid-template-columns: 7rem minmax(0, 1fr);
  align-items: baseline;
  gap: 1rem;
  text-decoration: none;
}

.home-post-link time {
  color: var(--muted-foreground);
  font-size: 0.8rem;
  white-space: nowrap;
}

.home-post-link span {
  min-width: 0;
  font-weight: 550;
  overflow-wrap: anywhere;
  transition: color 160ms ease;
}

.home-post-link:hover span {
  color: var(--primary);
}

.education-item {
  display: flex;
  margin-top: 1rem;
  align-items: flex-start;
  justify-content: space-between;
  gap: 1.5rem;
}

.education-item strong {
  font-weight: 650;
}

.education-item p,
.education-item > span {
  color: var(--muted-foreground);
  font-size: 0.875rem;
}

.education-item > span {
  flex: 0 0 auto;
}

.skill-list {
  margin-top: 1rem;
  list-style: none;
}

.skill-list li {
  font-weight: 550;
}

.home-footer {
  padding-top: 2.5rem;
  border-top: 1px solid var(--border);
  color: var(--muted-foreground);
  font-size: 0.8rem;
  text-align: center;
}
```

The page and every section remain a single content column; only each recent-post row uses a two-column date/title grid on wider screens.

Keep the existing `.avatar` block, changing only `margin-bottom` to `1.25rem` if necessary for the new profile rhythm.

- [ ] **Step 4: Replace the mobile homepage rules inside `@media (max-width: 560px)`**

Remove the old `.home-layout` and `.home-layout h1` rules and add:

```scss
  .home-page {
    padding: 2rem 1.25rem 2rem;
  }

  .profile-intro {
    min-height: 54vh;
    padding: 1.5rem 0 3rem;
  }

  .profile-intro h1 {
    font-size: 2.125rem;
  }

  .home-section {
    padding: 2.25rem 0;
  }

  .home-post-link {
    grid-template-columns: 1fr;
    gap: 0.2rem;
  }

  .education-item {
    flex-direction: column;
    gap: 0.35rem;
  }
```

- [ ] **Step 5: Run the complete homepage check and verify it passes**

Run:

```powershell
pwsh -NoProfile -File scripts/check-homepage.ps1
```

Expected: exit code `0` and `PASS: homepage content contract`.

- [ ] **Step 6: Commit the responsive presentation changes**

```powershell
git add -- assets/css/style.scss scripts/check-homepage.ps1
git commit -m "style: add content-led homepage layout"
```

### Task 3: Build And Visual Verification

**Files:**
- Verify: `index.md`
- Verify: `assets/css/style.scss`
- Verify: `scripts/check-homepage.ps1`

- [ ] **Step 1: Run fresh automated checks**

```powershell
pwsh -NoProfile -File scripts/check-homepage.ps1
git diff --check
git status --short
```

Expected: homepage contract passes, `git diff --check` exits `0`, and no uncommitted implementation files remain.

- [ ] **Step 2: Attempt the production Jekyll build without installing dependencies**

```powershell
Get-Command jekyll -ErrorAction SilentlyContinue
```

If Jekyll is available, run:

```powershell
jekyll build
```

Expected: exit code `0`. If the command is absent, record the build as not run because Ruby/Jekyll is unavailable.

- [ ] **Step 3: Render desktop and mobile previews**

Use the temporary preview harness at:

```text
C:\Users\JYH\.codex\visualizations\2026\06\11\019eb583-905b-7160-9e42-db81420dbf97\preview-check.mjs
```

Before its generic Liquid-tag removal, add this exact transformation so the preview renders real post rows:

```javascript
.replace(/{% for post in site\.posts limit: 3 %}[\s\S]*?{% endfor %}/, `
  <li><a class="home-post-link" href="#"><time datetime="2026-02-16">2026-02-16</time><span>2025年终总结</span></a></li>
  <li><a class="home-post-link" href="#"><time datetime="2026-02-09">2026-02-09</time><span>大一上小结</span></a></li>
  <li><a class="home-post-link" href="#"><time datetime="2026-02-05">2026-02-05</time><span>第一篇</span></a></li>
`)
```

Start the temporary server with:

```powershell
& 'C:\Users\JYH\.cache\codex-runtimes\codex-primary-runtime\dependencies\node\bin\node.exe' 'C:\Users\JYH\.codex\visualizations\2026\06\11\019eb583-905b-7160-9e42-db81420dbf97\preview-check.mjs'
```

Render desktop and mobile captures with headless Edge:

```powershell
& 'C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe' --headless=new --disable-gpu --hide-scrollbars --virtual-time-budget=750 --window-size=1440,900 --screenshot='C:\Users\JYH\.codex\visualizations\2026\06\11\019eb583-905b-7160-9e42-db81420dbf97\homepage-desktop.png' http://127.0.0.1:4178
```

```powershell
& 'C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe' --headless=new --disable-gpu --hide-scrollbars --virtual-time-budget=750 --force-device-scale-factor=2 --window-size=750,1624 --screenshot='C:\Users\JYH\.codex\visualizations\2026\06\11\019eb583-905b-7160-9e42-db81420dbf97\homepage-mobile.png' http://127.0.0.1:4178
```

These commands inspect:

```text
1440 x 900
375 x 812 CSS pixels (rendered at device scale factor 2)
```

Wait at least 500 milliseconds before capture so `fade-in-up` has completed.

- [ ] **Step 4: Inspect the rendered result**

Confirm all of the following:

```text
The top navigation does not overflow.
The profile area leaves the About heading visible in the first viewport.
The three newest post titles and dates appear in descending order.
Education dates do not collide with the school name.
C++ appears as the only skill.
No content overlaps at desktop or mobile width.
Foreground and muted text remain readable in both theme variable sets.
```

- [ ] **Step 5: Report verification evidence and residual limitations**

Include the contract-check result, `git diff --check` result, visual viewports inspected, and whether a production Jekyll build was available. Do not claim the build passed if the tool was absent.
