try {
    # Config paths
    $SourceFolder = "C:\Files\SourceFolder"
    $TargetFolder = "C:\Files\TargetFolder"
    $ArchiveFolder = "C:\Files\Archives"
    $LogTable = "FileArchiveLog"
    $SqlServerInstance = "SANJARBEK\SQLEXPRESS"
    $Database = "SSIS11"
    $ErrorLogFile = "C:\Files\error_log.txt"

    # Create folders if not exist
    New-Item -ItemType Directory -Force -Path $TargetFolder | Out-Null
    New-Item -ItemType Directory -Force -Path $ArchiveFolder | Out-Null

    # Generate timestamp and archive name
    $timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
    $archiveName = "Archive_$timestamp.zip"
    $archivePath = Join-Path $ArchiveFolder $archiveName

    # Filter files
    $filesToMove = Get-ChildItem -Path $SourceFolder -Filter *.csv | Where-Object {
        $_.Length -gt 1KB -and $_.Name -match '\d{8}_\d{6}'
    }

    if (-not $filesToMove) {
        Write-Host "❌ No matching files to process."
        exit 0
    }

    # Move files
    foreach ($file in $filesToMove) {
        Move-Item -Path $file.FullName -Destination $TargetFolder -Force
    }

    # Archive
    Compress-Archive -Path "$TargetFolder\*.csv" -DestinationPath $archivePath -Force

    if (-Not (Test-Path $archivePath)) {
        throw "Archive creation failed."
    }

    # Validate archive
    $tempExtractFolder = "$env:TEMP\ArchiveTest_$timestamp"
    New-Item -ItemType Directory -Path $tempExtractFolder | Out-Null
    Expand-Archive -Path $archivePath -DestinationPath $tempExtractFolder -Force

    if ((Get-ChildItem $tempExtractFolder -Filter *.csv).Count -eq 0) {
        throw "Archive validation failed. No files found after extraction."
    }

    # Delete original files
    foreach ($file in $filesToMove) {
        Remove-Item $file.FullName -Force
    }

    # Log to SQL
    $connectionString = "Server=$SqlServerInstance;Database=$Database;Integrated Security=True;"
    $logQuery = @"
INSERT INTO dbo.$LogTable (ArchiveFileName, ArchiveFilePath, ArchivedDate)
VALUES ('$archiveName', '$archivePath', GETDATE());
"@
    Invoke-Sqlcmd -Query $logQuery -ConnectionString $connectionString

    Write-Host "✅ Files archived and logged successfully."
}
catch {
    $errorMsg = "❌ Error occurred: $($_.Exception.Message)"
    Write-Host $errorMsg
    Add-Content -Path $ErrorLogFile -Value "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') $errorMsg"
}
finally {
    # Clean up temp
    if (Test-Path $tempExtractFolder) {
        Remove-Item -Path $tempExtractFolder -Recurse -Force -ErrorAction SilentlyContinue
    }
}
