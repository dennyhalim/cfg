# SAP-B1-Services.ps1
# Usage:
#   .\SAP-B1-Services.ps1 -Action Start
#   .\SAP-B1-Services.ps1 -Action Stop
#   .\SAP-B1-Services.ps1 -Action Restart
#   .\SAP-B1-Services.ps1 -Action Status
#   .\SAP-B1-Services.ps1 -Action Stop -IncludeSQL
#   .\SAP-B1-Services.ps1 -Action Start -IncludeSQL
param(
    [ValidateSet("Start","Stop","Restart","Status")]
    [string]$Action = "Status",
    [switch]$IncludeSQL,
    [int]$WaitSeconds = 15
)

# --- CONFIG: Order matters ---
# START order: Bottom-up
$StartOrder = @(
    "MSSQLSERVER",                    # 1. DB - only if -IncludeSQL
    "B1LicenseService",               # 2. License
    "B1ServerTools",                  # 3. Server Tools
    "SAP Business One SLD",           # 4. SLD - name varies, see below
    "B1SLD",
    "SAP Business One Service Layer", # 5. Service Layer
    "SAP Business One Web Client",    # 6. Web Client
    "SAPB1iDIProxy",                  # 7. B1i
    "SAPB1iDIProxy_Monitor",
    "SAPB1iEventSender",
    "B1Workflow",                     # 8. Workflow
    "SAPB1EventSender"
)

# STOP order: Top-down = reverse of Start
$StopOrder = @(
    "B1Workflow",
    "SAPB1EventSender",
    "SAPB1iEventSender",
    "SAPB1iDIProxy_Monitor",
    "SAPB1iDIProxy",
    "SAP Business One Web Client",
    "SAP Business One Service Layer",
    "SAP Business One SLD",
    "B1SLD",
    "B1ServerTools",
    "B1LicenseService",
    "MSSQLSERVER"
)

$LogFile = "$env:TEMP\SAP-B1-Services.log"
function Log($msg) {
    $line = "[$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')] $msg"
    Write-Host $line
    Add-Content -Path $LogFile -Value $line -ErrorAction SilentlyContinue
}

function Wait-ForStatus($Name, $Desired, $TimeoutSec = 60) {
    $sw = [Diagnostics.Stopwatch]::StartNew()
    while ($sw.Elapsed.TotalSeconds -lt $TimeoutSec) {
        $svc = Get-Service -Name $Name -ErrorAction SilentlyContinue
        if (-not $svc) { return $true }
        if ($svc.Status -eq $Desired) { return $true }
        Start-Sleep -Seconds 2
    }
    return $false
}

function Do-Start {
    Log "=== START SAP B1 Services ==="
    foreach ($name in $StartOrder) {
        if ($name -eq "MSSQLSERVER" -and -not $IncludeSQL) {
            Log "SKIP $name (use -IncludeSQL to include DB)"
            continue
        }
        $svc = Get-Service -Name $name -ErrorAction SilentlyContinue
        if (-not $svc) {
            Log "SKIP $name (not installed)"
            continue
        }
        if ($svc.Status -eq "Running") {
            Log "ALREADY RUNNING: $name"
            continue
        }
        Log "STARTING: $name ..."
        try {
            Start-Service -Name $name -ErrorAction Stop
            $ok = Wait-ForStatus $name "Running" 60
            if ($ok) { Log "OK: $name is Running" } else { Log "WARN: $name did not reach Running in 60s - check log" }
            # License needs extra time before SLD can connect
            if ($name -eq "B1LicenseService") { Log "Waiting ${WaitSeconds}s for License to bind port 30000..."; Start-Sleep -Seconds $WaitSeconds }
            if ($name -eq "B1ServerTools") { Start-Sleep -Seconds 5 }
            if ($name -eq "SAP Business One SLD" -or $name -eq "B1SLD") { Start-Sleep -Seconds 5 }
        } catch {
            Log "FAIL: $name - $($_.Exception.Message)"
        }
    }
    Log "=== START DONE ==="
}

function Do-Stop {
    Log "=== STOP SAP B1 Services ==="
    foreach ($name in $StopOrder) {
        if ($name -eq "MSSQLSERVER" -and -not $IncludeSQL) {
            Log "SKIP $name (use -IncludeSQL to include DB)"
            continue
        }
        $svc = Get-Service -Name $name -ErrorAction SilentlyContinue
        if (-not $svc) {
            Log "SKIP $name (not installed)"
            continue
        }
        if ($svc.Status -eq "Stopped") {
            Log "ALREADY STOPPED: $name"
            continue
        }
        Log "STOPPING: $name ..."
        try {
            Stop-Service -Name $name -Force -ErrorAction Stop
            $ok = Wait-ForStatus $name "Stopped" 60
            if ($ok) { Log "OK: $name is Stopped" } else { Log "WARN: $name did not stop in 60s - may need Taskkill" }
            Start-Sleep -Seconds 2
        } catch {
            Log "FAIL: $name - $($_.Exception.Message)"
        }
    }
    Log "=== STOP DONE ==="
}

function Do-Status {
    Log "=== STATUS ==="
    $all = $StartOrder + $StopOrder | Select-Object -Unique
    foreach ($name in $all) {
        $svc = Get-Service -Name $name -ErrorAction SilentlyContinue
        if ($svc) {
            $color = if ($svc.Status -eq "Running") { "Green" } else { "Yellow" }
            Write-Host ("{0,-35} {1}" -f $name, $svc.Status) -ForegroundColor $color
        }
    }
    # Ports
    Write-Host ""
    Write-Host "Ports:" -ForegroundColor Cyan
    netstat -ano | Select-String "30000|40000|50000|8443|1433" | ForEach-Object { Write-Host "  $_" }
}

# --- MAIN ---
# Must be Admin
$principal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
if (-not $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "ERROR: Run as Administrator!" -ForegroundColor Red
    exit 1
}

switch ($Action) {
    "Start"   { Do-Start; Do-Status }
    "Stop"    { Do-Stop; Do-Status }
    "Restart" { Do-Stop; Start-Sleep -Seconds 5; Do-Start; Do-Status }
    "Status"  { Do-Status }
}
