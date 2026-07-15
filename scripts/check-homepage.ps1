$ErrorActionPreference = "Stop"

$projectRoot = Split-Path -Parent $PSScriptRoot
$indexPath = Join-Path $projectRoot "index.md"
$index = Get-Content -Raw -Encoding utf8 $indexPath
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
Assert-Matches $profile '<a\b[^>]*href\s*=\s*["'']https://github\.com/percival-06["''][^>]*>\s*GitHub\s*</a>' "Profile GitHub link is missing."

$about = Get-SectionById $index 'about'
Assert-Contains $about '北京大学信息科学技术学院 2025 级本科生' "About education content is missing."
Assert-Contains $about '在这里记录学习、技术与生活中的思考。' "About introduction is missing."

$recentPosts = Get-SectionById $index 'recent-posts'
Assert-Matches $recentPosts '<h2\b[^>]*>\s*最近文章\s*</h2>' "Recent posts heading is missing."
Assert-Matches $recentPosts '<a\b(?=[^>]*\bhref\s*=\s*["'']{{\s*''/archive/''\s*\|\s*relative_url\s*}}["''])(?=[^>]*\baria-label\s*=\s*["'']查看全部文章["''])[^>]*>\s*查看全部\s*</a>' "Archive link must retain its text and have an accessible label."

$loopPattern = '{%-?\s*for\s+post\s+in\s+site\.posts\s+limit\s*:\s*3\s*-?%}(?<Body>.*?){%-?\s*endfor\s*-?%}'
$loopMatch = [regex]::Match($recentPosts, $loopPattern, $regexOptions)
if (-not $loopMatch.Success) {
    throw "Recent posts must use a three-post Jekyll loop."
}

$loopBody = $loopMatch.Groups['Body'].Value
Assert-Matches $loopBody 'href\s*=\s*["'']{{\s*post\.url\s*\|\s*relative_url\s*}}["'']' "Post links must respect Jekyll base URLs."
Assert-Matches $loopBody 'datetime\s*=\s*["'']{{\s*post\.date\s*\|\s*date_to_xmlschema\s*}}["'']' "Post datetime must use date_to_xmlschema."
Assert-Matches $loopBody '>\s*{{\s*post\.date\s*\|\s*date:\s*["'']%Y-%m-%d["'']\s*}}\s*</time>' "Visible post date must format post.date."
Assert-Matches $loopBody '{{\s*post\.title\s*\|\s*escape\s*}}' "Post titles must be escaped."

$education = Get-SectionById $index 'education'
Assert-Contains $education '北京大学' "Education institution is missing."
Assert-Contains $education '信息科学技术学院 · 本科生' "Education program is missing."
Assert-Contains $education '2025 - 至今' "Education dates are missing."

$skills = Get-SectionById $index 'skills'
Assert-Matches $skills '<li\b[^>]*>\s*C\+\+\s*</li>' "C++ skill is missing."

Write-Output "PASS: homepage content contract"
