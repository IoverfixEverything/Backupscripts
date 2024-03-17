# Change the background color to black
$Host.UI.RawUI.BackgroundColor = "Black"
Clear-Host

# Check if the script is running with elevated privileges, if not, relaunch it with elevated privileges and unrestricted execution policy
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "`nScript is not running with elevated privileges. Relaunching with elevated privileges...`n" -ForegroundColor Yellow
    Start-Process powershell.exe -Verb RunAs -ArgumentList "-ExecutionPolicy Bypass -File `"$PSCommandPath`""
    Exit
}

# Set execution policy to unrestricted for the current session
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Unrestricted -Force
if ($?) {
    Write-Host "`nSuccess: Set execution policy to unrestricted.`n" -ForegroundColor Green
} else {
    Write-Host "`nError: Failed to set execution policy to unrestricted.`n" -ForegroundColor Red
    Exit
}

# Prompt the user to enter the name of the backup file
$backupFileName = Read-Host "Enter the name of the backup file (e.g., PowercfgBackup_yyyymmdd_hhmmss.txt):"

# Check if the backup file exists
if (-not (Test-Path -Path $backupFileName -PathType Leaf)) {
    Write-Host "`nError: Backup file '$backupFileName' not found.`n" -ForegroundColor Red
    Exit
}

# Run the powercfg command to restore settings from the backup file
Write-Host "`nRestoring powercfg settings from backup file: $backupFileName`n" -ForegroundColor Yellow
& powercfg /restore $backupFileName

# Check if the restoration was successful
if ($?) {
    Write-Host "`nSuccess: Powercfg settings restored successfully.`n" -ForegroundColor Green
} else {
    Write-Host "`nError: Failed to restore powercfg settings.`n" -ForegroundColor Red
    Exit
}

# Prompt the user to press Enter to exit
Write-Host "`nPress Enter to exit...`n"
$null = Read-Host
