# Writing-First Homepage Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Turn the existing Jekyll homepage into a writing-first personal blog with a compact profile, an editorial five-post list, and education and skills consolidated on the About page.

**Architecture:** Keep the existing static Jekyll structure and use Liquid to render posts directly from `site.posts`. Page files own semantic content, post front matter owns homepage descriptions, the default layout owns global navigation/theme behavior, the SCSS file owns the visual system, and the existing PowerShell source-contract script provides repeatable tests without requiring Ruby.

**Tech Stack:** Jekyll, Liquid, Markdown/HTML, SCSS, vanilla JavaScript, PowerShell, optional local Ruby/Jekyll, headless Microsoft Edge.

## Global Constraints

- Preserve the existing centered circular avatar as a prominent homepage identity element.
- At a 1440 × 900 viewport, the recent-writing heading and at least the first article row must be visible without scrolling.
- Render no more than the five newest posts from `site.posts`.
- Resolve descriptions as `post.description`, then `post.excerpt | strip_html | strip_newlines | truncate: 72`, then no description.
- Move education and skills to About; do not add projects, status widgets, or invented credentials.
- Keep the existing low-saturation blue-gray accent, light/dark themes, keyboard focus, and `prefers-reduced-motion` behavior.
- Use `relative_url` for internal links and assets, escape post titles, and retain safe external-link attributes.
- Add no framework, CSS framework, remote font, CMS, client-side article loader, or new runtime dependency.

---

## File Map

- Modify `scripts/check-homepage.ps1`: source-level contracts for homepage content, description fallback, About migration, global navigation, and editorial styling.
- Modify `index.md`: compact profile introduction, short writing statement, and five-post editorial list.
- Modify `about.md`: education, motto, C++ skill, and existing contact details.
- Modify `_posts/2026-02-05-第一篇.md`: add the approved homepage description.
- Modify `_posts/2026-02-09-大一上小结.md`: add the approved homepage description.
- Modify `_posts/2026-02-16-2025年终总结.md`: add the approved homepage description.
- Modify `_posts/2026-07-15-大一下小结.md`: normalize the title and add the approved homepage description.
- Modify `_layouts/default.html`: flatter global navigation labels and existing theme behavior.
- Modify `_layouts/post.html`: base-URL-safe archive return link.
- Modify `archive.md`: base-URL-safe links and escaped post titles.
- Modify `assets/css/style.scss`: editorial type system, compact profile, post-list hierarchy, responsive behavior, and About education styling.
- Verify all page types after the shared style and internal-link changes.

## Task 1: Define The New Content Contract

**Files:**
- Modify: `scripts/check-homepage.ps1`
- Test: `scripts/check-homepage.ps1`

**Interfaces:**
- Consumes: current source files as UTF-8 text.
- Produces: a failing contract that Task 2 satisfies; existing helper functions `Assert-Contains`, `Assert-NotContains`, `Assert-Matches`, `Assert-NotMatches`, `Get-SectionByClass`, and `Get-SectionById` remain unchanged.

- [ ] **Step 1: Load About and current post sources in the contract script**

Add immediately after the existing config load:

```powershell
$aboutPath = Join-Path $projectRoot "about.md"
$about = Get-Content -Raw -Encoding utf8 $aboutPath
$archivePath = Join-Path $projectRoot "archive.md"
$archive = Get-Content -Raw -Encoding utf8 $archivePath
$postLayoutPath = Join-Path $projectRoot "_layouts/post.html"
$postLayout = Get-Content -Raw -Encoding utf8 $postLayoutPath

$postExpectations = @(
    @{
        File = "2026-07-15-大一下小结.md"
        Title = "title: \"大一下小结\""
        Description = "description: \"回顾大一下学期，也为接下来的学习做一个简单总结。\""
    },
    @{
        File = "2026-02-16-2025年终总结.md"
        Title = "title: \"2025年终总结\""
        Description = "description: \"回顾高考、暑假与大学新生活，并为新一年梳理方向。\""
    },
    @{
        File = "2026-02-09-大一上小结.md"
        Title = "title: \"大一上小结\""
        Description = "description: \"回顾从高中到大学的适应、学习方法与对差距的重新认识。\""
    },
    @{
        File = "2026-02-05-第一篇.md"
        Title = "title: \"第一篇\""
        Description = "description: \"博客的开场：记录学习、技术与生活，并持续分享随笔与心得。\""
    }
)
```

- [ ] **Step 2: Replace the old homepage-section assertions with the writing-first assertions**

Keep avatar, identity, GitHub, typewriter-removal, and helper assertions. Replace checks that require `#education`, `#skills`, the three-post loop, and the old post-row body with:

```powershell
$profile = Get-SectionByClass $index 'profile-intro'
Assert-Matches $profile '<img\b(?=[^>]*\bsrc\s*=\s*["'']{{\s*''/assets/images/avatar\.jpg''\s*\|\s*relative_url\s*}}["''])(?=[^>]*\balt\s*=\s*["'']Percival 的头像["''])[^>]*>' "Profile avatar is missing or invalid."
Assert-Matches $profile '<h1\b[^>]*\bid\s*=\s*["'']profile-name["''][^>]*>\s*Percival\s*</h1>' "Profile name is missing."
Assert-Contains $profile '开发者 / 创作者 / 终身学习者' "Profile role is missing."
Assert-Contains $profile '北京' "Profile location is missing."
Assert-Matches $profile '<a\b(?=[^>]*href\s*=\s*["'']https://github\.com/percival-06["''])(?=[^>]*target\s*=\s*["'']_blank["''])(?=[^>]*rel\s*=\s*["'']noopener noreferrer["''])[^>]*>\s*GitHub\s*</a>' "Profile GitHub link is missing safe external-link attributes."

$intro = Get-SectionById $index 'intro'
Assert-Contains $intro '北京大学信息科学技术学院 2025 级本科生' "Homepage identity introduction is missing."
Assert-Contains $intro '记录计算机学习、校园生活，以及沿途真实发生的思考。' "Homepage writing statement is missing."

$recentPosts = Get-SectionById $index 'recent-posts'
Assert-Matches $recentPosts '<h2\b[^>]*>\s*最近文章\s*</h2>' "Recent posts heading is missing."
Assert-Matches $recentPosts '<a\b(?=[^>]*\bhref\s*=\s*["'']{{\s*''/archive/''\s*\|\s*relative_url\s*}}["''])(?=[^>]*\baria-label\s*=\s*["'']查看全部文章["''])[^>]*>\s*查看全部\s*</a>' "Archive link is missing or unsafe."

$loopPattern = '{%-?\s*for\s+post\s+in\s+site\.posts\s+limit\s*:\s*5\s*-?%}(?<Body>.*?){%-?\s*endfor\s*-?%}'
$loopMatch = [regex]::Match($recentPosts, $loopPattern, $regexOptions)
if (-not $loopMatch.Success) {
    throw "Recent posts must use a five-post Jekyll loop."
}

$loopBody = $loopMatch.Groups['Body'].Value
Assert-Matches $loopBody 'href\s*=\s*["'']{{\s*post\.url\s*\|\s*relative_url\s*}}["'']' "Post links must respect Jekyll base URLs."
Assert-Matches $loopBody 'datetime\s*=\s*["'']{{\s*post\.date\s*\|\s*date_to_xmlschema\s*}}["'']' "Post datetime must use date_to_xmlschema."
Assert-Matches $loopBody '{{\s*post\.title\s*\|\s*escape\s*}}' "Post titles must be escaped."
Assert-Matches $loopBody '{%\s*assign\s+excerpt_description\s*=\s*post\.excerpt\s*\|\s*strip_html\s*\|\s*strip_newlines\s*\|\s*truncate:\s*72\s*%}' "Post excerpt fallback must use the approved cleanup filters."
Assert-Matches $loopBody '{%\s*if\s+post\.description\s*%}.*?{{\s*post\.description\s*\|\s*escape\s*}}.*?{%\s*elsif\s+excerpt_description\s*!=\s*empty\s*%}.*?{{\s*excerpt_description\s*\|\s*escape\s*}}.*?{%\s*endif\s*%}' "Post descriptions must prefer front matter, fall back to a non-empty excerpt, and omit empty descriptions."

Assert-NotMatches $index '<section\b[^>]*\bid\s*=\s*["'']education["'']' "Education must move off the homepage."
Assert-NotMatches $index '<section\b[^>]*\bid\s*=\s*["'']skills["'']' "Skills must move off the homepage."
```

- [ ] **Step 3: Add About and post-front-matter assertions**

Add after the homepage assertions:

```powershell
Assert-Contains $about '北京大学' "About education institution is missing."
Assert-Contains $about '信息科学技术学院 · 本科生' "About education program is missing."
Assert-Contains $about '2025 - 至今' "About education dates are missing."
Assert-Matches $about '<h2\b[^>]*>\s*技能\s*</h2>.*?<li\b[^>]*>\s*C\+\+\s*</li>' "About must retain the C++ skill."
Assert-Contains $about 'Keep calm and carry on' "About motto is missing."
Assert-Contains $about '66265381@qq.com' "About email is missing."

foreach ($expectation in $postExpectations) {
    $postPath = Join-Path (Join-Path $projectRoot "_posts") $expectation.File
    $post = Get-Content -Raw -Encoding utf8 $postPath
    Assert-Contains $post $expectation.Title "Expected title is missing from $($expectation.File)."
    Assert-Contains $post $expectation.Description "Expected description is missing from $($expectation.File)."
}

Assert-Matches $archive 'href\s*=\s*["'']{{\s*''/''\s*\|\s*relative_url\s*}}["'']' "Archive back link must respect Jekyll base URLs."
Assert-Matches $archive 'href\s*=\s*["'']{{\s*post\.url\s*\|\s*relative_url\s*}}["'']' "Archive post links must respect Jekyll base URLs."
Assert-Matches $archive '{{\s*post\.title\s*\|\s*escape\s*}}' "Archive post titles must be escaped."
Assert-Matches $postLayout 'href\s*=\s*["'']{{\s*''/archive/''\s*\|\s*relative_url\s*}}["'']' "Article back link must respect Jekyll base URLs."
```

- [ ] **Step 4: Run the contract and verify the expected failure**

Run:

```powershell
pwsh -NoProfile -File scripts/check-homepage.ps1
```

Expected: exit code `1` with `Section with id 'intro' is missing.` The failure demonstrates that the contract rejects the old homepage before content implementation.

- [ ] **Step 5: Commit the failing content contract**

```powershell
git add -- scripts/check-homepage.ps1
git commit -m "test: define writing-first homepage contract"
```

## Task 2: Implement Homepage Content And About Migration

**Files:**
- Modify: `index.md`
- Modify: `about.md`
- Modify: `archive.md`
- Modify: `_layouts/post.html`
- Modify: `_posts/2026-02-05-第一篇.md`
- Modify: `_posts/2026-02-09-大一上小结.md`
- Modify: `_posts/2026-02-16-2025年终总结.md`
- Modify: `_posts/2026-07-15-大一下小结.md`
- Test: `scripts/check-homepage.ps1`

**Interfaces:**
- Consumes: Task 1 contract and Jekyll `site.posts`, `post.description`, `post.excerpt`, `post.url`, `post.date`, and `post.title` values.
- Produces: semantic `.home-page`, `.profile-intro`, `#intro`, and `#recent-posts` markup; front-matter descriptions consumed by the Liquid list; `.education-item` markup reused by Task 3 styles.

- [ ] **Step 1: Replace `index.md` after its front matter with the writing-first page**

Use this complete page body:

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

    <section class="home-intro" id="intro" aria-labelledby="intro-title">
        <p class="home-eyebrow">你好，我是 Percival</p>
        <h2 id="intro-title">北京大学信息科学技术学院 2025 级本科生。</h2>
        <p>记录计算机学习、校园生活，以及沿途真实发生的思考。</p>
    </section>

    <section class="home-section home-writing" id="recent-posts" aria-labelledby="recent-posts-title">
        <div class="home-section-heading">
            <h2 id="recent-posts-title">最近文章</h2>
            <a href="{{ '/archive/' | relative_url }}" aria-label="查看全部文章">查看全部</a>
        </div>
        <ul class="home-post-list">
            {% for post in site.posts limit: 5 %}
            {% assign excerpt_description = post.excerpt | strip_html | strip_newlines | truncate: 72 %}
            <li>
                <a class="home-post-link" href="{{ post.url | relative_url }}">
                    <span class="home-post-copy">
                        <span class="home-post-title">{{ post.title | escape }}</span>
                        {% if post.description %}
                        <span class="home-post-description">
                            {{ post.description | escape }}
                        </span>
                        {% elsif excerpt_description != empty %}
                        <span class="home-post-description">
                            {{ excerpt_description | escape }}
                        </span>
                        {% endif %}
                    </span>
                    <time datetime="{{ post.date | date_to_xmlschema }}">{{ post.date | date: "%Y-%m-%d" }}</time>
                </a>
            </li>
            {% endfor %}
        </ul>
    </section>

    <footer class="home-footer">© {{ site.time | date: "%Y" }} {{ site.title }}</footer>
</div>
```

- [ ] **Step 2: Replace `about.md` after its front matter with the consolidated About page**

Use:

```html
<div class="page-layout about-page">
    <a href="{{ '/' | relative_url }}" class="back-link">← 返回</a>

    <h1>关于</h1>

    <div class="post-content">
        <p>Hi，我是 Percival，北京大学信息科学技术学院 2025 级本科生。</p>

        <h2>教育经历</h2>
        <div class="education-item">
            <div>
                <strong>北京大学</strong>
                <p>信息科学技术学院 · 本科生</p>
            </div>
            <span>2025 - 至今</span>
        </div>

        <h2>座右铭</h2>
        <p>Keep calm and carry on</p>

        <h2>技能</h2>
        <ul>
            <li>C++</li>
        </ul>

        <h2>联系方式</h2>
        <ul>
            <li>GitHub: <a href="https://github.com/percival-06" target="_blank" rel="noopener noreferrer">@percival-06</a></li>
            <li>Email: <a href="mailto:66265381@qq.com">66265381@qq.com</a></li>
        </ul>
    </div>

    <footer class="page-footer">© {{ site.time | date: "%Y" }} {{ site.title }}</footer>
</div>
```

- [ ] **Step 3: Add the approved post descriptions and normalize the latest title**

Insert each `description` immediately after `date` in the corresponding front matter:

```yaml
# _posts/2026-07-15-大一下小结.md
title: "大一下小结"
date: 2026-07-15 18:00:00 +0800
description: "回顾大一下学期，也为接下来的学习做一个简单总结。"

# _posts/2026-02-16-2025年终总结.md
title: "2025年终总结"
date: 2026-02-16 00:00:00 +0800
description: "回顾高考、暑假与大学新生活，并为新一年梳理方向。"

# _posts/2026-02-09-大一上小结.md
title: "大一上小结"
date: 2026-02-09 15:23:00 +0800
description: "回顾从高中到大学的适应、学习方法与对差距的重新认识。"

# _posts/2026-02-05-第一篇.md
title: "第一篇"
date: 2026-02-05 14:12:00 +0800
description: "博客的开场：记录学习、技术与生活，并持续分享随笔与心得。"
```

Do not change the existing `layout`, `categories`, `tags`, publication dates, filenames, or article bodies.

- [ ] **Step 4: Make archive and article return links base-URL safe**

In `archive.md`, replace the back link and post link/title with:

```html
<a href="{{ '/' | relative_url }}" class="back-link">← 返回</a>
```

```html
<a href="{{ post.url | relative_url }}" class="post-link">{{ post.title | escape }}</a>
```

In `_layouts/post.html`, replace the archive return link with:

```html
<a href="{{ '/archive/' | relative_url }}" class="back-link">← 返回文章列表</a>
```

- [ ] **Step 5: Run the content contract and verify it passes**

```powershell
pwsh -NoProfile -File scripts/check-homepage.ps1
```

Expected: exit code `0` and `PASS: homepage content contract`.

- [ ] **Step 6: Commit the content migration**

```powershell
git add -- index.md about.md archive.md _layouts/post.html _posts/2026-02-05-第一篇.md _posts/2026-02-09-大一上小结.md _posts/2026-02-16-2025年终总结.md _posts/2026-07-15-大一下小结.md
git commit -m "feat: make recent writing the homepage focus"
```

## Task 3: Implement The Editorial Visual System

**Files:**
- Modify: `scripts/check-homepage.ps1`
- Modify: `_layouts/default.html`
- Modify: `assets/css/style.scss`
- Test: `scripts/check-homepage.ps1`

**Interfaces:**
- Consumes: Task 2 classes `.home-intro`, `.home-eyebrow`, `.home-writing`, `.home-post-copy`, `.home-post-title`, `.home-post-description`, and `.education-item`.
- Produces: flat `.site-header`, serif `--font-editorial` tokens, desktop editorial rows, mobile stacked rows, and unchanged `#theme-toggle` JavaScript interface.

- [ ] **Step 1: Extend the PowerShell contract with global navigation and visual selectors**

Load the default layout after the existing source loads:

```powershell
$defaultLayoutPath = Join-Path $projectRoot "_layouts/default.html"
$defaultLayout = Get-Content -Raw -Encoding utf8 $defaultLayoutPath
```

Replace obsolete style assertions for homepage education/skills with:

```powershell
Assert-Contains $defaultLayout '>文章<' "Global navigation must retain the article archive link."
Assert-Contains $defaultLayout '>关于<' "Global navigation must retain the About link."
Assert-Contains $defaultLayout 'id="theme-toggle"' "Global theme toggle is missing."

Assert-Matches $styleForChecks '(?m)^\s*--font-editorial\s*:' "Editorial font token is missing."
Assert-Matches $styleForChecks '(?m)^\s*\.home-intro(?![-\w])\s*\{' "Homepage introduction styles are missing."
Assert-Matches $styleForChecks '(?m)^\s*\.home-post-link(?![-\w])\s*\{' "Editorial post-row styles are missing."
Assert-Matches $styleForChecks '(?m)^\s*\.home-post-description(?![-\w])\s*\{' "Post description styles are missing."
Assert-Matches $styleForChecks '(?m)^\s*\.home-post-link:hover\s+\.home-post-title\s*\{' "Post-title hover styling is missing."
Assert-Matches $styleForChecks '(?m)^\s*\.about-page\s+\.education-item(?![-\w])\s*\{' "About education styles are missing."
Assert-Contains $styleForChecks '@media (max-width: 640px)' "Editorial mobile breakpoint is missing."
Assert-Contains $styleForChecks '@media (prefers-reduced-motion: reduce)' "Reduced-motion support must remain available."
Assert-NotMatches $styleForChecks '(?m)^\s*\.skill-list(?![-\w])\s*\{' "Homepage-only skill-list styles must be removed."
```

- [ ] **Step 2: Run the contract and verify the expected style failure**

```powershell
pwsh -NoProfile -File scripts/check-homepage.ps1
```

Expected: exit code `1` with `Editorial font token is missing.`

- [ ] **Step 3: Flatten the global navigation without changing its routes or theme script**

In `_layouts/default.html`, keep the existing `文章`, `关于`, `GitHub`, and theme-button markup and the complete theme JavaScript. Replace only the brand's hard-coded text with the site value:

```html
<a class="site-brand" href="{{ '/' | relative_url }}" aria-label="返回首页">
    {{ site.title }}<span aria-hidden="true">.</span>
</a>
```

Do not rename `site-header`, `site-nav`, `site-nav__link`, `theme-toggle`, or `theme-icon`; the existing theme script and style contract depend on those interfaces.

- [ ] **Step 4: Add the editorial tokens and replace the global header style blocks**

Add to `:root` and keep identical tokens available in dark mode through inheritance:

```scss
  --font-sans: Inter, ui-sans-serif, -apple-system, BlinkMacSystemFont, "Segoe UI", "PingFang SC", "Microsoft YaHei", sans-serif;
  --font-editorial: ui-serif, "Noto Serif SC", "Songti SC", STSong, Georgia, serif;
```

Change `body` to `font-family: var(--font-sans);`. Replace the current `.site-header` block with:

```scss
.site-header {
  position: sticky;
  top: 0;
  z-index: 20;
  display: flex;
  width: min(calc(100% - 3rem), 960px);
  min-height: 4.25rem;
  margin: 0 auto;
  padding: 0;
  align-items: center;
  justify-content: space-between;
  gap: 1.25rem;
  background: var(--header-background);
  border-bottom: 1px solid var(--border);
  backdrop-filter: blur(14px);
  -webkit-backdrop-filter: blur(14px);
}

.site-brand {
  flex: 0 0 auto;
  color: var(--foreground);
  font-family: var(--font-editorial);
  font-size: 1.1rem;
  font-weight: 700;
  text-decoration: none;
}

.site-nav {
  display: flex;
  min-width: 0;
  align-items: center;
  justify-content: flex-end;
  gap: 0.125rem;
}

.site-nav__link {
  display: inline-flex;
  min-height: 2.25rem;
  padding: 0.375rem 0.625rem;
  align-items: center;
  border-radius: 4px;
  color: var(--muted-foreground);
  font-size: 0.875rem;
  font-weight: 500;
  text-decoration: none;
  transition: color 160ms ease, background-color 160ms ease;
  white-space: nowrap;
}

.site-nav__link:hover,
.site-nav__link.is-active {
  background: var(--muted-surface);
  color: var(--foreground);
}

.theme-toggle {
  display: inline-grid;
  width: 2.25rem;
  height: 2.25rem;
  flex: 0 0 2.25rem;
  margin-left: 0.25rem;
  place-items: center;
  border: 0;
  border-radius: 4px;
  background: transparent;
  color: var(--muted-foreground);
  cursor: pointer;
  font: inherit;
  transition: color 160ms ease, background-color 160ms ease;
}

.theme-toggle:hover {
  background: var(--muted-surface);
  color: var(--foreground);
}
```

Remove the old header border, rounded corners, margin-top, and box shadows. Keep the existing `.site-brand span`, `.theme-icon`, and theme-specific icon-visibility rules unchanged.

- [ ] **Step 5: Replace the homepage presentation blocks with the compact editorial layout**

Remove the existing `.home-page` through `.home-footer` blocks, including obsolete `.home-prose`, `.education-item` homepage placement, and `.skill-list` blocks. Add:

```scss
.home-page {
  width: min(100%, 720px);
  margin: 0 auto;
  padding: 2.5rem 1.5rem 3rem;
  animation: fade-in-up 320ms ease both;
}

.profile-intro {
  display: flex;
  padding: 1.25rem 0 2.25rem;
  flex-direction: column;
  align-items: center;
  text-align: center;
}

.profile-intro h1 {
  margin-bottom: 0.45rem;
  font-family: var(--font-editorial);
  font-size: clamp(2.25rem, 7vw, 3rem);
  font-weight: 700;
  letter-spacing: -0.03em;
  line-height: 1.1;
}

.avatar {
  width: 6.75rem;
  height: 6.75rem;
  margin-bottom: 1.1rem;
  padding: 0.2rem;
  border: 1px solid var(--border);
  border-radius: 50%;
  background: var(--surface);
  object-fit: cover;
}

.profile-role {
  color: var(--muted-foreground);
  font-size: 0.95rem;
}

.profile-meta {
  display: flex;
  margin-top: 0.65rem;
  align-items: center;
  justify-content: center;
  gap: 0.625rem;
  color: var(--muted-foreground);
  font-size: 0.825rem;
}

.profile-meta a {
  text-decoration: none;
  transition: color 160ms ease;
}

.profile-meta a:hover {
  color: var(--primary-hover);
}

.home-intro {
  padding: 2rem 0 2.5rem;
  border-top: 1px solid var(--border);
}

.home-eyebrow {
  margin-bottom: 0.55rem;
  color: var(--primary-hover);
  font-size: 0.72rem;
  font-weight: 650;
  letter-spacing: 0.12em;
  text-transform: uppercase;
}

.home-intro h2 {
  max-width: 32rem;
  font-family: var(--font-editorial);
  font-size: clamp(1.35rem, 4vw, 1.75rem);
  font-weight: 700;
  letter-spacing: -0.02em;
  line-height: 1.4;
}

.home-intro > p:last-child {
  max-width: 35rem;
  margin-top: 0.8rem;
  color: var(--muted-foreground);
}

.home-section {
  padding: 2.5rem 0;
  border-top: 1px solid var(--border);
}

.home-section-heading {
  display: flex;
  align-items: baseline;
  justify-content: space-between;
  gap: 1rem;
}

.home-section-heading h2 {
  font-family: var(--font-editorial);
  font-size: 1.35rem;
  letter-spacing: -0.02em;
}

.home-section-heading a {
  color: var(--muted-foreground);
  font-size: 0.825rem;
  text-decoration: none;
  transition: color 160ms ease;
}

.home-section-heading a:hover {
  color: var(--primary-hover);
}

.home-post-list {
  margin-top: 0.8rem;
  list-style: none;
}

.home-post-list li + li {
  border-top: 1px solid var(--border);
}

.home-post-link {
  display: grid;
  padding: 1.15rem 0;
  grid-template-columns: minmax(0, 1fr) auto;
  align-items: start;
  gap: 1.5rem;
  text-decoration: none;
}

.home-post-copy {
  display: grid;
  min-width: 0;
  gap: 0.35rem;
}

.home-post-title {
  font-family: var(--font-editorial);
  font-size: 1.1rem;
  font-weight: 700;
  line-height: 1.4;
  overflow-wrap: anywhere;
  transition: color 160ms ease, transform 160ms ease;
}

.home-post-description {
  color: var(--muted-foreground);
  font-size: 0.875rem;
  line-height: 1.6;
}

.home-post-link time {
  padding-top: 0.2rem;
  color: var(--muted-foreground);
  font-size: 0.75rem;
  white-space: nowrap;
}

.home-post-link:hover .home-post-title {
  color: var(--primary-hover);
  transform: translateX(0.2rem);
}

.home-footer {
  padding-top: 2rem;
  border-top: 1px solid var(--border);
  color: var(--muted-foreground);
  font-size: 0.78rem;
  text-align: center;
}

.about-page .education-item {
  display: flex;
  margin: 0 0 1rem;
  align-items: flex-start;
  justify-content: space-between;
  gap: 1.5rem;
}

.about-page .education-item strong {
  font-weight: 650;
}

.about-page .education-item p,
.about-page .education-item > span {
  margin-bottom: 0;
  color: var(--muted-foreground);
  font-size: 0.875rem;
}

.about-page .education-item > span {
  flex: 0 0 auto;
}
```

- [ ] **Step 6: Replace the old mobile homepage rules with the 640px editorial breakpoint**

Replace the complete existing mobile media query with this `@media (max-width: 640px)` block:

```scss
@media (max-width: 640px) {
  .site-header {
    width: calc(100% - 2rem);
    min-height: 3.75rem;
    gap: 0.5rem;
  }

  .site-brand {
    font-size: 1rem;
  }

  .site-nav__link {
    padding-inline: 0.45rem;
    font-size: 0.78rem;
  }

  .theme-toggle {
    margin-left: 0;
  }

  .home-page {
    padding: 1.5rem 1.25rem 2.5rem;
  }

  .profile-intro {
    padding: 1rem 0 2rem;
  }

  .avatar {
    width: 6rem;
    height: 6rem;
  }

  .home-intro,
  .home-section {
    padding: 2rem 0;
  }

  .home-post-link {
    grid-template-columns: 1fr;
    gap: 0.45rem;
  }

  .home-post-link time {
    grid-row: 2;
    padding-top: 0;
  }

  .about-page .education-item {
    flex-direction: column;
    gap: 0.35rem;
  }

  .page-layout {
    padding: 3rem 1.25rem 2.5rem;
  }

  .page-layout h1 {
    font-size: 1.75rem;
  }
}
```

- [ ] **Step 7: Run the complete contract**

```powershell
pwsh -NoProfile -File scripts/check-homepage.ps1
```

Expected: exit code `0` and `PASS: homepage content contract`.

- [ ] **Step 8: Commit the editorial visual system**

```powershell
git add -- _layouts/default.html assets/css/style.scss scripts/check-homepage.ps1
git commit -m "style: add editorial homepage visual system"
```

## Task 4: Build, Render, And Regression Verification

**Files:**
- Verify: `index.md`
- Verify: `about.md`
- Verify: `_layouts/default.html`
- Verify: `_layouts/post.html`
- Verify: `archive.md`
- Verify: `assets/css/style.scss`
- Verify: all four current posts
- Verify: `scripts/check-homepage.ps1`

**Interfaces:**
- Consumes: the complete implementation from Tasks 1–3.
- Produces: recorded automated, build, and visual evidence; no new runtime or repository file is required.

- [ ] **Step 1: Run clean automated source checks**

```powershell
pwsh -NoProfile -File scripts/check-homepage.ps1
git diff --check
git status --short
```

Expected: the contract prints `PASS: homepage content contract`; `git diff --check` exits `0`; `git status --short` is empty after the Task 3 commit.

- [ ] **Step 2: Attempt the production Jekyll build without installing dependencies**

```powershell
$jekyll = Get-Command jekyll -ErrorAction SilentlyContinue
if ($jekyll) {
    jekyll build
} else {
    Write-Output "SKIP: Ruby/Jekyll is unavailable"
}
```

Expected when available: `jekyll build` exits `0`. Expected when absent: the exact `SKIP` line is recorded, and completion reporting states that the production build was not run.

- [ ] **Step 3: Render desktop and mobile previews**

Use a local Jekyll server when the build runtime is available:

```powershell
jekyll serve --host 127.0.0.1 --port 4178 --no-watch
```

When Jekyll is unavailable, create the temporary file `C:\Users\JYH\.codex\visualizations\2026\07\16\019f69ba-8132-7f73-b323-007802574ce9\preview-check.mjs` with `apply_patch`. The fixture uses the repository's actual SCSS and asset plus exact copies of the implemented semantic markup; it is verification infrastructure outside the repository and must not be committed:

```javascript
import http from 'node:http';
import fs from 'node:fs';
import path from 'node:path';

const root = 'D:\\个人\\Percival-06.github.io';
const style = fs.readFileSync(path.join(root, 'assets', 'css', 'style.scss'), 'utf8')
  .replace(/^---\r?\n---\r?\n/, '');
const avatar = fs.readFileSync(path.join(root, 'assets', 'images', 'avatar.jpg'));

const nav = `
  <header class="site-header">
    <a class="site-brand" href="/">Percival<span aria-hidden="true">.</span></a>
    <nav class="site-nav" aria-label="主导航">
      <a class="site-nav__link" href="/archive/">文章</a>
      <a class="site-nav__link" href="/about/">关于</a>
      <a class="site-nav__link" href="https://github.com/percival-06">GitHub</a>
      <button class="theme-toggle" id="theme-toggle" type="button"><span class="theme-icon theme-icon--light">☀</span><span class="theme-icon theme-icon--dark">☾</span></button>
    </nav>
  </header>`;

const posts = [
  ['大一下小结', '回顾大一下学期，也为接下来的学习做一个简单总结。', '2026-07-15'],
  ['2025年终总结', '回顾高考、暑假与大学新生活，并为新一年梳理方向。', '2026-02-16'],
  ['大一上小结', '回顾从高中到大学的适应、学习方法与对差距的重新认识。', '2026-02-09'],
  ['第一篇', '博客的开场：记录学习、技术与生活，并持续分享随笔与心得。', '2026-02-05']
];

const postRows = posts.map(([title, description, date]) => `
  <li><a class="home-post-link" href="/post/">
    <span class="home-post-copy"><span class="home-post-title">${title}</span><span class="home-post-description">${description}</span></span>
    <time datetime="${date}T00:00:00+08:00">${date}</time>
  </a></li>`).join('');

const home = `
  <div class="home-page">
    <section class="profile-intro"><img src="/assets/images/avatar.jpg" alt="Percival 的头像" class="avatar"><h1>Percival</h1><p class="profile-role">开发者 / 创作者 / 终身学习者</p><div class="profile-meta"><span>北京</span><span>/</span><a href="#">GitHub</a></div></section>
    <section class="home-intro" id="intro"><p class="home-eyebrow">你好，我是 Percival</p><h2>北京大学信息科学技术学院 2025 级本科生。</h2><p>记录计算机学习、校园生活，以及沿途真实发生的思考。</p></section>
    <section class="home-section home-writing"><div class="home-section-heading"><h2>最近文章</h2><a href="/archive/">查看全部</a></div><ul class="home-post-list">${postRows}</ul></section>
    <footer class="home-footer">© 2026 Percival</footer>
  </div>`;

const about = `
  <div class="page-layout about-page"><a href="/" class="back-link">← 返回</a><h1>关于</h1><div class="post-content">
    <p>Hi，我是 Percival，北京大学信息科学技术学院 2025 级本科生。</p>
    <h2>教育经历</h2><div class="education-item"><div><strong>北京大学</strong><p>信息科学技术学院 · 本科生</p></div><span>2025 - 至今</span></div>
    <h2>座右铭</h2><p>Keep calm and carry on</p><h2>技能</h2><ul><li>C++</li></ul>
    <h2>联系方式</h2><ul><li>GitHub: <a href="#">@percival-06</a></li><li>Email: <a href="mailto:66265381@qq.com">66265381@qq.com</a></li></ul>
  </div><footer class="page-footer">© 2026 Percival</footer></div>`;

const archive = `<div class="page-layout"><a href="/" class="back-link">← 返回</a><h1>文章</h1><ul class="post-list">${posts.map(([title,,date]) => `<li><div class="post-meta">${date}</div><a href="/post/" class="post-link">${title}</a></li>`).join('')}</ul><footer class="page-footer">© 2026 Percival</footer></div>`;

const article = `<div class="page-layout"><a href="/archive/" class="back-link">← 返回文章列表</a><article class="post"><header class="post-header"><h1>大一下小结</h1><div class="post-meta">2026-07-15</div></header><div class="post-content"><p>一转眼大一就结束了，给自己下半学期做一个简单的小结吧。</p><h2>前言</h2><p>这是一段用于验证中文正文排版、链接和段落节奏的文章内容。</p><blockquote>这是对大一下学期的简单小结。</blockquote><h3>代码示例</h3><pre><code>function hello() { return 'world'; }</code></pre></div></article><footer class="page-footer">© 2026 Percival</footer></div>`;

function page(content, dark) {
  const theme = dark ? ' data-theme="dark"' : '';
  return `<!doctype html><html lang="zh-CN"${theme}><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1"><style>${style}</style></head><body>${nav}<main class="site-main">${content}</main><script>document.getElementById('theme-toggle').addEventListener('click',()=>{const r=document.documentElement;r.dataset.theme=r.dataset.theme==='dark'?'light':'dark';});</script></body></html>`;
}

http.createServer((request, response) => {
  const url = new URL(request.url, 'http://127.0.0.1:4178');
  if (url.pathname === '/assets/images/avatar.jpg') {
    response.writeHead(200, {'content-type': 'image/jpeg'});
    response.end(avatar);
    return;
  }
  const content = url.pathname.startsWith('/about') ? about : url.pathname.startsWith('/archive') ? archive : url.pathname.startsWith('/post') ? article : home;
  response.writeHead(200, {'content-type': 'text/html; charset=utf-8'});
  response.end(page(content, url.searchParams.get('theme') === 'dark'));
}).listen(4178, '127.0.0.1', () => console.log('preview: http://127.0.0.1:4178'));
```

Start the fallback fixture with Codex's bundled Node.js:

```powershell
& 'C:\Users\JYH\.cache\codex-runtimes\codex-primary-runtime\dependencies\node\bin\node.exe' 'C:\Users\JYH\.codex\visualizations\2026\07\16\019f69ba-8132-7f73-b323-007802574ce9\preview-check.mjs'
```

For the fallback harness, capture every route at both viewport sizes and in both themes with Edge:

```powershell
$edge = 'C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe'
$output = 'C:\Users\JYH\.codex\visualizations\2026\07\16\019f69ba-8132-7f73-b323-007802574ce9'
$routes = @(
    @{ Name = 'home'; Path = '/' },
    @{ Name = 'about'; Path = '/about/' },
    @{ Name = 'archive'; Path = '/archive/' },
    @{ Name = 'post'; Path = '/post/' }
)
$themes = @('light', 'dark')

foreach ($route in $routes) {
    foreach ($theme in $themes) {
        $suffix = if ($theme -eq 'dark') { '?theme=dark' } else { '' }
        $url = "http://127.0.0.1:4178$($route.Path)$suffix"
        $desktop = Join-Path $output "$($route.Name)-$theme-desktop.png"
        $mobile = Join-Path $output "$($route.Name)-$theme-mobile.png"
        & $edge --headless=new --disable-gpu --hide-scrollbars --virtual-time-budget=750 --window-size=1440,900 "--screenshot=$desktop" $url
        & $edge --headless=new --disable-gpu --hide-scrollbars --virtual-time-budget=750 --force-device-scale-factor=2 --window-size=780,1688 "--screenshot=$mobile" $url
    }
}
```

The captures represent `1440 × 900` and `390 × 844` CSS-pixel viewports. When using the real Jekyll server, inspect the same route/theme/viewport matrix through browser automation and click the existing theme button to change themes. Do not commit the temporary harness or screenshots.

- [ ] **Step 4: Inspect the homepage, About, archive, and one article in both themes**

Confirm each exact condition:

```text
1440 × 900 homepage: the recent-article heading and first article row are visible without scrolling.
390 × 844 homepage: navigation has no horizontal overflow; post dates sit below their titles/descriptions.
Both themes: foreground, muted text, dividers, focus rings, and hover states remain readable.
Homepage: avatar is circular and centered; education and skills are absent; four current posts appear newest-first.
About: education, motto, C++, GitHub, and email are present; the education date wraps safely on mobile.
Archive: all current posts remain listed and the normalized latest title appears.
Article: headings, body copy, inline code, code blocks, and back navigation remain legible.
Reduced motion: the existing media query disables nonessential animation and transitions.
```

- [ ] **Step 5: Record completion evidence**

The final handoff must name:

```text
The PowerShell contract command and PASS output.
The git diff --check result.
Whether Jekyll build passed or was skipped because the runtime was absent.
The desktop and mobile viewport sizes visually inspected.
Any residual limitation that remains after verification.
```
