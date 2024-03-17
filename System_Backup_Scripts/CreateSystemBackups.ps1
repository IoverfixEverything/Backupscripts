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

# Define the path where you want to store the backup (C:\BACKUPS)
$backupParentPath = "C:\BACKUPS"

# Create the parent backup directory if it doesn't exist
New-Item -Path $backupParentPath -ItemType Directory -ErrorAction SilentlyContinue
Start-Sleep -Seconds 5
if ($?) {
    Write-Host "`nSuccess: Created parent backup directory: $backupParentPath`n" -ForegroundColor Green
} else {
    Write-Host "`nError: Failed to create parent backup directory: $backupParentPath`n" -ForegroundColor Red
    Exit
}

# Define the paths for specific backup folders
$registryBackupPath = Join-Path -Path $backupParentPath -ChildPath "Registry_Backups"
$bcdBackupPath = Join-Path -Path $backupParentPath -ChildPath "Bcd_Backups"
$powercfgBackupPath = Join-Path -Path $backupParentPath -ChildPath "Powercfg_Backups"

# Create the specific backup directories if they don't exist
New-Item -Path $registryBackupPath -ItemType Directory -ErrorAction SilentlyContinue
New-Item -Path $bcdBackupPath -ItemType Directory -ErrorAction SilentlyContinue
New-Item -Path $powercfgBackupPath -ItemType Directory -ErrorAction SilentlyContinue
Start-Sleep -Seconds 5
if ($?) {
    Write-Host "`nSuccess: Created Registry backups directory: $registryBackupPath`n" -ForegroundColor Green
    Write-Host "`nSuccess: Created BCD backups directory: $bcdBackupPath`n" -ForegroundColor Green
    Write-Host "`nSuccess: Created Powercfg backups directory: $powercfgBackupPath`n" -ForegroundColor Green
    Write-Host "`n`n_-_-_-_-_-_-_-_-_-_-_-_" -ForegroundColor Red
} else {
    Write-Host "`nError: Failed to create one or more backup directories.`n" -ForegroundColor Red
    Exit
}

# Define the path for the powercfg executable
$powercfgPath = Get-Command -Name powercfg -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Source

# Check if powercfg is found
if ($powercfgPath -eq $null) {
    Write-Host "`nError: Powercfg executable not found. Please ensure that Powercfg is installed on your system.`n" -ForegroundColor Red
    Exit
}

# Visual break
Write-Host "`nBackup process starting..." -ForegroundColor Red

# Define the path where you want to store the backup (C:\RegistryBackup)
$registryBackupPath = Join-Path -Path $backupParentPath -ChildPath "Registry_Backups"

# Create the backup directory if it doesn't exist
New-Item -Path $registryBackupPath -ItemType Directory -ErrorAction SilentlyContinue
Start-Sleep -Seconds 5
if ($?) {
    Write-Host "`nSuccess: Created Registry backups directory: $registryBackupPath`n" -ForegroundColor Green
} else {
    Write-Host "`nError: Failed to create Registry backups directory: $registryBackupPath`n" -ForegroundColor Red
    Exit
}

# Define the name for the backup file
$backupFileName = "RegistryBackup_$(Get-Date -Format 'yyyyMMdd_HHmmss').reg"

# Create the backup of the registry
reg export HKLM\Software $registryBackupPath\$backupFileName
Start-Sleep -Seconds 5
if ($LastExitCode -eq 0) {
    Write-Host "`nSuccess: Registry backup created successfully at: $registryBackupPath\$backupFileName`n" -ForegroundColor Green
} else {
    Write-Host "`nError: Failed to create registry backup.`n" -ForegroundColor Red
    Exit
}

# Check if the backup was successful
if (Test-Path -Path "$registryBackupPath\$backupFileName") {
    Write-Host "`nSuccess: Backup file found at: $registryBackupPath\$backupFileName`n" -ForegroundColor Green
} else {
    Write-Host "`nError: Backup file not found.`n" -ForegroundColor Red
    Exit
}

# Backup powercfg settings

# Define the path for the powercfg backup file
$powercfgBackupFilePath = Join-Path -Path $powercfgBackupPath -ChildPath "PowercfgBackup_$(Get-Date -Format 'yyyyMMdd_HHmmss').txt"

# Create the backup of powercfg settings
& $powercfgPath /query > $powercfgBackupFilePath
Start-Sleep -Seconds 5
if ($?) {
    Write-Host "`nSuccess: Powercfg backup created successfully at: $powercfgBackupFilePath`n" -ForegroundColor Green
} else {
    Write-Host "`nError: Failed to create powercfg backup.`n" -ForegroundColor Red
    Exit
}

# Check if the backup was successful
if (Test-Path -Path $powercfgBackupFilePath) {
    Write-Host "`nSuccess: Powercfg backup file found at: $powercfgBackupFilePath`n" -ForegroundColor Green
} else {
    Write-Host "`nError: Powercfg backup file not found.`n" -ForegroundColor Red
    Exit
}

# Backup BCD settings

# Define the path for the BCD backup file
$bcdBackupFilePath = Join-Path -Path $bcdBackupPath -ChildPath "BCDBackup_$(Get-Date -Format 'yyyyMMdd_HHmmss').bcd"

# Create the backup of BCD settings
& bcdedit /export $bcdBackupFilePath
Start-Sleep -Seconds 5
if ($?) {
    Write-Host "`nSuccess: BCD backup created successfully at: $bcdBackupFilePath`n" -ForegroundColor Green
} else {
    Write-Host "`nError: Failed to create BCD backup.`n" -ForegroundColor Red
    Exit
}

# Check if the backup was successful
if (Test-Path -Path $bcdBackupFilePath) {
    Write-Host "`nSuccess: BCD backup file found at: $bcdBackupFilePath`n" -ForegroundColor Green
} else {
    Write-Host "`nError: BCD backup file not found.`n" -ForegroundColor Red
    Exit
}

# Prompt the user to press Enter to exit
Write-Host "`nYou are Safe now... Press Enter to exit...`n"
$null = Read-Host
