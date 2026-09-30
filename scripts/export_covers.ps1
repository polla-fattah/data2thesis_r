$ppt = New-Object -ComObject PowerPoint.Application
$ppt.Visible = [Microsoft.Office.Core.MsoTriState]::msoTrue
$pptxPath = (Resolve-Path "Data2thesisBookCover.pptx").Path
$presentation = $ppt.Presentations.Open($pptxPath, $true, $false, $false)
Write-Output ("Slide Count: " + $presentation.Slides.Count)
Write-Output ("Slide Width: " + $presentation.PageSetup.SlideWidth)
Write-Output ("Slide Height: " + $presentation.PageSetup.SlideHeight)

$imagesDir = (Resolve-Path "images").Path
$frontCover = Join-Path $imagesDir "cover-front.png"
$backCover = Join-Path $imagesDir "cover-back.png"
$backCoverJpg = Join-Path $imagesDir "cover-back.jpg"

# 2160 x 2880 gives crisp high-res 4x export (aspect ratio 3:4)
# Let's check slide dimensions: 540 x 720 -> 2160 x 2880
$slideWidth = [int]($presentation.PageSetup.SlideWidth * 4)
$slideHeight = [int]($presentation.PageSetup.SlideHeight * 4)

Write-Output ("Exporting at " + $slideWidth + " x " + $slideHeight)
$presentation.Slides.Item(1).Export($frontCover, "PNG", $slideWidth, $slideHeight)
$presentation.Slides.Item(2).Export($backCover, "PNG", $slideWidth, $slideHeight)
$presentation.Slides.Item(2).Export($backCoverJpg, "JPG", $slideWidth, $slideHeight)

$presentation.Close()
$ppt.Quit()
[System.Runtime.InteropServices.Marshal]::ReleaseComObject($presentation) | Out-Null
[System.Runtime.InteropServices.Marshal]::ReleaseComObject($ppt) | Out-Null

Get-Item $frontCover, $backCover, $backCoverJpg | Select-Object Name, Length, LastWriteTime
