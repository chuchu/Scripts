param
(
    [String] $tempFolder = [io.path]::Combine( $env:TEMP, "MakeAudioBook", (New-Guid).ToString()),
    [Bool] $tell = $false
)

function TellAndDo($action, $tell)
{
    Write-Host $tell
    
    #if(-Not $tell)
    #{
        Invoke-Command $action
    #}
}

###############################################################################
# Converting all mp3 files to wav
###############################################################################

$outFolderMp3ToWav = [io.path]::Combine($tempFolder ,"wav")

if(-Not (Test-Path $outFolderMp3ToWav))
{
    TellAndDo { New-Item -ItemType directory -Path $outFolderMp3ToWav } "Create folder $outFolderMp3ToWav"
}

foreach ($file in get-childitem -filter *.mp3)
{
    $outFile = [io.path]::Combine($outFolderMp3ToWav, [io.path]::ChangeExtension($file.Name, ".wav"))

    if(Test-Path $outFile)
    {
        Write-Host "'$outFile' already exists. Will be skipped."
        continue
    }
    
    $params = @()
    $params += "--decode"
    $params += $file.Name
    $params += $outFile
    TellAndDo { lame $params } $params
}

###############################################################################
# Converting all wav files to mono wav files
###############################################################################

$outFolderWavToMonoWav = [io.path]::Combine($tempFolder ,"monoWav")

if(-Not (Test-Path $outFolderWavToMonoWav))
{
    TellAndDo { New-Item -ItemType directory -Path $outFolderWavToMonoWav } "Create folder $outFolderWavToMonoWav"
}

foreach( $file in get-childitem -filter *.wav $outFolderMp3ToWav )
{
    $outFile = Join-Path -path $outFolderWavToMonoWav -child $file.Name

    if( Test-Path $outFile )
    {
        Write-Host "'$outFile' already exists. Will be skipped."
        continue
    }

    $params = @()
    $params += $file.FullName
    $params += $outFile
    $params += "remix"
    $params += "1-2"

    TellAndDo { sox $params } $params
}

###############################################################################
# Combine mono wav files for audiobook creation.The files are joined to 600 MB
# junks. In the final audiobook. Each chunk will be chapter.
###############################################################################

$outFolderCombinedWav = [io.path]::Combine($tempFolder ,"combinedWav")

TellAndDo { New-Item -ItemType directory -Path $outFolderCombinedWav } "Create folder $outFolderCombinedWav"

$monoWavFileList = [System.Collections.Generic.List[System.IO.FileInfo]]( get-childitem -filter *.wav $outFolderWavToMonoWav )
$monoWavFileList.Sort()

$currentFileNumber = 1;

while( $monoWavFileList.Count -gt 0 )
{
    $params = @()
    $params += $monoWavFileList[0]	
    $currentSize = $monoWavFileList[0].Length

    $monoWavFileList.RemoveAt( 0 );

    while( $monoWavFileList.Count -gt 0 )
    {
        if(($currentSize + $monoWavFileList[ 0 ].Length) -gt 600MB )
        {
            # Adding the next file would exeed the 600MB limit.
            # So don't do it.
            # Break and start joining this chunk.
            break
        }
        else
        {
            # Add the file and continue.
            $params += $monoWavFileList[ 0 ]
            $currentSize += $monoWavFileList[ 0 ].Length
            $monoWavFileList.RemoveAt( 0 );
        }
    }

    # Join all files for the current chunk.
    $OutFileName = "Part" + "{0:D2}" -f $currentFileNumber + ".wav"
    $params += Join-Path -path $outFolderCombinedWav -child $OutFileName
    TellAndDo { sox $params } $params

    $currentFileNumber += 1
}

exit 0

###############################################################################
# Create the actual audio book.
###############################################################################

$outFolderAudiobook = [io.path]::Combine($tempFolder ,"combinedWav")

TellAndDo { New-Item -ItemType directory -Path $outFolderAudiobook } "Create folder $outFolderAudiobook"

$combinedWavFileList = [System.Collections.Generic.List[System.IO.FileInfo]]( get-childitem -filter *.wav $outFolderCombinedWav )
$combinedWavFileList.Sort()

$params = @()
$params += "-br"
$params += 65536 # Bit per second
$params += "-2pass"

foreach( $file in $combinedWavFileList )
{
    Write-Host $file
    $params += "-if"
    $params += $file
}

$params += "-of"
$audiobookFile = Join-Path -path $outFolderAudiobook -child "Audiobook.$($mp4)"
$params += $audiobookFile
TellAndDo { neroaacenc $params } $params

###############################################################################
# Rename the chapters
###############################################################################

for( $i=1; $i -le $combinedWavFileList; $i++ )
{
    $params = @()
    $params += $audiobookFile
    $params += "-chapter:$i"
    $params += "-meta:title=Kapitel $i"
    TellAndDo { neroaactag $params } $params
}

###############################################################################
# Convert the chapters from nero to apple format.
###############################################################################

Write-Host "Converting chapters from nero to apple format"
$params = @()
$params += "-c"
$params += "-Q"
$params += $audiobookFile
TellAndDo { mp4chaps $params } $params

###############################################################################
# Change the audiobook file extension from mp4 to m4b so that it is considered
# as audiobook by itunes.
###############################################################################

TellAndDo { [io.path]::ChangeExtension($audiobookFile, "m4b") } "Change file extension of $audiobookFile to m4b"

# TellAndDo { Remove-Item $outFolderMp3ToWav } "Delete folder $outFolderMp3ToWav"