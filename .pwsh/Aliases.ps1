
# Aliases
Set-Alias vim nvim
Set-Alias which Get-Command

# If docker isn't installed but podman is then alias docker to podman
if ((Get-Command podman -ErrorAction SilentlyContinue) -and -not (Get-Command docker -ErrorAction SilentlyContinue))
{
	Set-Alias docker podman
}
