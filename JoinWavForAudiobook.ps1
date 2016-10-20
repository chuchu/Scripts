$OutFolder = "combined"

if( Test-Path $OutFolder )
{
	Write-Host "Out folder already exists."
	return
}
else
{
	New-Item -ItemType directory -Path $OutFolder
}

$Files = [System.Collections.Generic.List[System.IO.FileInfo]]( get-childitem -filter *.wav )

Write-Host "File Count" $Files.Count

$CurrentFileNumber = 1;

while( $Files.Count -gt 0 )
{
	$Params = @()
	$Params += $Files[ 0 ]	
	$CurrentSize = $Files[ 0 ].Length
	#Write-Host "Adding file" $Files[ 0 ].Name	
	#Write-Host "Current file size is" $CurrentSize
	$Files.RemoveAt( 0 );
		
	while( $Files.Count -gt 0 )
	{
		if( ( $CurrentSize + $Files[ 0 ].Length ) -gt 600MB )
		{
			break
		}
		else
		{
			$Params += $Files[ 0 ]
			$CurrentSize += $Files[ 0 ].Length
			#Write-Host "Adding file" $Files[ 0 ].Name			
			#Write-Host "Current file size is" $CurrentSize
			$Files.RemoveAt( 0 );
		}		
	}
	
	$OutFileName = "Part" + "{0:D2}" -f $CurrentFileNumber + ".wav"	
	#Write-Host "Write out file" $OutFileName
	$Params += Join-Path -path $OutFolder -child $OutFileName
	sox $Params
	$CurrentFileNumber += 1
}