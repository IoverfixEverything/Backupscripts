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

# Prompt the user to enter the name of the registry backup file
$backupFileName = Read-Host "Enter the name of the registry backup file (e.g., RegistryBackup_yyyymmdd_hhmmss.reg):"

# Check if the backup file exists
if (-not (Test-Path -Path $backupFileName -PathType Leaf)) {
    Write-Host "`nError: Backup file '$backupFileName' not found.`n" -ForegroundColor Red
    Exit
}

# Run the reg command to restore registry settings from the backup file
Write-Host "`nRestoring registry settings from backup file: $backupFileName`n" -ForegroundColor Yellow
reg import $backupFileName
Start-Sleep -Seconds 5

# Check if the restoration was successful
if ($LastExitCode -eq 0) {
    Write-Host "`nSuccess: Registry settings restored successfully.`n" -ForegroundColor Green
} else {
    Write-Host "`nError: Failed to restore registry settings.`n" -ForegroundColor Red
    Exit
}

# Prompt the user to press Enter to exit
Write-Host "`nPress Enter to exit...`n"
$null = Read-Host
