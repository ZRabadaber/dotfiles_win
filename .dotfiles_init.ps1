$dotfiles = Join-Path $env:USERPROFILE '.dotfiles'
git "--git-dir=$dotfiles" rev-parse --is-bare-repository *> $null
if ($LASTEXITCODE -ne 0) {
    git init --bare $dotfiles
}
git "--git-dir=$dotfiles" "--work-tree=$env:USERPROFILE" config --local status.showUntrackedFiles no

Add-Content -Path $PROFILE -Value '$git = "git.exe"
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

'
