if (Test-Path "..\.env") {
    Get-Content "..\.env" | ForEach-Object {
        $line = $_.Trim()
        if ($line -and -not $line.StartsWith("#") -and $line.Contains("=")) {
            $key, $value = $line.Split("=", 2)
            $key = $key.Trim()
            $value = $value.Trim()
            [System.Environment]::SetEnvironmentVariable($key, $value, "Process")
            Write-Host "Set env: $key"
        }
    }
}
mvn spring-boot:run
