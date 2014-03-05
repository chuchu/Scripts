$job1 = Start-Job -ScriptBlock {
	$sum = 0
	
	for( $i=1; $i -le 1000000; $i++ ) 
	{
		$sum += $i
	}
}

$job2 = Start-Job -ScriptBlock {
	$sum = 0
	
	for( $i=1; $i -le 1000000; $i++ ) 
	{
		$sum += $i
	}
}

$job3 = Start-Job -ScriptBlock {
	$sum = 0
	
	for( $i=1; $i -le 1000000; $i++ ) 
	{
		$sum += $i
	}
}

Wait-Job -id $job1.Id, $job2.Id, $job3.Id

Write-Host "Done"