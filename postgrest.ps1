# Start-PostgREST.ps1
param(
    [string]$ConfigPath = "$PSScriptRoot\postgrest.conf"
)

# required env vars that your original script used
$required = @("ORACLE_POSTGRES_USERNAME","ORACLE_POSTGRES_PASSWORD","ORACLE_POSTGRES_HOST","ORACLE_POSTGRES_PORT")
$missing = @()
foreach ($n in $required) { if (-not $env:$n) { $missing += $n } }
if ($missing.Count -gt 0) {
    Write-Error "Missing environment variables: $($missing -join ', ')"
    exit 1
}

# default DB name (use ORACLE_POSTGRES_DBNAME if set; else 'finfolio')
if (-not $env:ORACLE_POSTGRES_DBNAME) { $env:ORACLE_POSTGRES_DBNAME = "finfolio" }

# Build the Postgres URI
$pgrstUri = "postgres://{0}:{1}@{2}:{3}/{4}" -f $env:ORACLE_POSTGRES_USERNAME, $env:ORACLE_POSTGRES_PASSWORD, $env:ORACLE_POSTGRES_HOST, $env:ORACLE_POSTGRES_PORT, $env:ORACLE_POSTGRES_DBNAME

# Export for PostgREST (process environment)
$env:PGRST_DB_URI = $pgrstUri

# Mask the password for display
$masked = $pgrstUri -replace ":(.+?)@", ":****@"
Write-Host "Starting PostgREST with DB URI: $masked"

# Verify executable exists
$exe = Join-Path $PSScriptRoot "postgrest.exe"
if (-not (Test-Path $exe)) { Write-Error "postgrest.exe not found at $exe"; exit 1 }

# Launch PostgREST (foreground). Change to Start-Process for background:
& $exe $ConfigPath
