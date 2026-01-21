# ==========================================================
# Axelus Optimizer — Core Functions
# ==========================================================

function Set-PowerPlan {
    try {
        powercfg -duplicatescheme e9a42b02-d5df-448d-aa00-03f14749eb61 > $null
        powercfg -setactive e9a42b02-d5df-448d-aa00-03f14749eb61
        return @{Text="Ultimate Performance Power Plan set!"; Success=$true}
    } catch { return @{Text="Failed to set Power Plan: $_"; Success=$false} }
}

function Disable-GameDVR {
    try {
        reg add "HKCU\System\GameConfigStore" /v GameDVR_Enabled /t REG_DWORD /d 0 /f
        reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\GameDVR" /v AllowGameDVR /t REG_DWORD /d 0 /f
        return @{Text="Game DVR disabled!"; Success=$true}
    } catch { return @{Text="Failed to disable Game DVR: $_"; Success=$false} }
}

function Input-LatencyTweaks {
    try {
        reg add "HKCU\Control Panel\Mouse" /v MouseSpeed /t REG_SZ /d 0 /f
        reg add "HKCU\Control Panel\Mouse" /v MouseThreshold1 /t REG_SZ /d 0 /f
        reg add "HKCU\Control Panel\Mouse" /v MouseThreshold2 /t REG_SZ /d 0 /f
        return @{Text="Input & Latency optimized!"; Success=$true}
    } catch { return @{Text="Failed Input & Latency tweaks: $_"; Success=$false} }
}

function Network-Optimizations {
    try {
        netsh interface tcp set global autotuninglevel=normal
        netsh interface tcp set global ecncapability=disabled
        netsh interface tcp set global timestamps=disabled
        return @{Text="Network optimized!"; Success=$true}
    } catch { return @{Text="Failed Network optimizations: $_"; Success=$false} }
}

function Services-Debloat {
    $services = @("DiagTrack","MapsBroker","SysMain","WSearch","Fax","RetailDemo","XboxGipSvc","XboxNetApiSvc","XblAuthManager","XblGameSave")
    try {
        foreach ($svc in $services) {
            Get-Service -Name $svc -ErrorAction SilentlyContinue | Where-Object {$_.Status -ne "Stopped"} | Stop-Service -Force
            Set-Service -Name $svc -StartupType Disabled -ErrorAction SilentlyContinue
        }
        return @{Text="Unnecessary services disabled!"; Success=$true}
    } catch { return @{Text="Failed to debloat services: $_"; Success=$false} }
}

function GPU-Tweaks {
    try {
        reg add "HKLM\SYSTEM\CurrentControlSet\Control\GraphicsDrivers" /v HwSchMode /t REG_DWORD /d 2 /f
        return @{Text="GPU & system tweaks applied!"; Success=$true}
    } catch { return @{Text="Failed GPU tweaks: $_"; Success=$false} }
}

