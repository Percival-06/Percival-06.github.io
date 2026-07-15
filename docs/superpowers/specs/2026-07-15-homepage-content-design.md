# Homepage Content Design

## Goal

Turn the current full-screen profile card into a content-led personal homepage inspired by Arthals' ink while keeping Percival's identity, existing routes, and Jekyll setup.

This phase covers only the homepage. Projects, search, comments, article metadata, and article-page enhancements remain outside its scope.

## Content

The homepage uses one vertical column with these sections:

1. Profile introduction
   - Existing avatar
   - Name: Percival
   - Fixed role line: `开发者 / 创作者 / 终身学习者`
   - Location: `北京`
   - Link to the existing GitHub profile
2. About
   - A concise introduction based on the existing About page
   - Identifies Percival as a 2025 undergraduate in 北京大学信息科学技术学院
   - States that the site records learning, technology, and reflections on life
3. Recent posts
   - Automatically renders the three newest Jekyll posts
   - Shows each post's title and publication date
   - Includes a link to the full archive
4. Education
   - 北京大学信息科学技术学院
   - `2025 - 至今`
5. Skills
   - Shows only `C++`

No placeholder skills, projects, or experiences will be invented.

## Layout And Visual Direction

- Keep the existing global header and theme switcher.
- Use a centered profile introduction followed by a narrow content column of approximately 720 pixels.
- The profile area must not fill the entire viewport; the beginning of the About section remains visible on common desktop and mobile viewports.
- Use unframed sections, whitespace, headings, and subtle dividers instead of cards.
- Continue using the existing light and dark theme variables and low-saturation blue accent.
- Keep all content in a single column on mobile and reduce spacing without changing the content order.
- Remove the typewriter animation and its JavaScript. The role line becomes static.
- Retain only the existing subtle page-entry animation and respect `prefers-reduced-motion`.

## Data And Behavior

- Jekyll's `site.posts` collection is the source for recent posts.
- The homepage limits the loop to three posts and uses `relative_url` for internal links.
- Adding or removing posts automatically updates the homepage without editing `index.md`.
- GitHub remains an external link and opens in a new tab with safe `rel` attributes.
- Existing `/archive/` and `/about/` routes remain unchanged.

## Accessibility

- Use semantic sections with headings and accessible labels.
- Preserve meaningful avatar alternative text.
- Keep keyboard focus styles from the global theme.
- Ensure text and controls retain sufficient contrast in light and dark modes.
- Do not rely on animation or color alone to communicate information.

## Verification

- Add a failing structural check before implementation for the required sections, recent-post loop, three-post limit, archive link, and absence of the typewriter script.
- Run the check again after implementation and confirm it passes.
- Run `git diff --check`.
- Render desktop and mobile previews and inspect spacing, overflow, content order, and readability.
- Inspect both theme variable paths. If Ruby/Jekyll remains unavailable locally, report that the production Jekyll build could not be executed rather than claiming build success.
