# Build the website and the book, then serve them at http://localhost:4300
#
#   .\build.ps1                build everything, then serve
#   .\build.ps1 -NoBuild       serve what is already built
#   .\build.ps1 -NoServe       build only
#   .\build.ps1 -Playground    also rebuild the playground download zips first
#   .\build.ps1 -Chapter 07-hypothesis-testing.qmd
#                              render one book chapter only, then serve
#
# If Windows refuses to run the script, use:
#   powershell -ExecutionPolicy Bypass -File .\build.ps1
#
# Chapters whose code has not changed are not re-run (their results are frozen
# in _freeze), so a full build takes seconds, not an hour.

param(
  [switch]$NoBuild,
  [switch]$NoServe,
  [switch]$Playground,
  [string]$Chapter = "",
  [int]$Port = 4300
)

$ErrorActionPreference = "Stop"
$root    = $PSScriptRoot
$quarto  = "C:\Program Files\Quarto\bin\quarto.exe"
$rscript = "C:\Program Files\R\R-4.4.3\bin\Rscript.exe"
$env:QUARTO_R = $rscript

if (-not $NoBuild) {
  if ($Playground) {
    Write-Host "Building the playground download zips..." -ForegroundColor Cyan
    Push-Location $root
    & $rscript data-raw/build_playground.R
    Pop-Location
  }

  if ($Chapter) {
    $target = if ($Chapter -like "content/book/*") { $Chapter } else { "content/book/$Chapter" }
    Write-Host "Rendering $target..." -ForegroundColor Cyan
    & $quarto render $target
  } else {
    Write-Host "Rendering website, book, and playground..." -ForegroundColor Cyan
    & $quarto render

    # Mirror content/ paths to root URLs for backward compatibility
    if (Test-Path "$root/_site/content") {
      Copy-Item -Path "$root/_site/content/*" -Destination "$root/_site" -Recurse -Force
    }
  }
}

if (-not $NoServe) {
  Write-Host ""
  Write-Host "Serving http://localhost:$Port  (press Ctrl+C to stop)" -ForegroundColor Green
  python -m http.server $Port --directory (Join-Path $root "_site")
}
