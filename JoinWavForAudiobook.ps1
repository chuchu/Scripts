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

$currentFileNumber = 1;

while( $files.Count -gt 0 )
{
    $params = @()
    
    Write-Host "Adding file $($files[0].FullName)"
    $params += $files[0].FullName
    $currentSize = $files[0].Length
    $files.RemoveAt(0);

    while( $files.Count -gt 0 )
    {
        if(($currentSize + $files[0].Length) -gt 600MB)
        {
            break
        }
        else
        {
            Write-Host "Adding file $($files[0].FullName)"
            $params += $files[0].FullName
            $currentSize += $files[0].Length
            $files.RemoveAt(0);
        }
    }

    $outFileName = "Part" + "{0:D2}" -f $currentFileNumber + ".wav"	
    $params += Join-Path -path $outFolder -child $outFileName
    sox $params
    $currentFileNumber += 1
}