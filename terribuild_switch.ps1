param ([string]$region)

$version_string = "1.1.0"

switch ($region) {
    "EU" { $title_id = "010040000C596000"; $suffix = "eng"; break }
    "US" { $title_id = "010042800B880000"; $suffix = "eng"; break }
    Default {}
}

function PrintSection {
    param ([string]$desc)
    $line = "------------------------------------------------------------------------"
    $len = (($line.length, $desc.legnth) | Measure -Max).Maximum
    
    Write-Host ""
    Write-Host $line.PadRight($len) -BackgroundColor DarkBlue -ForegroundColor Cyan
    Write-Host ("      >> " + $desc).PadRight($len) -BackgroundColor DarkBlue -ForegroundColor Cyan
    Write-Host $line.PadRight($len) -BackgroundColor DarkBlue -ForegroundColor Cyan
    Write-Host ""
}

Write-Output "                          ＴＥＲＲＩＢＵＩＬＤ"
Write-Output "Rated World's #1 Build Script By Leading Game Industry Officials"
Write-Output ""
Write-Output "------------------------------------------------------------------------"
Write-Output ""

PrintSection "Creating new DIST and temp"
Remove-Item -Force -Recurse -ErrorAction SilentlyContinue .\DIST
New-Item -ItemType directory -Path .\DIST | Out-Null

PrintSection "Pulling latest script changes"
cd sge-scripts
& git pull
cd ..

PrintSection "Patching scripts and copying to romfs"
New-Item -ItemType directory -Path .\temp\patched_script_archive | Out-Null
copy script_archive_switch\*.scx temp\patched_script_archive
New-Item -ItemType directory -Path .\temp\patched_edited_script_archive | Out-Null
copy temp\patched_script_archive\*.scx temp\patched_edited_script_archive
.\sc3tools\target\release\sc3tools.exe replace-text temp\patched_edited_script_archive\*.scx sge-scripts\*.txt sge
Copy-Item -Recurse -Force temp\patched_edited_script_archive .\DIST\atmosphere\contents\$title_id\romfs\script

PrintSection "Copying assets to romfs"
Copy-Item -Recurse .\c0data_switch_$suffix\* .\DIST\atmosphere\contents\$title_id\romfs

PrintSection "Copying readme and license"
Copy-Item -Recurse .\content_switch\* .\DIST\atmosphere\contents\$title_id

PrintSection "Clean"
Get-ChildItem -Path .\DIST -Include .gitkeep -Recurse | foreach { $_.Delete()}

PrintSection "Packing the patch"
$patchFolderName = "SGESwitch${region}Patch-v$version_string-Setup"
cd .\DIST
7z a -mx=5 "$patchFolderName.zip" "."
Remove-Item -Force -Recurse .\atmosphere
cd ..

PrintSection "Removing temp"
Remove-Item -Force -Recurse .\temp