param
(
    [String] $inFile,
    [int] $chapterCount
)

for( $i=1; $i -le $chapterCount; $i++ )
{
    $params = @()
    $params += $inFile
    $params += "-chapter:$i"
    $params += "-meta:title=Kapitel $i"
    neroaactag $params
}

Write-Host "Converting chapters from nero to apple format"
$params = @()
$params += "-c"
$params += "-Q"
$params += $inFile
mp4chaps $params

Write-Host "Rename audio book file to m4b"
[io.path]::ChangeExtension($inFile, "m4b")
Copy-Item $inFile $outFile