param(
    [string] $sourceFolder,
    [string] $targetFolder,
    [string] $handbrakeCLI = "E:\Program Files\Handbrake\HandBrakeCLI.exe"
)

function GetMatchOrEmptyStringFromFile([string]$file, [string]$regex)
{
    $matches = select-string -path $file -pattern $regex -AllMatches

    if( $matches.Matches.Count -gt 0 )
    {
        if( $matches.Matches[0].Count -gt 0 )
        {
            if( $matches.Matches[0].Groups.Count -gt 1 )
            {
                $matches.Matches[0].Groups[1].Value
            }
        }
    }
}

function ProcessFolder($folder)
{
    $currentTargetFolder = "$($targetFolder)\$($folder.Parent.Name)"
    if ( -Not ( Test-Path $currentTargetFolder ) )
    {
	    md -Path $currentTargetFolder
    }    
    
    $handbrakeProcessOut = "$($env:temp)\$([System.Guid]::NewGuid().ToString()).txt"

    & $handbrakeCLI --input $folder.FullName --scan *>&1 > "$($handbrakeProcessOut)"

    $numberOfTitles = GetMatchOrEmptyStringFromFile $handbrakeProcessOut ".*has (\d*) title.*"

    for( $i=1; $i -le $numberOfTitles; $i++ )
    {
        & $handbrakeCLI --input $folder.FullName --scan --title $i *>&1 > "$($handbrakeProcessOut)"    

        $german_index = GetMatchOrEmptyStringFromFile $handbrakeProcessOut ".*\+\s(\d*),\sDeutsch.*ch.*"        
                
        if( !$german_index )
        {
            continue;
        }

        $chapter_file = "$($env:temp)\$([System.Guid]::NewGuid().ToString()).csv"

        $outFile = "$($targetFolder)\$($folder.Parent.Name)\$($i).mp4"
    
        & $handbrakeCLI -i $folder.FullName -t $i --angle 1 -c 1-2 -o "$($currentTargetFolder)\$($i).mp4" -f mp4  --deinterlace="slow" -w 720 --crop 0:2:0:0 --loose-anamorphic  --modulus 2 -e x264 -q 25 --vfr -a $german_index -E av_aac -6 dpl2 -R Auto -B 160 -D 0 --gain 0 --audio-fallback ac3 --markers=$chapter_file --encoder-preset=veryfast  --encoder-level="4.0"  --encoder-profile=main

        If (test-path $chapter_file)
        {
	        remove-item $chapter_file
        }        
    }

    If (test-path $handbrakeProcessOut)
    {
	    remove-item $handbrakeProcessOut
    }
}

foreach( $videoTSFolder in gci $sourceFolder -Recurse -Filter "VIDEO_TS")
{    
    ProcessFolder( $videoTSFolder )
}