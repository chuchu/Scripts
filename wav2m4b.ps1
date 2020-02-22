param
(
	[int] $filesPerAudioBook=1,
	[String] $name="audiobook"
)

$combinedWavFolder = "combinedWav"
$audiobookFolder = "audiobook"
$mp4 = "mp4"
$m4b = "m4b"

# Create out folder
if( Test-Path $combinedWavFolder )
{
	Write-Host "Out folder already exists."
	exit
}
else
{
	New-Item -ItemType directory -Path $combinedWavFolder	
}

# Create out folder
if( Test-Path $audiobookFolder )
{
	Write-Host "Out folder already exists."
	exit
}
else
{
	New-Item -ItemType directory -Path $audiobookFolder	
}

Write-Host "#########################"
Write-Host "Convert wav files to mono"
Write-Host "#########################"
$fileNameList = New-Object "System.Collections.Generic.List``1[System.String]"
foreach( $file in get-childitem -filter *.wav )
{
	$fileNameList.Add( $file.FullName )
}
$fileNameList.Sort()


# Put all wave files into a list and sort it
$fileNameList = New-Object "System.Collections.Generic.List``1[System.String]"
foreach( $file in get-childitem -filter *.wav )
{
	$fileNameList.Add( $file.FullName )
}
$fileNameList.Sort()

Write-Host "Combining wav files ..."
$fileNumber = 1;
while( $fileNameList.Count -gt 0 )
{
	$params = @()

	for( $i=0; $i -lt $filesPerAudioBook -and $fileNameList.Count -gt 0; $i++ )
	{
		Write-Host $fileNameList[0]
		$params += $fileNameList[0]
		$fileNameList.RemoveAt( 0 )
	}

	$outFile = "Part" + "{0:D2}" -f $fileNumber + ".wav"
	Write-Host "Writing file" $outFile
	$params +=  Join-Path -path $combinedWavFolder -child $outFile
	
	$fileNumber = $fileNumber + 1
	
	sox $params
}

Write-Host "Creating audio book ..."
$fileNameList = New-Object "System.Collections.Generic.List``1[System.String]"
foreach( $file in get-childitem $combinedWavFolder -filter *.wav )
{
	$fileNameList.Add( $file.FullName )
}
$fileNameList.Sort()

$params = @()
$params += "-br"
$params += 65536 # Bit per second
$params += "-2pass"

foreach( $file in $fileNameList )
{
		Write-Host $file
		$params += "-if"
		$params += $file
}

$params += "-of"
$audiobookFile = Join-Path -path $audiobookFolder -child "$($name).$($mp4)"
Write-Host "Creating file" 	$audiobookFile
$params +=  $audiobookFile
neroaacenc $params

Write-Host "Renaming chapters"
if( $fileNumber -eq 1 )
{
	return
}
	
for( $i=1; $i -le $fileNumber; $i++ )
{
	$params = @()
	$params += $audiobookFile
	$params += "-chapter:$i"
	$params += "-meta:title=Kapitel $i"
	
	neroaactag $params
}

Write-Host "Converting chapters from nero to apple format"
$params = @()
$params += "-c"
$params += "-Q"
$params += $audiobookFile
mp4chaps $params

Write-Host "Rename audio book file to m4b"
$fileWithoutExtension = $audiobookFile.Substring( 0, $audiobookFile.Length - $m4b.Length )
$newFileName = $fileWithoutExtension + $m4b
Rename-Item $audiobookFile $newFileName