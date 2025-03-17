param (
    [string[]]$Files,
    [string]$Format
)

foreach ($File in $Files) {
    $OutputFile = [System.IO.Path]::ChangeExtension($File, $Format)
    Start-Process -FilePath "magick" -ArgumentList "`"$File`" `"$OutputFile`"" -Wait
}