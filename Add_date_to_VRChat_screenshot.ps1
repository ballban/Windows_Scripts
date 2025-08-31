# PowerShell script to extract date from filename and update EXIF "AllDates" tag

# Path to the folder containing images
$folderPath = "E:\Amazon Drive\Pictures\VRChat"

$files = Get-ChildItem -Path $folderPath -File -Recurse -Include *.jpg, *.jpeg, *.png
$fileCount = $files.Count
Write-Output "$fileCount files found."
for ($i = 0; $i -lt $files.Count; $i++) {
    $file = $files[$i]
    Write-Output "----------------------------------------"
    Write-Output "Processing $($i + 1)/$fileCount"
    Write-Output "Processing file: $($file.FullName)"

    # Extract just the filename
    $fileName = [System.IO.Path]::GetFileName($file.FullName)

    # Use regex to find the date-time portion from filename
    if ($fileName -match '\d{4}-\d{2}-\d{2}_\d{2}-\d{2}-\d{2}(\.\d{3})?') {
        $Date = & 'exiftool.exe' -overwrite_original -DateTimeOriginal $file.FullName | Select-String "Date"
        Write-Output $Date
        # Return if date already exists
        
        if (![System.String]::IsNullOrWhiteSpace($Date)){
            Write-Host "Date already exists. Skipping file."
            Continue
        }

        # Replace '_' with space for EXIF format
        $exifDateTime = $matches[0] -replace '_', ' '

        # Append +09:00 timezone
        $exifDateTimeWithTZ = "$exifDateTime+09:00"

        Write-Host "Setting EXIF AllDates to: $exifDateTimeWithTZ"

        # Call exiftool to update date fields
        # Requires exiftool installed and in PATH
        & 'exiftool.exe' -overwrite_original -alldates="$exifDateTimeWithTZ" $file.FullName
    }
    else {
        Write-Host "No valid date/time found in filename."
    }
}