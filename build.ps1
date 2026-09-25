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
# in _freeze), so a full build takes a few minutes, not an hour.

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

function Render($folder, $target) {
  Push-Location (Join-Path $root $folder)
  try {
    if ($target) { & $quarto render $target } else { & $quarto render }
    if ($LASTEXITCODE -ne 0) { throw "Rendering $folder failed." }
  } finally {
    Pop-Location
  }
}

if (-not $NoBuild) {
  if ($Playground) {
    Write-Host "Building the playground download zips..." -ForegroundColor Cyan
    Push-Location $root
    & $rscript data-raw/build_playground.R
    Pop-Location
  }

  if ($Chapter) {
    Write-Host "Rendering book/$Chapter..." -ForegroundColor Cyan
    Render "book" $Chapter
  } else {
    # The website first, then the book: the book is published inside the site.
    Write-Host "Rendering the website..." -ForegroundColor Cyan
    Render "site" ""
    Write-Host "Rendering the book..." -ForegroundColor Cyan
    Render "book" ""
  }
}

if (-not $NoServe) {
  Write-Host ""
  Write-Host "Serving http://localhost:$Port  (press Ctrl+C to stop)" -ForegroundColor Green
  python -m http.server $Port --directory (Join-Path $root "_site")
}
