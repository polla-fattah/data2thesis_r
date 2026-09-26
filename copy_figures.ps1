$sources = @("content/book/_freeze", "content/book/.quarto/_freeze")
foreach ($s in $sources) {
    if (Test-Path $s) {
        $dirs = Get-ChildItem $s -Directory
        foreach ($d in $dirs) {
            $src = Join-Path $d.FullName "figure-typst"
            if (Test-Path $src) {
                $dest = "content/book/" + $d.Name + "_files/figure-typst"
                [System.IO.Directory]::CreateDirectory($dest) | Out-Null
                Copy-Item (Join-Path $src "*") $dest -Force
            }
        }
    }
}
Write-Output "Synced all figure-typst"
