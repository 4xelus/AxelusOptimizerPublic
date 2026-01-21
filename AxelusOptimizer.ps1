# ==========================================================
# Axelus Optimizer
# High-performance Windows gaming optimizer
# Author: Axelus
# ==========================================================

# REQUIRE ADMIN
if (-not ([Security.Principal.WindowsPrincipal] `
    [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(`
    [Security.Principal.WindowsBuiltInRole] "Administrator"))
{
    Write-Host "Run PowerShell as Administrator!" -ForegroundColor Red
    exit
}

Clear-Host
Write-Host "==============================================" -ForegroundColor Cyan
Write-Host " AXELUS OPTIMIZER - MAX PERFORMANCE MODE" -ForegroundColor Green
Write-Host "==============================================" -ForegroundColor Cyan

# ----------------------------------------------------------
# SYSTEM INFO
# ----------------------------------------------------------
$cpu = (Get-CimInstance Win32_Processor).Name
$gpu = (Get-CimInstance Win32_VideoController | Select-Object -First 1).Name
$ram = [math]::Round((Get-CimInstance Win32_ComputerSystem).TotalPhysicalMemory / 1GB)

Write-Host "CPU: $cpu"
Write-Host "GPU: $gpu"
Write-Host "RAM: $ram GB"
Write-Host ""

# ----------------------------------------------------------
# POWER PLAN (ULTIMATE PERFORMANCE)
# ----------------------------------------------------------
Write-Host "[1/6] Setting Ultimate Performance power plan..." -ForegroundColor Yellow
powercfg -duplicatescheme e9a42b02-d5df-448d-aa00-03f14749eb61 > $null
powercfg -setactive e9a42b02-d5df-448d-aa00-03f14749eb61

# ----------------------------------------------------------
# GAME MODE + DVR OFF
# ----------------------------------------------------------
Write-Host "[2/6] Disabling Game DVR & background capture..." -ForegroundColor Yellow
reg add "HKCU\System\GameConfigStore" /v GameDVR_Enabled /t REG_DWORD /d 0 /f
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\GameDVR" /v AllowGameDVR /t REG_DWORD /d 0 /f

# ----------------------------------------------------------
# INPUT & LATENCY TWEAKS
# ----------------------------------------------------------
Write-Host "[3/6] Applying input & latency optimizations..." -ForegroundColor Yellow
reg add "HKCU\Control Panel\Mouse" /v MouseSpeed /t REG_SZ /d 0 /f
reg add "HKCU\Control Panel\Mouse" /v MouseThreshold1 /t REG_SZ /d 0 /f
reg add "HKCU\Control Panel\Mouse" /v MouseThreshold2 /t REG_SZ /d 0 /f

# ----------------------------------------------------------
# NETWORK OPTIMIZATION
# ----------------------------------------------------------
Write-Host "[4/6] Network latency optimizations..." -ForegroundColor Yellow
netsh interface tcp set global autotuninglevel=normal
netsh interface tcp set global ecncapability=disabled
netsh interface tcp set global timestamps=disabled

# ----------------------------------------------------------
# SERVICES DEBLOAT (SAFE FOR GAMING)
# ----------------------------------------------------------
Write-Host "[5/6] Disabling unnecessary services..." -ForegroundColor Yellow

$services = @(
    "DiagTrack",
    "MapsBroker",
    "SysMain",
    "WSearch",
    "Fax",
    "RetailDemo",
    "XboxGipSvc",
    "XboxNetApiSvc",
    "XblAuthManager",
    "XblGameSave"
)

foreach ($svc in $services) {
    Get-Service -Name $svc -ErrorAction SilentlyContinue | `
    Where-Object {$_.Status -ne "Stopped"} | `
    Stop-Service -Force
    Set-Service -Name $svc -StartupType Disabled -ErrorAction SilentlyContinue
}

# ----------------------------------------------------------
# GPU SCHEDULING + SYSTEM TWEAKS
# ----------------------------------------------------------
Write-Host "[6/6] GPU & system performance tweaks..." -ForegroundColor Yellow
reg add "HKLM\SYSTEM\CurrentControlSet\Control\GraphicsDrivers" /v HwSchMode /t REG_DWORD /d 2 /f

# ----------------------------------------------------------
# FINISH
# ----------------------------------------------------------
Write-Host ""
Write-Host "==============================================" -ForegroundColor Green
Write-Host " OPTIMIZATION COMPLETE" -ForegroundColor Green
Write-Host " Restart PC for full effect." -ForegroundColor Cyan
Write-Host "==============================================" -ForegroundColor Green
