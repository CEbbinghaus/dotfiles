# Set global encoding to UTF8
$global:OutputEncoding = [Console]::InputEncoding = [Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$PSDefaultParameterValues['*:Encoding'] = 'utf8'
 
# We override the $Profile variable to allow for continued easy access to this file from any powershell instance
# Yes we are overriding a built in variable but that is just required in this case. Makes no sense to not
$Profile = "$($MyInvocation.MyCommand.Path)"

Clear-Host *> $null

# If Clear-Host fails we know that this is a non GUI environment so we don't need to load any of the profile.
if(-not $?) {
	return;
}

# Load aliases defined in a seperate file
. "$PSScriptRoot/Aliases.ps1"


# if (Get-Command "oh-my-posh" -ErrorAction SilentlyContinue) {
# 	oh-my-posh init pwsh --config "~/.config/oh-my-posh.json"| Invoke-Expression
# }
# else
if(Get-Command "starship" -ErrorAction SilentlyContinue) {
	Invoke-Expression (&starship init powershell) -ErrorAction SilentlyContinue
}

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

function touch {
	param([string]$Path)
	Write-Output $null >> $Path
}

function GetFileExtension {
	param([string]$Path)
	return (Split-Path -Path $Path -Leaf).Split(".")[1];
}

function Convert {
	param(
		[string]$From,
		[string]$To
	)

	Write-Host "Converting $From -> $To"

	if(-not $From) {
		throw "No From value was provided"
	}

	if(-not $To) {
		throw "No to value was provided"
	}

	$From = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($From)
	$To = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($To)

	Add-Type -AssemblyName System.Drawing
	$imageFormat = "System.Drawing.Imaging.ImageFormat" -as [type]

	$supportedFormats = @{
		"jpg" = $imageFormat::Jpeg
		"jpeg" = $imageFormat::Jpeg
		"png" = $imageFormat::Png
		"bmp" = $imageFormat::Bmp
		"exif" = $imageFormat::Exif
		"heif" = $imageFormat::Heif
		"ico" = $imageFormat::Icon
		"tif" = $imageFormat::Tiff
		"tiff" = $imageFormat::Tiff
		"webp" = $imageFormat::Webp
	}

	$fromType = $supportedFormats[(GetFileExtension $From).ToLower()]
	$toType = $supportedFormats[(GetFileExtension $To).ToLower()]

	if(-not $fromType) {
		throw "From value isn't a valid file type"
	}

	if(-not $toType) {
		throw "To value isn't a valid file type"
	}

	$image = [Drawing.Image]::FromFile($From)

	if($image) {
		$image.Save($To, $toType)
	} else {
		Write-Error "There was a problem Loading the image. See output above"
	} 
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

function Link {
	param (
		[string]$Source,
		[string]$Destination,
		[switch]$Directory = $false,
		[switch]$Hard = $false,
		[switch]$Junction = $false
	)

	if (-not $Destination) {
		Write-Error "Destination was not specified"
		return
	}

	if (-not $Source) {
		Write-Error "Source was not specified"
		return
	}

	$isAdmin = IsAdministrator

	if($isAdmin) {
		Write-Output "Running as Administrator..."
	}

	$command = "mklink"

	if($Directory) {
		$command += " /D"
	}
	if($Hard) {
		$command += " /H"
	}
	if($Junction) {
		$command += " /J"
	}

	$command += " `"$($ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($Destination))`" `"$(Resolve-Path $Source)`""

	if($isAdmin) {
		&cmd /c "$command"
	} else {
		sudo cmd /c "$command"
	}
}


# function Global:prompt {
# }

function GlobalProtect
{
	Start-Job {  &"~/services/GlobalProtect.ps1" *> $null } *> $null
}

function CopyAnalyzers {
	Push-Location /git/wtg/CargoWise/Shared/CargoWise.Analyzers
	dotnet build *> $null

	Copy-Item -Force bin/CargoWise.Analyzers.dll /git/wtg/CargoWise/Dev/packages/build/CargoWise.Analyzers/analyzers/dotnet/cs
	Pop-Location
}

function ConvertClipboard {
	[Reflection.Assembly]::LoadWithPartialName('System.Web')
    $linkName = Get-Clipboard
    $rawLink = Get-Clipboard -TextFormatType Rtf
    $rawLink[2] -match 'ControllerID=(\w+)&BusinessEntityPK=([0-9a-f\-]+)&'
    $type = $Matches[1]
    $id = $Matches[2]
    Write-Host $type 
    Write-Host $id
    $type = [System.Web.HttpUtility]::UrlEncode($type)
    $id = [System.Web.HttpUtility]::UrlEncode($id)
    $htmlContent = '<a href=\"https://svc-ediprod.wtg.zone/Services/link/ShowEditForm/{0}/{1}?lang=en-gb\" target="_blank">{2}</a>' -f $type,$id,$linkName
    Set-Clipboard -Value $htmlContent -AsHtml
}

function ShuffleBag {
	param(
		[string[]]$Items
	)

	$Items = $Items | Sort-Object {Get-Random}

	do {
		$value, $rest = $Items
		$Items = $rest | Sort-Object {Get-Random}
		Write-Host $value

		while($Items.Length -gt 0 -and $host.UI.RawUI.ReadKey('IncludeKeyDown, NoEcho').VirtualKeyCode -ne 13){}
	} while ($Items.Length -gt 0)
}

function Get-Cache() {
  param (
    [switch]
    $Release = $false,
    [int]
    [Alias("O")]
    [ValidateRange(0, 3)]
    $MatchLevel = 0
  )

  $version = if ( $Release ) { "Release" } else { "Debug" };
  
  if($MatchLevel -gt 0)
  {
    Write-Warning "Using a less accurate matcher might result in downloading the wrong build. Please verify the integrity manually after."
  }

  &git rev-parse --is-inside-work-tree *> $null
  
  # The previous command existed abnormally (We are not in a git repository)
  if(-not $?)
  {
    Write-Output "Not in a git repository..."
    return
  }

  $rootDir = git rev-parse --show-toplevel

  $remoteUrl =  (git config --get remote.origin.url).Split("/");
  $category = $remoteUrl[-3]
  $project = $remoteUrl[-1]

  $hash = git rev-parse HEAD

  
  $basePath = "\\datfiles.wtg.zone\CrikeyMonitor\QGLByProject\*"
  $matchers = ("*$category`_$project`_$hash$version.zip", "*$project`_$hash$version.zip", "*$hash$version.zip", "*$hash*.zip")

  $matcher = $matchers[$MatchLevel]

  $files = Get-ChildItem -Path $basePath -Filter $matcher | Where-Object -FilterScript { $_.Length -gt 0 }

  # No files could be found
  if($files.Length -eq 0) {
    Write-Output "Cache Miss. Sorry there is no cached build for this commit"
    return
  }
 
  # TODO: Figure out what the fuck the best one of the files is

  $hit = $files | Where-Object -FilterScript { $_.Name -like "C_git_wtg_*"} | Select-Object -First 1;

  if( -not $hit ) {
    Write-Warning "Could not find a match in the Preferred Location. Resorting to something else..."
    $hit = $files[0] 
  }
  
  $path = $hit.FullName;
  
  Write-Output "Cached build found at: `n    $path $(Format-FileSize $hit.Length)"

  if (-not $path -like "*$version*" ) {
    Write-Warning "!!! File Path did not contain $version"
  }

  $binDir = Join-Path $rootDir Bin

  Write-Output "Deleting existing bin directory"

  Remove-Item -Recurse -Force $binDir

  Write-Output "Finished deleting bin directory"
  Write-Output "Unzipping Build Artifact..."

  # Expand-Archive $path -DestinationPath $binDir
  # [System.IO.Compression.ZipFile]::ExtractToDirectory($path, $binDir)
  &7z.exe e "$path" -o"$binDir" -y -bso0 -bsp0

  Write-Output "Done"

}

function Authenticate {
  param (
	[switch]$Cold
  )
  
  if($Cold) {
	Start-Job { emulator -avd Authenticator -noaudio -no-snapshot-load *> $null } *> $null
	return;
  }
  Start-Job { emulator -avd Authenticator -noaudio *> $null } *> $null
}

function Clean {

  $files = ("DBUPG_SkipUpgradeDbs.txt")

  &git rev-parse --is-inside-work-tree *> $null
  
  # The previous command existed abnormally (We are not in a git repository)
  if(-not $?)
  {
	Write-Output "Not in a git repository..."
	return
  }

  $currentDir = $pwd.Path
  $rootDir = git rev-parse --show-toplevel

  Set-Location $rootDir
  
  foreach($file in $files) {
	Move-Item "$file" "../"
  }
  Write-Output "Moved files out"
  
  Write-Output "Cleaning..."
  &git clean -xfd *> $null
  
  foreach($file in $files) {
	Move-Item "../$file" "./"
  }
  Write-Output "Moved files back in"
  
  Set-Location $currentDir
  
  Write-Output "Done"
}

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
