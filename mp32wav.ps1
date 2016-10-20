$Mp3Extension = ".mp3"
$WavExtension = ".wav"
$OutFolder = "wav"

if( Test-Path $OutFolder )
{
	Write-Host "Out folder already exists."
	return
}
else
{
	New-Item -ItemType directory -Path $OutFolder
}

$Files = get-childitem -filter *.mp3

for ( $i = 0; $i -lt $Files.Count; $i++ )
{
	$CurrentFile = $Files[$i]
	
	$WavFileName = [io.path]::ChangeExtension($CurrentFile.FullName, $WavExtension)	
		
	$Params = @()
	$Params += "--decode"
	$Params += $CurrentFile.Name
	$Params += $WavFileName	
	lame $Params
	
	Move-Item $WavFileName $OutFolder
}