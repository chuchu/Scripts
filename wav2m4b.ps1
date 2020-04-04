param
(
	[String] $inFolder,
	[String] $outFolder
)

if(-Not (Test-Path $outFolder))
{
    New-Item -ItemType directory -Path $OutFolder
}

$files = [System.Collections.Generic.List[System.IO.FileInfo]](get-childitem -filter *.wav $inFolder)

$params = @()
$params += "-br"
$params += 65536 # Bit per second
$params += "-2pass"

foreach( $file in $files )
{
    Write-Host $file
    $params += "-if"
    $params += $file.FullName
}

$params += "-of"
$params +=  Join-Path -path $outFolder -child "audiobook.mp4"
neroaacenc $params

# Write-Host "Renaming chapters"
# if( $fileNumber -eq 1 )
# {
# 	return
# }
	
# for( $i=1; $i -le $fileNumber; $i++ )
# {
# 	$params = @()
# 	$params += $audiobookFile
# 	$params += "-chapter:$i"
# 	$params += "-meta:title=Kapitel $i"
	
# 	neroaactag $params
# }

# Write-Host "Converting chapters from nero to apple format"
# $params = @()
# $params += "-c"
# $params += "-Q"
# $params += $audiobookFile
# mp4chaps $params

# Write-Host "Rename audio book file to m4b"
# $fileWithoutExtension = $audiobookFile.Substring( 0, $audiobookFile.Length - $m4b.Length )
# $newFileName = $fileWithoutExtension + $m4b
# Rename-Item $audiobookFile $newFileName