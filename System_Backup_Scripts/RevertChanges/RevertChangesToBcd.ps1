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
Start-Sleep -Seconds 5
if ($?) {
    Write-Host "`nSuccess: Set execution policy to unrestricted.`n" -ForegroundColor Green
} else {
    Write-Host "`nError: Failed to set execution policy to unrestricted.`n" -ForegroundColor Red
    Exit
}

# Define the path where the BCD backup files are located
$bcdBackupPath = "C:\BACKUPS\Bcd_Backups"  # Update this path if necessary

# Check if the BCD backup directory exists
if (-not (Test-Path -Path $bcdBackupPath -PathType Container)) {
    Write-Host "`nError: BCD backup directory not found at: $bcdBackupPath`n" -ForegroundColor Red
    Exit
}

# List all available BCD backup files
$backupFiles = Get-ChildItem -Path $bcdBackupPath -Filter "*.bcd" | Select-Object -ExpandProperty FullName

# Check if any BCD backup files are found
if ($backupFiles.Count -eq 0) {
    Write-Host "`nError: No BCD backup files found in directory: $bcdBackupPath`n" -ForegroundColor Red
    Exit
}

# Prompt the user to choose a BCD backup file
Write-Host "`nAvailable BCD backup files:`n"
for ($i = 0; $i -lt $backupFiles.Count; $i++) {
    Write-Host "$($i + 1). $($backupFiles[$i])"
}
$choice = Read-Host "Enter the number corresponding to the desired backup file"

# Validate the user's choice
if ($choice -lt 1 -or $choice -gt $backupFiles.Count) {
    Write-Host "`nError: Invalid choice. Please enter a number between 1 and $($backupFiles.Count)`n" -ForegroundColor Red
    Exit
}

# Select the chosen backup file
$chosenBackupFile = $backupFiles[$choice - 1]

# Revert changes to the BCD settings
& bcdedit /import $chosenBackupFile
Start-Sleep -Seconds 5
if ($?) {
    Write-Host "`nSuccess: BCD settings reverted using backup file: $chosenBackupFile`n" -ForegroundColor Green
} else {
    Write-Host "`nError: Failed to revert BCD settings.`n" -ForegroundColor Red
    Exit
}

# Prompt the user to press Enter to exit
Write-Host "`nPress Enter to exit...`n"
$null = Read-Host
