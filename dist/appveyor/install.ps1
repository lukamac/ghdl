Write-Host "Installing dependencies ..." -Foreground Yellow
Write-Host "  Installing MinGW64 packages ..." -Foreground Yellow
C:\msys64\usr\bin\pacman -V
# list installed packages and versions
# C:\msys64\usr\bin\pacman -Q
C:\msys64\usr\bin\pacman -S mingw-w64-x86_64-llvm35 mingw-w64-x86_64-clang35 --noconfirm

Write-Host "  Installing PSGet ..." -Foreground Yellow
Invoke-WebRequest "http://psget.net/GetPsGet.ps1" -UseBasicParsing | Invoke-Expression
Write-Host "  Installing Chocolatey ..." -Foreground Yellow
Invoke-WebRequest https://chocolatey.org/install.ps1 -UseBasicParsing | Invoke-Expression

Write-Host "  Installing PowerShell modules ..." -Foreground Yellow
Install-Module -Name Pscx

Write-Host "  Check all Write-* CmdLets ..." -Foreground Yellow
Get-Command -Verb Write | Format-Table

exit $LastExitCode
