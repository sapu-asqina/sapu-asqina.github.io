$ErrorActionPreference = "Stop"

# Refresh PATH so git/gh are found in this shell
$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")

Set-Location $PSScriptRoot

Write-Host "==> Checking GitHub CLI auth..." -ForegroundColor Cyan
gh auth status *> $null
if ($LASTEXITCODE -ne 0) {
    Write-Host "Not signed in. Launching 'gh auth login'..." -ForegroundColor Yellow
    gh auth login
    if ($LASTEXITCODE -ne 0) { throw "GitHub login failed." }
}

$user = (gh api user --jq .login).Trim()
if ([string]::IsNullOrWhiteSpace($user)) { throw "Could not read GitHub username." }
$repo = "$user.github.io"

Write-Host "GitHub user : $user" -ForegroundColor Green
Write-Host "Target repo : $repo" -ForegroundColor Green

# Commit identity (local to this repo)
git config user.email "$user@users.noreply.github.com"
git config user.name  "$user"

# Init repo if needed
if (-not (Test-Path (Join-Path $PSScriptRoot ".git"))) {
    Write-Host "==> Initializing git repo..." -ForegroundColor Cyan
    git init -b main | Out-Null
}

git add -A
git diff --cached --quiet
if ($LASTEXITCODE -ne 0) {
    git commit -m "Add product catalog" | Out-Null
    Write-Host "==> Commit created." -ForegroundColor Cyan
} else {
    Write-Host "==> No changes to commit." -ForegroundColor Cyan
}

git branch -M main

# Create the repo on GitHub if it does not exist yet
gh repo view "$user/$repo" *> $null
if ($LASTEXITCODE -ne 0) {
    Write-Host "==> Creating repo $repo ..." -ForegroundColor Cyan
    gh repo create $repo --public --source=. --remote=origin --push
} else {
    Write-Host "==> Repo already exists. Ensuring remote + push..." -ForegroundColor Cyan
    $remotes = git remote
    if ($remotes -notcontains "origin") {
        git remote add origin "https://github.com/$user/$repo.git"
    }
    git push -u origin main
}

Write-Host ""
Write-Host "===================================================" -ForegroundColor Green
Write-Host " Done! Site will be live in ~1 minute at:" -ForegroundColor Green
Write-Host "   https://$user.github.io/" -ForegroundColor Yellow
Write-Host "===================================================" -ForegroundColor Green
