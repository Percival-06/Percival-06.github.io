$ErrorActionPreference = "Stop"

$projectRoot = Split-Path -Parent $PSScriptRoot
$indexPath = Join-Path $projectRoot "index.md"
$index = Get-Content -Raw -Encoding utf8 $indexPath
$stylePath = Join-Path $projectRoot "assets/css/style.scss"
$style = Get-Content -Raw -Encoding utf8 $stylePath
$configPath = Join-Path $projectRoot "_config.yml"
$config = Get-Content -Raw -Encoding utf8 $configPath
$aboutPath = Join-Path $projectRoot "about.md"
$about = Get-Content -Raw -Encoding utf8 $aboutPath
$archivePath = Join-Path $projectRoot "archive.md"
$archive = Get-Content -Raw -Encoding utf8 $archivePath
$postLayoutPath = Join-Path $projectRoot "_layouts/post.html"
$postLayout = Get-Content -Raw -Encoding utf8 $postLayoutPath
$defaultLayoutPath = Join-Path $projectRoot "_layouts/default.html"
$defaultLayout = Get-Content -Raw -Encoding utf8 $defaultLayoutPath

$postExpectations = @(
    @{
        File = "2026-07-15-大一下小结.md"
        Title = "title: `"大一下小结`""
        Description = "description: `"回顾大一下学期，也为接下来的学习做一个简单总结。`""
    },
    @{
        File = "2026-02-16-2025年终总结.md"
        Title = "title: `"2025年终总结`""
        Description = "description: `"回顾高考、暑假与大学新生活，并为新一年梳理方向。`""
    },
    @{
        File = "2026-02-09-大一上小结.md"
        Title = "title: `"大一上小结`""
        Description = "description: `"回顾从高中到大学的适应、学习方法与对差距的重新认识。`""
    },
    @{
        File = "2026-02-05-第一篇.md"
        Title = "title: `"第一篇`""
        Description = "description: `"博客的开场：记录学习、技术与生活，并持续分享随笔与心得。`""
    }
)
$regexOptions = [System.Text.RegularExpressions.RegexOptions]::IgnoreCase -bor
    [System.Text.RegularExpressions.RegexOptions]::Singleline

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

function Assert-Matches {
    param(
        [string]$Content,
        [string]$Pattern,
        [string]$Message
    )

    if (-not [regex]::IsMatch($Content, $Pattern, $script:regexOptions)) {
        throw $Message
    }
}

function Assert-NotMatches {
    param(
        [string]$Content,
        [string]$Pattern,
        [string]$Message
    )

    if ([regex]::IsMatch($Content, $Pattern, $script:regexOptions)) {
        throw $Message
    }
}

function Get-SectionByClass {
    param(
        [string]$Content,
        [string]$ClassName
    )

    $escapedClassName = [regex]::Escape($ClassName)
    $pattern = '<section\b(?=[^>]*\bclass\s*=\s*["''][^"'']*\b' +
        $escapedClassName + '\b[^"'']*["''])[^>]*>.*?</section>'
    $match = [regex]::Match($Content, $pattern, $script:regexOptions)

    if (-not $match.Success) {
        throw "Section with class '$ClassName' is missing."
    }

    return $match.Value
}

function Get-SectionById {
    param(
        [string]$Content,
        [string]$Id
    )

    $escapedId = [regex]::Escape($Id)
    $pattern = '<section\b(?=[^>]*\bid\s*=\s*["'']' +
        $escapedId + '["''])[^>]*>.*?</section>'
    $match = [regex]::Match($Content, $pattern, $script:regexOptions)

    if (-not $match.Success) {
        throw "Section with id '$Id' is missing."
    }

    return $match.Value
}

$index = [regex]::Replace($index, '<!--.*?-->', '', $regexOptions)
$index = [regex]::Replace(
    $index,
    '{%-?\s*comment\s*-?%}.*?{%-?\s*endcomment\s*-?%}',
    '',
    $regexOptions
)

Assert-Contains $index '<div class="home-page">' "Homepage wrapper is missing."
Assert-NotContains $index 'id="typewriter"' "Typewriter markup must be removed."
Assert-NotContains $index 'setTimeout(type' "Typewriter JavaScript must be removed."

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
Assert-Matches $postLayout '{{\s*page\.title\s*\|\s*escape\s*}}' "Article titles must be escaped."

$styleForChecks = [regex]::Replace($style, '/\*.*?\*/', '', $regexOptions)
$styleForChecks = [regex]::Replace(
    $styleForChecks,
    '(?m)^[ \t]*//[^\r\n]*(?:\r?\n|$)',
    ''
)

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
Assert-Matches $styleForChecks '(?m)^\s*\.home-intro(?![-\w])\s*\{[^}]*\boverflow-wrap\s*:\s*anywhere\s*;[^}]*\}' "Homepage introduction must wrap within the viewport."
Assert-Matches $styleForChecks '(?m)^\s*\.post-content(?![-\w])\s*\{[^}]*\boverflow-wrap\s*:\s*anywhere\s*;[^}]*\}' "Article and About prose must wrap within the viewport."
Assert-Matches $styleForChecks '(?m)^\s*\.post-content\s+pre(?![-\w])\s*\{[^}]*\bmax-width\s*:\s*100%\s*;[^}]*\boverflow-x\s*:\s*auto\s*;[^}]*\}' "Code blocks must scroll internally without widening the page."
Assert-Matches $styleForChecks '@media\s*\(max-width:\s*640px\)\s*\{.*?\.site-header(?![-\w])\s*\{[^}]*\bflex-wrap\s*:\s*wrap\s*;[^}]*\}.*?\.site-nav(?![-\w])\s*\{[^}]*\bflex\s*:\s*1\s+1\s+100%\s*;[^}]*\}' "Mobile navigation must wrap intact when horizontal space is constrained."
Assert-NotMatches $styleForChecks '(?m)^\s*\.skill-list(?![-\w])\s*\{' "Homepage-only skill-list styles must be removed."

Assert-NotMatches $styleForChecks '(?m)^\s*\.home-layout(?![-\w])[^\r\n,{]*\{' "Legacy homepage layout styles must be removed."
Assert-NotMatches $styleForChecks '(?m)^\s*\.typewriter-text(?![-\w])[^\r\n,{]*\{' "Legacy typewriter styles must be removed."
Assert-NotMatches $styleForChecks '(?m)^\s*\.cursor(?![-\w])[^\r\n,{]*\{' "Legacy cursor styles must be removed."
Assert-NotMatches $styleForChecks '(?m)^\s*\.tagline(?![-\w])[^\r\n,{]*\{' "Legacy tagline styles must be removed."
Assert-NotMatches $styleForChecks '(?m)^\s*\.minimal-nav(?![-\w])[^\r\n,{]*\{' "Legacy minimal navigation styles must be removed."
Assert-NotMatches $styleForChecks '(?m)^\s*\.minimal-footer(?![-\w])[^\r\n,{]*\{' "Legacy minimal footer styles must be removed."
Assert-NotMatches $styleForChecks '(?m)^\s*@keyframes\s+blink\b\s*\{' "Legacy cursor animation must be removed."

Assert-Matches $styleForChecks '(?m)^\s*\.profile-meta\s+a:hover\s*\{[^}]*\bcolor\s*:\s*var\(--primary-hover\)\s*;[^}]*\}' "Profile metadata hover must use the high-contrast primary color."
Assert-Matches $styleForChecks '(?m)^\s*\.home-section-heading\s+a:hover\s*\{[^}]*\bcolor\s*:\s*var\(--primary-hover\)\s*;[^}]*\}' "Homepage section link hover must use the high-contrast primary color."
Assert-Matches $styleForChecks '(?m)^\s*\.home-post-link:hover\s+\.home-post-title\s*\{[^}]*\bcolor\s*:\s*var\(--primary-hover\)\s*;[^}]*\}' "Homepage post hover must use the high-contrast primary color."

Assert-Matches $config '(?m)^\s*-\s+docs/?\s*$' "Jekyll must exclude internal docs from the published site."

Write-Output "PASS: homepage content contract"
