param
(
    [String] $inFolder = ".",
    [String] $outFolder
)

if(-Not (Test-Path $outFolder))
{
    New-Item -ItemType directory -Path $OutFolder
}

foreach( $file in get-childitem -filter *.wav $inFolder )
{
    $params = @()
    $params += $file.FullName
    $params += Join-Path -path $outFolder -child $file.Name
    $params += "remix"
    $params += "1-2"
    sox $params
}