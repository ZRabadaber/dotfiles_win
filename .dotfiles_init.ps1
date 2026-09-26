$dotfiles = Join-Path $env:USERPROFILE '.dotfiles'
Write-Host "Репозиторий: $dotfiles"

git "--git-dir=$dotfiles" rev-parse --is-bare-repository *> $null
if ($LASTEXITCODE -ne 0) {
    git init --bare $dotfiles
    Write-Host "Создан новый репозиторий."
} else {
    git "--git-dir=$dotfiles" "--work-tree=$env:USERPROFILE" reset --hard
    git "--git-dir=$dotfiles" "--work-tree=$env:USERPROFILE" pull
    Write-Host "Файлы приведены в актуальное состояние."
}
git "--git-dir=$dotfiles" "--work-tree=$env:USERPROFILE" config --local status.showUntrackedFiles no

$profileDirectory = Split-Path -Parent $PROFILE
if (-not (Test-Path -LiteralPath $profileDirectory)) {
    New-Item -ItemType Directory -Path $profileDirectory -Force | Out-Null
}

$dotScriptPath = Join-Path $profileDirectory 'dot.ps1'
$dotScript = @'
$git = "git.exe"
function git-dot {& $git "--git-dir=$env:USERPROFILE\.dotfiles" "--work-tree=$env:USERPROFILE" $args}
Set-Alias dot git-dot

function yy {
  $tmp = (New-TemporaryFile).FullName
  [System.Environment]::SetEnvironmentVariable("YAZI_CWD", $tmp, "User")
  yazi $args --cwd-file="$tmp"
  $cwd = Get-Content -Path $tmp -Encoding UTF8
  if (-not [String]::IsNullOrEmpty($cwd) -and $cwd -ne $PWD.Path) {
    Set-Location -LiteralPath (Resolve-Path -LiteralPath $cwd).Path
  }
  Remove-Item -Path $tmp
}

Invoke-Expression (&starship init powershell)
'@
Set-Content -LiteralPath $dotScriptPath -Value $dotScript -Encoding UTF8
Write-Host "Добавлен файл: $dotScriptPath"

if (-not (Test-Path -LiteralPath $PROFILE)) {
    New-Item -ItemType File -Path $PROFILE -Force | Out-Null
    Write-Host "Добавлен профиль: $PROFILE"
}

$escapedDotScriptPath = $dotScriptPath.Replace("'", "''")
$profileCall = ". '$escapedDotScriptPath'"
$profileLines = Get-Content -LiteralPath $PROFILE -ErrorAction SilentlyContinue
$hasProfileCall = $profileLines | Where-Object { $_.Trim() -ceq $profileCall } | Select-Object -First 1

if ($null -eq $hasProfileCall) {
    Add-Content -LiteralPath $PROFILE -Value $profileCall
    Write-Host "Добавлен вызов dot.ps1 в профиль: $PROFILE"
} else {
    Write-Host "Вызов dot.ps1 уже есть в профиле: $PROFILE"
}
