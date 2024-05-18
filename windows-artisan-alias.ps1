function Test-Admin {
    $currentUser = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
    return $currentUser.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

function Create-AliasFile {
    param (
        [string]$alias,
        [string]$directory
    )

    # Create the new alias file
    $aliasFile = "$directory\$alias.bat"
    Set-Content -Path $aliasFile -Value "@echo off`nphp artisan %*"
    Write-Output "Alias '$alias' created successfully."
    return $true
}

function Add-ToPath {
    param (
        [string]$directory
    )
    $existingPath = [System.Environment]::GetEnvironmentVariable('Path', 'Machine')
    if ($existingPath -notlike "*$directory*") {
        $newPath = "$existingPath;$directory"
        [System.Environment]::SetEnvironmentVariable('Path', $newPath, [System.EnvironmentVariableTarget]::Machine)
        Write-Output "Directory '$directory' added to PATH."
    }
}

function Remove-FromPath {
    param (
        [string]$directory
    )
    $existingPath = [System.Environment]::GetEnvironmentVariable('Path', 'Machine')
    if ($existingPath -like "*$directory*") {
        $newPath = ($existingPath -split ';') -ne $directory -join ';'
        [System.Environment]::SetEnvironmentVariable('Path', $newPath, [System.EnvironmentVariableTarget]::Machine)
        Write-Output "Directory '$directory' removed from PATH."
    }
}

function Remove-PhpArtisanAlias {
    param (
        [string]$alias,
        [string]$directory
    )

    $aliasFile = "$directory\$alias.bat"
    if (Test-Path $aliasFile) {
        Remove-Item -Path $aliasFile -Force
        Write-Output "Existing alias file '$aliasFile' has been removed."

        # Check if the directory is empty after removing the alias file
        $remainingFiles = Get-ChildItem -Path $directory
        if ($remainingFiles.Count -eq 0) {
            Remove-Item -Path $directory -Force
            Write-Output "Directory '$directory' is empty and has been removed."
            Remove-FromPath -directory $directory
        }
    }
}

function Check-PhpArtisanAlias {
    param (
        [ref]$conflictPath,
        [ref]$aliasName
    )

    $existingPath = [System.Environment]::GetEnvironmentVariable('Path', 'Machine')
    $paths = $existingPath.Split(';')
    foreach ($path in $paths) {
        $aliasFiles = Get-ChildItem -Path $path -Filter "*.bat" -ErrorAction SilentlyContinue
        foreach ($file in $aliasFiles) {
            $content = Get-Content -Path $file.FullName
            if ($content -match "php artisan") {
                $conflictPath.Value = $path
                $aliasName.Value = $file.BaseName
                return $true
            }
        }
    }
    return $false
}

function Get-ScriptHash {
    param (
        [string]$scriptPath
    )
    $hash = Get-FileHash -Path $scriptPath -Algorithm SHA256
    return $hash.Hash
}

# Function to restart the script
function Restart-Script {
    Clear-Host
    Write-Output "Restarting script..."
    Start-Process powershell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -Command `"$PSCommandPath`"" -Verb RunAs
    exit
}

# Get the system drive
$systemDrive = [System.IO.Path]::GetPathRoot([System.Environment]::SystemDirectory)

# Get the script hash
$scriptPath = $PSCommandPath
$scriptHash = Get-ScriptHash -scriptPath $scriptPath

# Main logic
while ($true) {
    Clear-Host
    # Check for admin rights
    if (-not (Test-Admin)) {
        Write-Output "This script requires administrative privileges."
        Write-Output "The script will request admin rights in 3 seconds..."
        Start-Sleep -Seconds 3
        Restart-Script
    }

    Clear-Host
    # Display initial options
    Write-Output "Please select an option:"
    Write-Output "1. Start the process"
    Write-Output "2. Exit"
    Write-Output ""
    Write-Output "Script SHA-256: $scriptHash"
    Write-Output "Developer: skysea45"
    $initialChoice = Read-Host "Enter your choice (1/2)"
    if ($initialChoice -eq "2" -or $initialChoice -eq "0") {
        Clear-Host
        Write-Output "Operation cancelled by user."
        Write-Output "The script will close in 2 seconds..."
        Start-Sleep -Seconds 2
        exit
    } elseif ($initialChoice -ne "1") {
        Clear-Host
        Write-Output "Invalid choice. Restarting script..."
        Restart-Script
    }

    Clear-Host
    # Default values
    $defaultDirectory = "$systemDrive\aliases"
    $defaultAlias = "pia"
    $directory = $null
    $alias = $null

    # Inform user about the default directory
    Write-Output "The alias will be added to the default directory: $defaultDirectory"
    Write-Output "Press 0 to return to the main menu."
    $response = Read-Host "Would you like to change the directory? (y/n) [n]"
    if ($response -eq "0") {
        continue
    } elseif ($response -eq "y") {
        Clear-Host
        $customDirectory = Read-Host "Enter the custom directory"
        if ($customDirectory -eq "0") {
            continue
        }
        $directory = $customDirectory
    } else {
        $directory = $defaultDirectory
    }

    Clear-Host
    # Inform user about the default alias
    Write-Output "The default alias is '$defaultAlias'"
    Write-Output "Press 0 to return to the main menu."
    $response = Read-Host "Would you like to change the alias? (y/n) [n]"
    if ($response -eq "0") {
        continue
    } elseif ($response -eq "y") {
        Clear-Host
        $alias = Read-Host "Enter the custom alias"
        if ($alias -eq "0") {
            continue
        }
    } else {
        $alias = $defaultAlias
    }

    Clear-Host

    # Check for existing php artisan alias in PATH
    $conflictPath = ""
    $aliasName = ""
    if (Check-PhpArtisanAlias -conflictPath ([ref]$conflictPath) -aliasName ([ref]$aliasName)) {
        $response = Read-Host "An alias for 'php artisan' already exists as '$aliasName' at '$conflictPath'. Do you want to remove it and use the new alias from the new directory? (y/n) [n]"
        if ($response -eq "y") {
            Remove-PhpArtisanAlias -alias $aliasName -directory $conflictPath
        } else {
            Write-Output "Alias creation cancelled due to conflict. Returning to the alias naming step."
            continue
        }
    }

    # Ensure the directory exists but do not create it yet
    if (-not (Test-Path $directory)) {
        $directoryExists = $false
    } else {
        $directoryExists = $true
    }

    # Remove existing php artisan alias in the target directory
    Remove-PhpArtisanAlias -alias $alias -directory $directory

    # Create the directory if it does not exist
    if (-not $directoryExists) {
        New-Item -Path $directory -ItemType Directory
        Write-Output "Directory '$directory' created successfully."
    }

    # Create alias file
    if (-not (Create-AliasFile -alias $alias -directory $directory)) {
        continue
    }

    Clear-Host
    # Add directory to PATH
    Add-ToPath -directory $directory

    Write-Output "Alias '$alias' created and added to PATH successfully."
    Write-Output "The script will close in 5 seconds..."
    Start-Sleep -Seconds 5
    exit
}
