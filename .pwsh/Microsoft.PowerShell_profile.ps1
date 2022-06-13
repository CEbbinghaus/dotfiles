Invoke-Expression (&starship init powershell)

if($PWD.Path -eq "C:\WINDOWS\system32") {
  Set-Location ~
}


Clear-Host

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

function ReloadProfile {
  . $profile
}