# Registry path settings
$regBasePath = "Registry::HKEY_CLASSES_ROOT\SystemFileAssociations"
$formats = @("image", ".bmp", ".heic", ".webp")
$convertScript = "C:\Users\ballb\Documents\SourceCode\Windows_Scripts\Convert_Images\Convert_images.ps1"

# Function to add context menu items
function Add-ImageConversionContextMenu {
    param(
        [string] $format
    )

    $convertToJpegPath = "${regBasePath}\$format\shell\Convert to Jpeg"
    $convertToWebpPath = "${regBasePath}\$format\shell\Convert to WebP"

    try {
        # Create 'Convert to JPEG' menu item
        New-Item -Path $convertToJpegPath -Force
        Set-ItemProperty -Path $convertToJpegPath -Name '(Default)' -Value 'Convert to Jpeg'
        New-Item -Path "${convertToJpegPath}\command" -Force
        Set-ItemProperty -Path "${convertToJpegPath}\command" -Name '(Default)' -Value "powershell -NoProfile -Command `"& {& `'$convertScript`' -Files @(`'%1`') -Format `'jpeg`'}`"" -ErrorAction Stop

        # Create 'Convert to WebP' menu item
        New-Item -Path $convertToWebpPath -Force
        Set-ItemProperty -Path $convertToWebpPath -Name '(Default)' -Value 'Convert to WebP'
        New-Item -Path "${convertToWebpPath}\command" -Force
        Set-ItemProperty -Path "${convertToWebpPath}\command" -Name '(Default)' -Value "powershell -NoProfile -Command `"& {& `'$convertScript`' -Files @(`'%1`') -Format `'webp`'}`"" -ErrorAction Stop

    } catch {
        Write-Error "Error: $_"
        return $false
    }
    return $true
}

# Function to remove all context menu items under $regBasePath
function Remove-AllImageConversionContextMenu {
    # Get all sub_keys under the base path
    Write-Host "Getting all keys."
    $sub_keys = Get-ChildItem -Path $regBasePath
    $counter = 1
    $total_count = $sub_keys.Length

    Write-Host "Start delete."
    foreach ($sub_key in $sub_keys) {
        $convert_to_jpeg_path = $sub_key.PSPath + "\shell\Convert to Jpeg"
        $convert_to_webp_path = $sub_key.PSPath + "\shell\Convert to WebP"

        try {
            # Remove 'Convert to JPEG' menu item
            if (Test-Path -Path $convert_to_jpeg_path) {
                Remove-Item -Path $convert_to_jpeg_path -Recurse -Force -ErrorAction Stop
                Write-Host "Removed $convert_to_jpeg_path"
            }
            # Remove 'Convert to WebP' menu item
            if (Test-Path -Path $convert_to_webp_path) {
                Remove-Item -Path $convert_to_webp_path -Recurse -Force -ErrorAction Stop
                Write-Host "Removed $convert_to_webp_path"
            }
        } catch {
            Write-Error "Error: $_"
            return $false
        }

        # Counter text
        Write-Host "Processing ${counter}/${total_count}."
        $counter++
    }

    return $true
}


# Main function to choose installation or deletion based on user input
function Main {
    $user_input = Read-Host "Enter any character to install, enter 'delete' to remove context menus:"
    if ($user_input -eq "delete") {
        $result = Remove-AllImageConversionContextMenu
        if ($result -eq $true) {
            Write-Host "All relevant context menu items have been removed."
        } else {
            Write-Host "Error happened."            
        }
    } else {
        foreach ($format in $formats) {
            Write-Host "Adding context menu to ${format}."
            $result = Add-ImageConversionContextMenu -format $format
            if ($result -eq $false) {
                Write-Host "Error happened with adding context menu to ${format}."
                exit
            }
        }
        Write-Host "Context menu items have been added."
    }
}

# Return if script is not run by administrator
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Host "You are not running PowerShell as an administrator. Please run this script as an administrator."
    exit
}

# Run the main function
Main