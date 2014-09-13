$wavExtension = ".wav"
$outFolder = "out"

if( Test-Path $outFolder )
{
	Write-Host "Out folder already exists."
	exit
}
else
{
	New-Item -ItemType directory -Path $outFolder	
}

foreach( $file in get-childitem -filter *$wavExtension )
{	
	Write-Hoste "Converting $file.Name"
	
	$params = @()
	$params += $file.Name
	$params += Join-Path -path $outFolder -child $file.Name
	$params += "remix"
	$params += "1-2"
			
	sox $params	
}