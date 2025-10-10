# PowerShell script to extract date from filename and update EXIF "AllDates" tag

# Path to the folder containing images
$folderPath = "E:\Amazon Drive\Pictures\VRChat"

$files = Get-ChildItem -Path $folderPath -File -Recurse -Include *.jpg, *.jpeg, *.png | Where-Object {$_.Name -notmatch '_dated'}
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
            Write-Host "Date already exists. Rename the file."
            
            $name = [System.IO.Path]::GetFileNameWithoutExtension($file)
            $ext = [System.IO.Path]::GetExtension($fileName)
            $newName = "${name}_dated$ext"
            Rename-Item -Path $file -NewName $newName
            
            Write-Host "Renamed file to: $newName"
            Continue
        }

        # Replace '_' with space for EXIF format
        $exifDateTime = $matches[0] -replace '_', ' '

        # Append +09:00 timezone
        $exifDateTimeWithTZ = "$exifDateTime+09:00"

        Write-Host "Setting EXIF AllDates to: $exifDateTimeWithTZ"

        # Call exiftool to update date fields
        & 'exiftool.exe' -overwrite_original -alldates="$exifDateTimeWithTZ" $file.FullName

        # Check the date was set and rename the file
        $Date = & 'exiftool.exe' -overwrite_original -DateTimeOriginal $file.FullName | Select-String "Date"
        if (![System.String]::IsNullOrWhiteSpace($Date)){
            Write-Host "Date set successfully. Rename the file."
            
            $name = [System.IO.Path]::GetFileNameWithoutExtension($file)
            $ext = [System.IO.Path]::GetExtension($fileName)
            $newName = "${name}_dated$ext"
            Rename-Item -Path $file -NewName $newName
            
            Write-Host "Renamed file to: $newName"
            Continue
        }
    }
    else {
        Write-Host "No valid date/time found in filename."
    }
}