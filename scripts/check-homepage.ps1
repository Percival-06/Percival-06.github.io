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
