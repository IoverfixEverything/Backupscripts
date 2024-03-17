# Check if the script is running with elevated privileges, if not, relaunch it with elevated privileges and unrestricted execution policy

if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "`nScript is not running with elevated privileges. Relaunching with elevated privileges...`n"
    Start-Process powershell.exe -Verb RunAs -ArgumentList "-ExecutionPolicy Bypass -File `"$PSCommandPath`""
    Exit
}

# Set execution policy to unrestricted for the current session

Set-ExecutionPolicy -Scope Process -ExecutionPolicy Unrestricted -Force

Start-Sleep -Seconds 2

if ($?) {
    Write-Host "`nSuccess: Set execution policy to unrestricted.`n"
} else {
    Write-Host "`nError: Failed to set execution policy to unrestricted.`n"
    Exit
}

# Define the path where you want to store the backup (C:\RegistryBackup)

$backupPath = "C:\RegistryBackup"

# Create the backup directory if it doesn't exist

New-Item -Path $backupPath -ItemType Directory -ErrorAction SilentlyContinue

Start-Sleep -Seconds 2

if ($?) {
    Write-Host "`nSuccess: Created backup directory: $backupPath`n"
} else {
    Write-Host "`nError: Failed to create backup directory: $backupPath`n"
    Exit
}

# Define the name for the backup file

$backupFileName = "RegistryBackup_$(Get-Date -Format 'yyyyMMdd_HHmmss').reg"

# Create the backup of the registry

reg export HKLM\Software $backupPath\$backupFileName

Start-Sleep -Seconds 2

if ($LastExitCode -eq 0) {
    Write-Host "`nSuccess: Registry backup created successfully at: $backupPath\$backupFileName`n"
} else {
    Write-Host "`nError: Failed to create registry backup.`n"
    Exit
}

# Check if the backup was successful

if (Test-Path -Path "$backupPath\$backupFileName") {
    Write-Host "`nSuccess: Backup file found at: $backupPath\$backupFileName`n"
} else {
    Write-Host "`nError: Backup file not found.`n"
    Exit
}

# Prompt the user to press Enter to exit

Write-Host "`nPress Enter to exit...`n"

$null = Read-Host
