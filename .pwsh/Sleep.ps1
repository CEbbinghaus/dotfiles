param (
	[switch]$shutdown = $false,
	$time
)

function GetRemainingFromSeconds {
	param (
		[int]$total
	)

	$seconds = $total % 60
	$total = [math]::Floor($total / 60)
	$minutes = $total % 60
	$hours = [math]::Floor($total / 60)

	return ($hours, $minutes, $seconds);
}

function WriteRemaingTime {
	param (
		$cursorPos,
		[int]$total
	)

	($hours, $minutes, $seconds) = GetRemainingFromSeconds $total

	[Console]::SetCursorPosition($cursorPos.X, $cursorPos.Y - 1);

	$time = ""
	if($hours -gt 0){
		$time += "$hours`:"
	}
	if ($hours -gt 0 -or $minutes -gt 0) {
		if($time -eq ""){
			$time += "$minutes`:"
		}else{
			$time += "$($minutes.ToString('00'))`:"
		}
	}
	
	$time += $seconds.ToString('00')

	[Console]::Write("`rRemaining: $time  `n")
}

function SleepTimeout {
	param (
		[int]$Timeout = 3600
	)

	$timer = [Diagnostics.Stopwatch]::StartNew()

	Write-Host ""
	$cursorPos = $host.UI.RawUI.CursorPosition

	WriteRemaingTime $cursorPos $Timeout
	

	while ($timer.Elapsed.TotalSeconds -lt $Timeout) {

		Start-Sleep -Seconds 1

		# Check the time
		$totalSecs = [math]::Round($timer.Elapsed.TotalSeconds, 0)

		# Calulcate how long is left
		$remainingTime = $Timeout - $totalSecs

		# Print remaining time as 
		WriteRemaingTime $cursorPos $remainingTime
	}

	## The action either completed or timed out. Stop the timer.
	$timer.Stop()
}

# No time has been passed in so we ask
if ([string]::IsNullOrWhiteSpace($time)){
	$time = Read-Host -Prompt 'Sleep Time'
}

# No time has been provided so we set the default to 1 hour
if ([string]::IsNullOrWhiteSpace($time)){
	$time = "60"
}

# Variables used for time caluclation
$hours = 0;
$minutes = 0;
$seconds = 0;

Clear-Host

if ($shutdown){
	Write-Output "Shutting down"
}

# Parsing the input and determining how much to sleep for
if($time -match ":"){
	if($time -eq ":"){
		Write-Output "A time must be provided"
		exit 1
	}

	$slots = $time.Split(":");

	switch ($slots.Count) {
		3 { 
			$hours = $slots[0] -as [int]
			$minutes = $slots[1] -as [int]
			$seconds = $slots[2] -as [int]
		}
		2 {
			$hours = $slots[0] -as [int]
			$minutes = $slots[1] -as [int]
		}
		default {
			Write-Output "Wasn't able to Parse time. Aborting"
			exit 1
		}
	}

	if ($null -eq $hours) {
		Write-Output "Hours could not be Parsed"
		exit 1
	}
	if ($null -eq $minutes) {
		Write-Output "Minutes could not be Parsed"
		exit 1
	}
	if ($null -eq $seconds) {
		Write-Output "Seconds could not be Parsed"
		exit 1
	}

	Write-Output "Sleeping in $hours Hours, $minutes Minutes and $seconds Seconds"

}
else{
	if(![int32]::TryParse($time, [ref]$minutes)){
		Write-Output "Failed to parse number"
		exit 1
	}

	Write-Output "Sleeping in $time Minutes"
}

$minutes += $hours * 60;
$seconds += $minutes * 60;

SleepTimeout $seconds
Write-Output "Sleeping..."
if ($shutdown) {
	shutdown /s /f /t 0
} else {
	shutdown /h /f
}