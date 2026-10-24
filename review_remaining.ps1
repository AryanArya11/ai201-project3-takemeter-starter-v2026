$rows = Import-Csv candidates.csv
$labeled = [System.Collections.Generic.List[object]]::new()
foreach ($row in (Import-Csv labels.csv)) { $labeled.Add($row) }

$seen = [System.Collections.Generic.HashSet[string]]::new()
foreach ($row in $labeled) {
    if ($row.note -match 'https://news\.ycombinator\.com/item\?id=\d+') {
        [void]$seen.Add($Matches[0])
    }
}

foreach ($post in $rows) {
    if ($labeled.Count -ge 200) { break }
    if ($seen.Contains($post.note)) { continue }

    $text = $post.text

    # A rough suggestion, not a final label.
    $suggestion = ""
    if ($text -match '(?i)\b(I built|I tried|I used|I worked|I tested|we built|we tried|in my experience|at my job)\b') {
        $suggestion = "real_world_experience"
    }
    elseif ($text -match '(?i)\b(will|going to|I expect|I predict|in the future|next year|within \d+ years)\b') {
        $suggestion = "prediction"
    }
    elseif ($text -match '(?i)\b(because|works by|implemented|architecture|latency|bandwidth|memory|database|kernel|CPU|GPU)\b') {
        $suggestion = "technical_explanation"
    }

    Clear-Host
    Write-Host "Labeled: $($labeled.Count) / 200" -ForegroundColor Cyan
    Write-Host ""
    Write-Host $text
    Write-Host ""
    Write-Host "Suggestion: $suggestion"
    Write-Host "[Enter] Accept suggestion (only if there is one)"
    Write-Host "[t] Technical explanation  [p] Prediction"
    Write-Host "[r] Real-world experience [s] Skip [x] Save and stop"

    $choice = (Read-Host "Your decision").Trim().ToLower()

    if ($choice -eq "x") { break }

    $label = switch ($choice) {
        "t" { "technical_explanation" }
        "p" { "prediction" }
        "r" { "real_world_experience" }
        ""  { $suggestion }
        default { "" }
    }

    if ($choice -eq "s" -or -not $label) { continue }

    $labeled.Add([PSCustomObject]@{
        text  = $text
        label = $label
        note  = "rule-suggested; human-reviewed; $($post.note)"
    })
    [void]$seen.Add($post.note)

    # Save after every decision so stopping or an error won't lose your work.
    $labeled | Export-Csv labels.csv -NoTypeInformation -Encoding UTF8
}

Write-Host "Saved $($labeled.Count) labeled posts."