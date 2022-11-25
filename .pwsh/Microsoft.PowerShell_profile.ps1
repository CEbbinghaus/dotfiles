Clear-Host *> $null

# If Clear-Host fails we know that this is a non GUI environment so we don't need to load any of the profile.
if(-not $?) {
	return;
}

Invoke-Expression (&starship init powershell) -ErrorAction SilentlyContinue
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

if($PWD.Path -eq "C:\WINDOWS\system32") {
  Set-Location ~
}

# Chocolatey profile
$ChocolateyProfile = "$env:ChocolateyInstall\helpers\chocolateyProfile.psm1"
if (Test-Path($ChocolateyProfile)) {
  Import-Module "$ChocolateyProfile"
}

function ConvertMp4ToMkv {
  param (
	[string]$FilePath
  )

  if (-not(Test-Path -Path $FilePath -PathType Leaf)) {
	Write-Host "File $FilePath doesn't exist";
	return;
  }

  $File = Get-Item $FilePath 

  $InFile = join-path $File.DirectoryName $File.Name;
  $OutFile = join-path $File.DirectoryName ($File.BaseName + ".mkv");

  ffmpeg -i "$InFile" -vcodec copy -acodec copy "$OutFile"
}

function config()
{
	&git --git-dir=$HOME/.cfg/ --work-tree=$HOME $args
}

function Reload {
  . $Profile
}

function IsAdministrator {
	$user = [Security.Principal.WindowsIdentity]::GetCurrent();
	return (New-Object Security.Principal.WindowsPrincipal $user).IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)
}

function Format-FileSize() {
  Param ([int64]$size, [switch]$Fixed = $false, [int]$DecimalPlaces = 2)
  $char = if ($Fixed) {"0"} else {"#"}
  $format = "{0:0.$($char * $DecimalPlaces)}"
  If     ($size -ge 1PB) {[string]::Format("$format`PB", $size / 1PB)}
  ElseIf ($size -ge 1TB) {[string]::Format("$format`TB", $size / 1TB)}
  ElseIf ($size -ge 1GB) {[string]::Format("$format`GB", $size / 1GB)}
  ElseIf ($size -ge 1MB) {[string]::Format("$format`MB", $size / 1MB)}
  ElseIf ($size -ge 1KB) {[string]::Format("$format`kB", $size / 1KB)}
  ElseIf ($size -ge 0)   {[string]::Format("{0}B", $size)}
  Else                   {""}
}

# function Global:prompt {
# }

function Array-To-Object
{
	[CmdletBinding()]
	param (
		[Parameter(Mandatory)]
		# allow string arrays:
		[string[]]
		$Keys,
		[Parameter(Mandatory,ValueFromPipeline)]
		[object[]]
		$Values
	)
	process
	{
		if($Values -isnot [System.Array])
		{
			Write-Error "Not a Array"
			return $null
		}
		
		$table = [ordered]@{}
		
		for($i = 0; $i -lt $Keys.Count -and $i -lt $Values.Count; ++$i)
		{
			$table.add($Keys[$i], $Values[$i]); 
		}
		
		return [pscustomobject]$table
	}
}
