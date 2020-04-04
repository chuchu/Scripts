param
(
    [String] $inFolder = ".",
    [String] $outFolder
)

if(-Not (Test-Path $outFolder))
{
    New-Item -ItemType directory -Path $OutFolder
}

foreach ($file in get-childitem -filter *.mp3 $inFolder)
{
    $wavFileName = [io.path]::ChangeExtension($file.Name, "wav")

    $params = @()
    $params += "--decode"
    $params += $file.FullName
    $params += Join-Path -Path $outFolder -ChildPath $wavFileName
    lame $params
}