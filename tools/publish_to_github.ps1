param(
  [Parameter(Mandatory=$true)][string]$Token,
  [string]$User = "yurkoivan",
  [string]$Repo = "Jellyfin.Plugin.ThePornDB",
  [string]$Tag = "v1.6.0.0",
  [string]$ZipPath = "Jellyfin.Plugin.ThePornDB/bin/Release/Jellyfin.Plugin.ThePornDB.zip"
)

$ErrorActionPreference = 'Stop'

function Invoke-GHApi {
  param(
    [Parameter(Mandatory)][string]$Method,
    [Parameter(Mandatory)][string]$Url,
    [object]$Body,
    [hashtable]$Headers
  )
  $hdr = @{
    'Authorization' = "Bearer $Token"
    'Accept' = 'application/vnd.github+json'
    'User-Agent' = 'CodexCLI/1.0'
    'X-GitHub-Api-Version' = '2022-11-28'
  }
  if ($Headers) { $hdr += $Headers }
  if ($Body) {
    return Invoke-RestMethod -Method $Method -Uri $Url -Headers $hdr -Body ($Body | ConvertTo-Json -Depth 10) -ContentType 'application/json'
  } else {
    return Invoke-RestMethod -Method $Method -Uri $Url -Headers $hdr
  }
}

Write-Host "Ensuring repo https://github.com/$User/$Repo exists..."
try {
  $null = Invoke-GHApi -Method GET -Url "https://api.github.com/repos/$User/$Repo"
} catch {
  Write-Host "Creating repository $Repo under $User..."
  $null = Invoke-GHApi -Method POST -Url 'https://api.github.com/user/repos' -Body @{ name=$Repo; private=$false; description='Jellyfin 10.10 compatible ThePornDB plugin'}
}

git init | Out-Null
git config user.name 'Codex CLI'
git config user.email 'codex@example.com'
git add .
try { git commit -m 'feat: Jellyfin 10.10 compatibility (v1.6.0.0)' | Out-Null } catch {}
git branch -M main

git remote remove origin 2>$null
$remote = "https://$User:`$Token@github.com/$User/$Repo.git"
git remote add origin $remote
git push -u origin main

try { git tag -a $Tag -m "Release $Tag" } catch {}
git push origin $Tag

Write-Host "Creating GitHub release $Tag..."
$release = $null
try {
  $release = Invoke-GHApi -Method POST -Url "https://api.github.com/repos/$User/$Repo/releases" -Body @{ tag_name=$Tag; name=$Tag; prerelease=$false; draft=$false }
} catch {
  $release = Invoke-GHApi -Method GET -Url "https://api.github.com/repos/$User/$Repo/releases/tags/$Tag"
}

if (!(Test-Path $ZipPath)) { throw "Zip not found: $ZipPath" }
$uploadUrl = $release.upload_url -replace "{.*$", ''
$assetName = [IO.Path]::GetFileName($ZipPath)
Write-Host "Uploading asset $assetName..."
$headers = @{ 'Content-Type' = 'application/zip' }
$bytes = [IO.File]::ReadAllBytes($ZipPath)
$uri = "$uploadUrl?name=$assetName"
Invoke-WebRequest -Method POST -Uri $uri -Headers (@{'Authorization'="Bearer $Token"; 'Accept'='application/vnd.github+json'; 'X-GitHub-Api-Version'='2022-11-28'}) -ContentType 'application/zip' -Body $bytes | Out-Null

Write-Host "Done. Repo: https://github.com/$User/$Repo"
Write-Host "Release: https://github.com/$User/$Repo/releases/tag/$Tag"

