# Writing-First Homepage Design

## Goal

Redesign the existing Jekyll homepage into a writing-first personal site inspired by the restraint and content rhythm of Arthals' ink without reproducing its visual identity. The new homepage should communicate that Percival writes consistently, bring recent posts into view earlier, and retain recognizable personal elements such as the centered circular avatar.

This phase covers the homepage, the content moved from the homepage to the About page, and the post metadata needed by the homepage list. Projects, search, comments, feeds, article-page redesigns, and new content categories remain outside scope.

## Chosen Direction

The design uses a personal editorial direction rather than a close visual copy of the reference site. It keeps the reference site's restrained palette, content-led hierarchy, and compact reading rhythm while introducing a distinct type system and a simpler writing-focused information architecture.

The homepage prioritizes articles and ongoing output. Education and skills no longer compete with the post list on the homepage; they live on the About page.

## Information Architecture

The homepage remains a single-column document with the following order:

1. Global navigation
   - Brand link
   - Article archive
   - About page
   - GitHub profile
   - Light/dark theme toggle
2. Profile introduction
   - Existing centered circular avatar
   - Name: `Percival`
   - Concise identity line
   - Beijing and GitHub metadata
3. Short introduction
   - One or two sentences describing who Percival is and what he writes about
4. Recent writing
   - Up to five newest posts
   - Title, date, and one-line description for each post
   - A clear archive link on the same heading row, allowed to wrap below the heading on narrow screens
5. Minimal footer
   - Current year and site title

The homepage does not contain education, skills, projects, a now section, status widgets, or placeholder content.

## Profile Introduction

The existing avatar remains circular, centered, and visually prominent. Its border and shadow become quieter, and the profile block becomes shorter so the recent-writing heading or first article is visible within a common desktop viewport.

The identity copy stays concise and factual. It should support the writing rather than behave like a full résumé summary.

## Recent Writing

The post area uses an editorial list rather than article cards or a timeline. Each row contains:

- The escaped post title as the primary element
- The publication date as secondary metadata
- A concise one-line description when available

Rows use typography, whitespace, subtle dividers, and a small hover movement to establish hierarchy. They do not use filled card backgrounds. Desktop rows may place the date opposite the title; mobile rows place the date below or near the title so long Chinese titles retain enough width.

The homepage renders the five newest posts from `site.posts`. The archive page remains the complete chronological list.

## Post Description Data

Posts may define a `description` value in YAML front matter. The homepage resolves the display copy in this order:

1. Use `post.description` when it exists and is not empty.
2. Otherwise pass `post.excerpt` through Jekyll's `strip_html`, `strip_newlines`, and `truncate: 72` filters, and use the result when it is not empty.
3. Otherwise omit the description and keep the row aligned with title and date only.

The four current posts receive these front-matter descriptions, based on their existing body content:

- `大一下小结`: `回顾大一下学期，也为接下来的学习做一个简单总结。`
- `2025年终总结`: `回顾高考、暑假与大学新生活，并为新一年梳理方向。`
- `大一上小结`: `回顾从高中到大学的适应、学习方法与对差距的重新认识。`
- `第一篇`: `博客的开场：记录学习、技术与生活，并持续分享随笔与心得。`

Future posts may add `description` without changing the homepage template.

The latest post's front-matter title changes from `2026-07-15-大一下小结` to `大一下小结`. Its filename, URL date components, and publication date remain unchanged.

## About Page

The About page becomes the home for personal details that no longer appear on the homepage. It contains:

- The existing personal introduction, edited only for spacing and readability
- Education: 北京大学信息科学技术学院, 本科生, `2025 - 至今`
- Existing motto
- Existing `C++` skill
- Existing GitHub and email contact details

No additional experience, skill, award, project, or credential is invented.

## Visual System

The design retains the existing low-saturation blue-gray accent and both light and dark themes.

- The global header becomes visually flatter and lighter, with a subtle divider instead of a prominent floating-card treatment.
- Body copy and navigation use the existing system-oriented sans-serif stack for clarity.
- The profile name, section headings, and article titles use a locally available serif fallback stack to create an editorial voice without downloading a remote font.
- Large gradients, saturated decorative colors, and filled article cards are excluded.
- Section spacing becomes tighter than the current implementation while retaining a calm reading rhythm.
- Avatar styling stays circular and centered, with reduced border and shadow emphasis.

Color contrast must remain readable in both themes. Theme colors continue to be expressed through shared CSS custom properties instead of page-specific literal values.

## Motion And Interaction

Motion remains restrained:

- Keep a subtle page-entry fade.
- Add only a small color or horizontal movement response to post links.
- Keep navigation and theme-toggle hover/focus feedback.
- Preserve `prefers-reduced-motion` handling so nonessential transitions and animation are effectively disabled.

The theme selection remains stored in `localStorage` when available and falls back safely when storage access fails.

## Responsive Behavior

The site remains a narrow single-column layout.

- Desktop: reduce the profile block height enough to expose the beginning of recent writing on a common viewport.
- Mobile: reduce outer padding and section spacing; keep navigation usable without horizontal overflow.
- Article rows: stack or regroup title, date, and description so titles receive the full available width.
- About content: remain single-column, with education dates allowed to wrap below the institution details when necessary.

No content is removed solely because the viewport is small.

## Accessibility And Link Safety

- Retain semantic headings and section labels.
- Keep meaningful avatar alternative text.
- Preserve visible keyboard focus styles for links and buttons.
- Use `relative_url` for internal homepage, archive, About, asset, and post links.
- Escape post titles before rendering.
- Keep safe `target` and `rel` attributes on external links that open a new tab.
- Do not rely on color or animation alone to communicate hover, focus, or active state.

## Implementation Boundaries

The implementation stays within the existing Jekyll structure. It may update:

- `index.md`
- `about.md`
- `_layouts/default.html`
- `assets/css/style.scss`
- Current post front matter
- `scripts/check-homepage.ps1` or focused companion checks

It does not add a JavaScript framework, CSS framework, remote font service, CMS, build-time content service, or client-side article loader.

## Verification

Verification must cover both structure and rendered behavior:

1. Extend the PowerShell content contract so it initially fails for the new requirements and then passes after implementation. It must check:
   - Homepage section order and removal of education and skills
   - A `site.posts` loop limited to five posts
   - Title escaping, date metadata, internal `relative_url` use, and description fallback behavior
   - The archive link
   - Education and skills on the About page
   - Continued reduced-motion support
2. Run the relevant PowerShell checks after implementation.
3. Run a Jekyll build when a compatible local Ruby/Jekyll runtime is available. If unavailable, report that limitation rather than claiming build success.
4. Render or preview desktop and mobile layouts and inspect:
   - First-viewport content balance
   - Long Chinese titles and description wrapping
   - Navigation overflow
   - Light and dark theme contrast
   - Hover and keyboard focus states
5. Run `git diff --check` before completion.

## Success Criteria

The redesign is successful when:

- At a 1440 × 900 desktop viewport, the recent-writing heading and at least the first article row are visible without scrolling.
- The homepage reads primarily as an actively maintained personal blog, not a résumé or generic profile template.
- The avatar and personal identity remain recognizable.
- Recent posts update automatically through Jekyll data and tolerate missing descriptions.
- Education and skills remain discoverable on the About page.
- Desktop, mobile, light, dark, keyboard, and reduced-motion paths remain usable.
